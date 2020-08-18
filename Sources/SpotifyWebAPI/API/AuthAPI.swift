import Foundation
import Combine
import Logger

// MARK: Authorization Methods

public extension SpotifyAPI {
    
    /// Used to retrieve refresh and access tokens
    /// and to refresh an access token.
    ///
    /// ```
    /// "https://accounts.spotify.com/api/token"
    /// ```
    private static let getRefreshAndAccessTokensURL = URL(
        scheme: "https",
        host: Endpoints.accountsBase,
        path: Endpoints.getRefreshAndAccessTokens
    )!
    
    /**
     The first step in the [Authorization Code Flow][1].
     
     Creates the URL that is used to request authorization for
     your app. You can decide how to open the url. Typically,
     this URL is opened in the web browser.
     
     - Parameters:
       - redirectURI: The location that Spotify will redirect to
             after the user authorizes or denies authorization for your app.
             This should link to a location in your app.
       - scopes: An array of [Spotify Authorization scopes][2].
       - showDialog: Whether or not to force the user to approve the app again
             if they’ve already done so. If `false`,
             a user who has already approved the application
             may be automatically redirected to the `redirectURI`.
             If `true`, the user will not be automatically
             redirected and will have to approve the app again.
     - Returns: The URL that must be opened to authorize your app.
     
     - Warning: **DO NOT add a forward-slash to the end of the redirect URI**.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: x-source-tag://Scopes
     
     - Tag: makeAuthorizationURL
     */
    func makeAuthorizationURL(
        redirectURI: URL,
        scopes: Set<Scope>,
        showDialog: Bool
    ) -> URL {
        
        return URL(
            scheme: "https",
            host: Endpoints.accountsBase,
            path: Endpoints.authorize,
            queryItems: [
                "client_id": self.clientID,
                "response_type": "code",
                "redirect_uri": redirectURI.absoluteString,
                "scope": Scope.makeString(scopes),
                "show_dialog": "\(showDialog)"
            ]
        )!
        
    }
    
    /**
     The second step in the [Authorization Code Flow][1].
    
     After the user either authorizes or denies authorization
     for your app, it will redirect to the redirect uri you specified
     with query parameters appended to it.
     Pass this URL into this method to request access and refresh tokens.
    
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     
     - Tag: requestAccessAndRefreshTokens-redirectURIWithQuery
     */
    func requestAccessAndRefreshTokens(
        redirectURIWithQuery redirectURI: URL
    ) -> AnyPublisher<AuthInfo, Error> {
       
        self.authLogger.trace("raw url: \(redirectURI)")
        
        // MARK: golden path
        if let code = redirectURI.queryItemsDict["code"] {
            
            return self._requestAccessAndRefreshTokens(
                code: code,
                redirectURI: redirectURI
                    .removingQueryItems()
                    .removingTrailingSlashInPath()
            )
        }
        
        if let error = redirectURI.queryItemsDict["error"] {
            // this is the way that the authorization should fail
            self.authLogger.warning("redirect uri query has error")
            return SpotifyAuthorizationError(
                error: error, state: redirectURI.queryItemsDict["state"]
            )
            .anyFailingPublisher(AuthInfo.self)
            
        }
        self.authLogger.error("unkown error")
        return SpotifyLocalError.other(
            "an unknown error occured when handling the redirect URI:\n" +
            redirectURI.absoluteString
        )
        .anyFailingPublisher(AuthInfo.self)
            
    }
    
