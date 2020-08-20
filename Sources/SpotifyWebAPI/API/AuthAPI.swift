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
     Returns `true` if the application is authorized
     for the specified scopes, else `false`.

     - Parameter scopes: [Spotify Authorizaion Scopes][1].
    
     [1]: https://developer.spotify.com/documentation/general/guides/scopes/
     */
    func isAuthorized(for scopes: Set<Scope>) -> Bool {
        return (try? self.ensureAuthorized(forScopes: scopes)) != nil
    }
    
    /**
     The first step in the [Authorization Code Flow][1].
     
     Creates the URL that is used to request authorization for
     your app. Open in URL in a browser/webview so that the user can
     login to their Spotify account and authorize your app.
     
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
       - state: Optional, but strongly recommended. The state can be useful for
                correlating requests and responses. Because your redirect_uri can
                be guessed, using a state value can increase your assurance that
                an incoming connection is the result of an authentication request.
                If you generate a random string or encode the hash of some client
                state (e.g., a cookie) in this state variable, you can validate the
                response to additionally ensure that the request and response
                originated in the same browser. This provides protection against
                attacks such as cross-site request forgery.
     - Returns: The URL that must be opened to authorize your app.
     
     - Warning: **DO NOT add a forward-slash to the end of the redirect URI**.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: x-source-tag://Scopes
     
     - Tag: makeAuthorizationURL
     */
    func makeAuthorizationURL(
        redirectURI: URL,
        scopes: Set<Scope>,
        showDialog: Bool,
        state: String? = nil
    ) -> URL {
        
        return URL(
            scheme: "https",
            host: Endpoints.accountsBase,
            path: Endpoints.authorize,
            queryItems: removeIfNil([
                "client_id": self.clientID,
                "response_type": "code",
                "redirect_uri": redirectURI.absoluteString,
                "scope": Scope.makeString(scopes),
                "show_dialog": "\(showDialog)",
                "state": state
            ])
        )!
        
    }
    
    /**
     The second step in the [Authorization Code Flow][1].
     
     After you open the url from `makeAuthorizationURL` and the user either
     authorizes or denies authorization for your app, Spotify will redirect
     to the redirect uri you specified with query parameters appended to it.
     Pass this URL into this method to request access and refresh tokens.
     
     These tokens, along with the scopes that the access token is
     authorized for and its expiration date, will be stored in the
     `@Published var authInfo` instance property of this class.
     You must subscribe to that publisher to be notified of all
     changes to the authorization info. For this reason, the output
     of this publisher is `Void`.
     
     When subscribing to this publisher, consider using the convienence
     method `sink(receiveCompletion:)`, which only takes a completion
     handler. Available for all publishers where `Output` == `Void`.
     
     - Parameters:
       - redirectURI: The redirect URI with query parameters appended to it.
       - state: The value of the state parameter that you provided when
             making the authorization URL. If this is non-nil and doesn't
             match the value for the state parameter found in the query
             string of `redirectURIWithQuery`, an error will be thrown.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     
     - Tag: requestAccessAndRefreshTokens-redirectURIWithQuery
     */
    func requestAccessAndRefreshTokens(
        redirectURIWithQuery redirectURI: URL,
        state: String? = nil
    ) -> AnyPublisher<Void, Error> {
       
        self.authLogger.trace("raw url: \(redirectURI)")
        
        let queryDict = redirectURI.queryItemsDict
        
        if let code = queryDict["code"] {
            
            if let redirectURIstate = queryDict["state"],
                    let state = state {
                
                if redirectURIstate != state {
                    return SpotifyLocalError.invalidState(
                        supplied: state, received: redirectURIstate
                    )
                    .anyFailingPublisher(Void.self)
                }
            }

            let baseRedirectURI = redirectURI
                    .removingQueryItems()
                    .removingTrailingSlashInPath()

            // MARK: golden path
            return self._requestAccessAndRefreshTokens(
                baseRedirectURI: baseRedirectURI,
                code: code
            )
        }
        
        if let error = queryDict["error"] {
            // this is the way that the authorization should fail
            self.authLogger.warning("redirect uri query has error")
            return SpotifyAuthorizationError(
                error: error, state: queryDict["state"]
            )
            .anyFailingPublisher(Void.self)
            
        }
        
        self.authLogger.error("unkown error")
        return SpotifyLocalError.other(
            "an unknown error occured when handling the redirect URI:\n" +
            redirectURI.absoluteString
        )
        .anyFailingPublisher(Void.self)
            
    }
    
    /**
     Uses the refresh token to get a new access token.
    
     **You shouldn't need to call this method**. It gets
     called automatically each time you make a request to the
     Spotify API.
     
     Subscribe to the `@Published var authInfo` instance
     property of this class to be notified of changes
     to the authorization info. For this reason, the output
     of this publisher is `Void`.
     
     - Parameters:
       - onlyIfExpired: Only refresh the token if it is expired.
       - tolerance: The tolerance in seconds to use when determining
             if the token is expired. Defaults to 60.
             The token is considered expired if
             `expirationDate` + `tolerance` is equal to or
             before the current date.
     */
    func refreshAccessToken(
        onlyIfExpired: Bool,
        tolerance: Double = 60
    ) -> AnyPublisher<Void, Error> {
        
        let refreshAccessTokenFunction = #function
        
        do {
            
            // ensure that the user has authorized their app.
            guard let authInfo = self.authInfo else {
                throw SpotifyLocalError.unauthorized(
                    "can't refresh access token: no authorization"
                )
            }

            // if the token should only be refreshed if expired
            // and it's not expired, then return early.
            if onlyIfExpired && !authInfo.isExpired(tolerance: tolerance) {
                self.authLogger.trace("access token not expired; returning early")
                return Result<Void, Error>
                    .Publisher(.success(()))
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
            .receive(on: RunLoop.main)
            .map { newAuthInfo in
                self.authLogger.trace("recieved new access token")
                if newAuthInfo.refreshToken != nil {
                    self.authLogger.notice(
                        "also recieved new refresh token"
                    )
                }
                if self.authInfo == nil {
                    self.authLogger.error(
                        "self.authInfo was nil after " +
                        "retrieving new authInfo",
                        function: refreshAccessTokenFunction
                    )
                }
                self.authInfo = AuthInfo(
                    accessToken: newAuthInfo.accessToken,
                    refreshToken: newAuthInfo.refreshToken ?? refreshToken,
                    expirationDate: newAuthInfo.expirationDate,
                    scopes: newAuthInfo.scopes
                )
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher(Void.self)
        }

    }
    
}

// MARK: - Internal Methods -

extension SpotifyAPI {
    
    private func _requestAccessAndRefreshTokens(
        baseRedirectURI: URL,
        code: String
    ) -> AnyPublisher<Void, Error> {
        
        let requestBody = TokensRequest(
            code: code,
            redirectURI: baseRedirectURI,
            clientId: clientID,
            clientSecret: clientSecret
        )
        
        self.authLogger.notice("")
        
        return URLSession.shared.dataTaskPublisher(
            url: Self.getRefreshAndAccessTokensURL,
            httpMethod: "POST",
            headers: Headers.formURLEncoded,
            body: requestBody.formURLEncoded()
        )
        .spotifyDecode(AuthInfo.self)
        .logError(to: self.authLogger)
        .receive(on: RunLoop.main)
        .map { authInfo in
            self.authLogger.notice("recieved authInfo:\n\(authInfo)")
            self.authInfo = authInfo
        }
        .eraseToAnyPublisher()
        
    }
    
    
    /// Ensures that `self.authInfo` is not `nil` and that the app is
    /// authorized for the specified scopes. Else, throws an error.
    ///
    /// - Parameter requiredScopes: A set of Spotify scopes.
    ///
    /// - Returns: `self.authInfo.value` unwrapped.
    func ensureAuthorized(
        forScopes requiredScopes: Set<Scope>
    ) throws -> AuthInfo {
        
        self.authLogger.trace("forScopes: \(requiredScopes)")
        
        guard let authInfo = self.authInfo else {
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