    func _requestAccessAndRefreshTokens(
        code: String,
        redirectURI: URL
    ) -> AnyPublisher<AuthInfo, Error> {
        
        
        self.authLogger.trace(
            "clientID: '\(clientID)'; clientSecret: '\(clientSecret)'"
        )
        
        let requestBody = TokensRequest(
            code: code,
            redirectURI: redirectURI,
            clientId: clientID,
            clientSecret: clientSecret
        )
        
        return URLSession.shared.dataTaskPublisher(
            url: Self.getRefreshAndAccessTokensURL,
            httpMethod: "POST",
            headers: Headers.formURLEncoded,
            body: requestBody.formURLEncoded()
        )
        .spotifyDecode(AuthInfo.self)
        .logError(to: self.authLogger)
        .handleEvents(receiveOutput: { authInfo in
            self.authLogger.trace("recieved authInfo:\n\(authInfo)")
            self.authInfo.value = authInfo
        })
        .eraseToAnyPublisher()
        
    }
    
    
    /**
     Uses the refresh token to get a new access token.
    
     **You shouldn't need to call this method**. It gets
     called automatically each time you make a request to the
     Spotify API.
    
     - Parameters:
       - onlyIfExpired: Only refresh the token if it is expired.
             Defaults to `true`.
       - tolerance: The tolerance in seconds to use when determining
             if the token is expired. Defaults to 60.
             The token is considered expired if
             the expirationDate + `tolerance` is equal to or
             before the current date.
     */
    func refreshAccessToken(
        onlyIfExpired: Bool = true,
        tolerance: Double = 60
    ) -> AnyPublisher<AuthInfo, Error> {
        
        let refreshAccessTokenFunction = #function
        
        do {
            
            // ensure that the user has authorized their app.
            guard let authInfo = self.authInfo.value else {
                throw SpotifyLocalError.unauthorized(
                    "can't refresh access token: no authorization"
                )
            }

            // if the token should only be refreshed if expired
            // and it's not expired, then return early.
            if onlyIfExpired && !authInfo.isExpired(tolerance: tolerance) {
                self.authLogger.trace("access token not expired; returning early")
                return Result<AuthInfo, Error>
                    .Publisher(.success(authInfo))
                    .eraseToAnyPublisher()
                
            }
        
            self.authLogger.notice("need to refresh access token")
            
            guard let refreshToken = authInfo.refreshToken else {
                throw SpotifyLocalError.other(
                    "can't refresh access token: no refresh token"
                )
            }
            
            guard let header = Headers.basicBase64Encoded(
                clientID: clientID, clientSecret: clientSecret
            )
            else {
                // this error should never occur
                let message = "couldn't base 64 encode " +
                        "client id and client secret"
                self.authLogger.critical("\(message)")
                throw SpotifyLocalError.other(message)
            }
            
            let requestBody = RefreshAccessTokenRequest(
                refreshToken: refreshToken
            )
            self.authLogger.debug("getting new token...")
            return URLSession.shared.dataTaskPublisher(
                url: Self.getRefreshAndAccessTokensURL,
                httpMethod: "POST",
                headers: header,
                body: requestBody.formURLEncoded()
            )
            .spotifyDecode(AuthInfo.self)
            .handleEvents(receiveOutput: { newAuthInfo in
                self.authLogger.trace("recieved new access token")
                if newAuthInfo.refreshToken != nil {
                    self.authLogger.notice(
                        "also recieved new refresh token"
                    )
                }
                if self.authInfo.value == nil {
                    self.authLogger.error(
                        "self.authInfo was nil after " +
                        "retrieving new authInfo",
                        function: refreshAccessTokenFunction
                    )
                }
                self.authInfo.value = AuthInfo(
                    accessToken: newAuthInfo.accessToken,
                    refreshToken: newAuthInfo.refreshToken ?? refreshToken,
                    expirationDate: newAuthInfo.expirationDate,
                    scopes: newAuthInfo.scopes
                )
            })
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher(AuthInfo.self)
        }

    }
    
    
    // MARK: - Internal Methods -
    
    /// Ensures that the app is authorized for the specified scopes
    /// and that `self.authInfo` is not `nil`. Else, throws an error.
    ///
    /// - Parameter requiredScopes: A set of Spotify scopes.
    ///
    /// - Returns: `self.authInfo` unwrapped.
    internal func ensureAuthorized(
        forScopes requiredScopes: Set<Scope>
    ) throws -> AuthInfo {
        
        self.authLogger.trace("\(requiredScopes)")
        
        guard let authInfo = self.authInfo.value else {
            throw SpotifyLocalError.unauthorized("no authorization")
        }
        
        guard requiredScopes.isSubset(of: authInfo.scopes) else {
            throw SpotifyLocalError.insufficientScope(
                requiredScopes: requiredScopes,
                authorizedScopes: authInfo.scopes
            )
        }
        
        return authInfo
        
    }
       
}
