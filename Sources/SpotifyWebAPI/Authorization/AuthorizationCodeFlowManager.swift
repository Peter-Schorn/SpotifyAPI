import Foundation
import Combine
import Logging

/**
 Manages the authorization process for the [Authorization Code Flow][1].
 
 For applications where it is unsafe to store your client secret, consider
 using `AuthorizationCodeFlowPKCEManager`, which manages the
 [Authorization Code Flow with Proof Key for Code Exchange][2]; it provides
 an additional layer of security.
 
 The first step in the authorization code flow is to make the
 authorization URL using
 `makeAuthorizationURL(redirectURI:showDialog:state:scopes:)`.
 Open this URL in a broswer/webview to allow the user to login
 to their Spotify account and authorize your application.
 
 After they either authorize or deny authorization for your application,
 Spotify will redirect to the redirect URI specified in the authorization
 URL with query parameters appended to it. Pass this URL into
 `requestAccessAndRefreshTokens(redirectURIWithQuery:state:)` to request
 the refresh and access tokens. After that, you can begin making requests
 to the Spotify API. The access token will be refreshed for you
 automatically when needed.
 
 Note that this type conforms to `Codable`. It is this type that you should
 encode to data using a `JSONEncoder` in order to save it to persistent storage.
 See this [article][3] for more information.
 
 Use `isAuthorized(for:)` to check if your application is authorized
 for the specified scopes.
 
 Use `deauthorize()` to set the `accessToken`, `refreshToken`, `expirationDate`,
 and `scopes` to `nil`. Does not change `clientId` or `clientSecret`,
 which are immutable.
 
 Contains the following properties:
 
 * The client id
 * The client secret
 * The access token
 * The refresh token
 * The expiration date for the access token
 * The scopes that have been authorized for the access token
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 [2]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 [3]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
 */
public final class AuthorizationCodeFlowManager:
    AuthorizationCodeFlowManagerBase,
    SpotifyScopeAuthorizationManager
{
    
    /// The logger for this class.
    public static var logger = Logger(
        label: "AuthorizationCodeFlowManager", level: .critical
    )
    
    /**
     Creates an authorization manager for the [Authorization Code Flow][1].
     
     To get a client id and client secret, go to the
     [Spotify Developer Dashboard][2] and create an app. see the README in the
     root directory of this package for more information.
     
     Note that this type conforms to `Codable`. It is this type that you should
     encode to data using a `JSONEncoder` in order to save it to persistent storage.
     See [Saving authorization information to persistent storage][3] for more
     information.
     
     - Parameters:
       - clientId: The client id for your application.
       - clientSecret: The client secret for your application.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: https://developer.spotify.com/dashboard/login
     [3]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
     */
    public required init(
        clientId: String,
        clientSecret: String
    ) {
        super.init(clientId: clientId, clientSecret: clientSecret)
    }
    
    /**
     Creates an authorization manager for the [Authorization Code Flow][1].
     
     **In general, only use this initializer if you have retrieved the**
     **authorization information from an external source.** Otherwise, use
     `init(clientId:clientSecret:)`.
    
     You are discouraged from individually saving the properties of this instance
     to persistent storage and then retrieving them later and passing them into
     this initializer. Instead, encode this entire instance to data using a
     `JSONEncoder` and then decode the data from storage later. See
     [Saving authorization information to persistent storage][3] for more
     information.
     
     To get a client id and client secret, go to the
     [Spotify Developer Dashboard][2] and create an app. see the README in the root
     directory of this package for more information.
     
     - Parameters:
       - clientId: The client id for your application.
       - clientSecret: The client secret for your application.
       - accessToken: The access token.
       - expirationDate: The expiration date of the access token.
       - refreshToken: The refresh token.
       - scopes: The scopes that have been authorized for the access token.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: https://developer.spotify.com/dashboard/login
     [3]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
     */
    public convenience init(
        clientId: String,
        clientSecret: String,
        accessToken: String,
        expirationDate: Date,
        refreshToken: String,
        scopes: Set<Scope>
    ) {
        self.init(clientId: clientId, clientSecret: clientSecret)
        self._accessToken = accessToken
        self._expirationDate = expirationDate
        self._refreshToken = refreshToken
        self._scopes = scopes
    }
    
    // MARK: - Codable -
    
    /// :nodoc:
    public override init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    /// :nodoc:
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
}

public extension AuthorizationCodeFlowManager {
    
    // MARK: - Authorization -
    
    /**
     The first step in the [Authorization Code Flow][1].
     
     Creates the URL that is used to request authorization for your app. It
     displays a permissins dialog to the user. Open the URL in a
     browser/webview so that the user can login to their Spotify account and
     authorize your app.
     
     After the user either authorizes or denies authorization for your
     application, Spotify will redirect to `redirectURI` with query parameters
     appended to it. Pass that URL into
     `requestAccessAndRefreshTokens(redirectURIWithQuery:state:)` to complete
     the authorization process.
     
     # Warning:
     
     **DO NOT add a forward-slash to the end of the redirect URI**.
     
     All of these values will be automatically percent-encoded.
     Therefore, do not percent-encode them yourself before passing them
     into this method.

     - Parameters:
       - redirectURI: The location that Spotify will redirect to
             after the user authorizes or denies authorization for your app.
             Usually, this should be a custom URL scheme that redirects to a
             location in your app.cThis URI needs to have been entered in the
             Redirect URI whitelist that you specified when you
             [registered your application][2].
       - showDialog: Whether or not to force the user to approve the app again
             if they’ve already done so. If `false`, a user who has already
             approved the application may be automatically redirected to the
             `redirectURI`. If `true`, the user will not be automatically
             redirected and will have to approve the app again.
       - state: Optional, but strongly recommended. **If you provide a value**
             **for this parameter, you must pass the same value to**
             `requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`,
             **otherwise an error will be thrown.** The state can be useful for
             correlating requests and responses. Because your redirect URI can
             be guessed, using a state value can increase your assurance that
             an incoming connection is the result of an authentication request
             that you made. If you generate a random string or encode the hash of
             some client state (e.g., a cookie) in this state variable, you can
             validate the response to additionally ensure that the request and
             response originated in the same browser. This provides protection
             against attacks such as cross-site request forgery.
       - scopes: A set of [Spotify Authorization scopes][3].
     - Returns: The URL that must be opened to authorize your app. May return
           `nil` if the URL could not be created.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: https://developer.spotify.com/dashboard/applications
     [3]: https://developer.spotify.com/documentation/general/guides/scopes/
     
     - Tag: makeAuthorizationURL
     */
    func makeAuthorizationURL(
        redirectURI: URL,
        showDialog: Bool,
        state: String? = nil,
        scopes: Set<Scope>
    ) -> URL? {
        
        return URL(
            scheme: "https",
            host: Endpoints.accountsBase,
            path: Endpoints.authorize,
            queryItems: urlQueryDictionary([
                "client_id": self.clientId,
                "response_type": "code",
                "redirect_uri": redirectURI.absoluteString,
                "scope": Scope.makeString(scopes),
                "show_dialog": showDialog,
                "state": state
            ])
        )
        
    }
    
    /**
     The second and final step in the [Authorization Code Flow][1].
     
     After you open the URL from
     `makeAuthorizationURL(redirectURI:scopes:showDialog:state:)`
     and the user either authorizes or denies authorization for your app,
     Spotify will redirect to the redirect URI you specified with query
     parameters appended to it. Pass this URL into this method to request
     access and refresh tokens. The access token is required for all endpoints,
     even those that do not access user data.
     
     If the user denied your app's authorization request or the request failed
     for some other reason, then `SpotifyAuthorizationError` will be thrown to
     downstream subscribers. Use the `accessWasDenied` boolean property of this
     error to check if the user denied your app's authorization request.
     
     If the request for the access and refresh tokens suceeds, `self.didChange`
     will emit a signal, which causes `SpotifyAPI.authorizationManagerDidChange`
     to emit a signal.
     
     - Parameters:
       - redirectURIWithQuery: The redirect URI with query parameters appended to
             it.
       - state: The value of the state parameter that you provided when
             making the authorization URL. The state can be useful for
             correlating requests and responses. Because your redirect URI can
             be guessed, using a state value can increase your assurance that
             an incoming connection is the result of an authentication request
             that you made. **If the state parameter in the query string of**
             `redirectURIWithQuery` **doesn't match this value, then an error will**
             **be thrown.** If `nil`, then the state parameter must not be present
             in `redirectURIWithQuery` either, otherwise an error will be thrown.
             After this request has been made, you should generate a new value
             for this parameter in preparation for the next authorization process.
     
     # Warning:
     
     All of these values will be automatically percent-encoded.
     Therefore, do not percent-encode them yourself before passing them
     into this method.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     
     - Tag: requestAccessAndRefreshTokens-redirectURIWithQuery
     */
    func requestAccessAndRefreshTokens(
        redirectURIWithQuery: URL,
        state: String? = nil
    ) -> AnyPublisher<Void, Error> {

        Self.logger.trace(
            "redirectURIWithQuery: '\(redirectURIWithQuery)'"
        )
        
        // a dictionary of the query items in the URL
        let queryDict = redirectURIWithQuery.queryItemsDict

        // if the code is found in the query,
        // then the user successfully authorized the application.
        // this is required for requesting the access and refresh tokens.
        guard let code = queryDict["code"] else {
            
            if let error = queryDict["error"] {
                Self.logger.warning("redirect uri query has error")
                // This is the way that the authorization should fail.
                // For example, if the user denied the app's authorization
                // request, then this error will be returned.
                return SpotifyAuthorizationError(
                    error: error, state: queryDict["state"]
                )
                .anyFailingPublisher()
            }
            
            Self.logger.error("unkown error")
            return SpotifyLocalError.other(
                """
                an unknown error occured when handling the redirect URI: \
                expected to find 'code' or 'error' parameter in query string: \
                '\(redirectURIWithQuery.absoluteString)'
                """
            )
            .anyFailingPublisher()
            
        }
        
        // Ensure the state paramter in the query string of the redirect
        // URI matches the value provided to this method.
        guard state == queryDict["state"] else {
            return SpotifyLocalError.invalidState(
                supplied: state, received: queryDict["state"]
            )
            .anyFailingPublisher()
        }
        
        let baseRedirectURI = redirectURIWithQuery
            .removingQueryItems()
            .removingTrailingSlashInPath()
        
        let body = TokensRequest(
            code: code,
            redirectURI: baseRedirectURI,
            clientId: clientId,
            clientSecret: clientSecret
        )
        .formURLEncoded()
        
        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
        
        Self.logger.trace(
            """
            POST request to "\(Endpoints.getTokens)" \
            (URL for requesting access and refresh tokens); body:
            \(bodyString)
            """
        )
        
        return URLSession.shared.dataTaskPublisher(
            url: Endpoints.getTokens,
            httpMethod: "POST",
            headers: Headers.formURLEncoded,
            body: body
        )
        // Decoding into `AuthInfo` never fails because all of its
        // properties are optional, so we must try to decode errors
        // first.
        .decodeSpotifyErrors()
        .decodeSpotifyObject(AuthInfo.self)
        .tryMap { authInfo in
            
            Self.logger.trace("received authInfo:\n\(authInfo)")
            
            if authInfo.accessToken == nil ||
                    authInfo.refreshToken == nil ||
                    authInfo.expirationDate == nil ||
                    authInfo.scopes == nil {
                
                let errorMessage = """
                    missing properties after requesting access and \
                    refresh tokens (expected access token, refresh token, \
                    expiration date, and scopes):
                    \(authInfo)
                    """
                Self.logger.error("\(errorMessage)")
                throw SpotifyLocalError.other(errorMessage)
                
            }
            
            self.updateFromAuthInfo(authInfo)
            
        }
        .eraseToAnyPublisher()
        
    }

    /**
     Uses the refresh token to get a new access token.
    
     **You shouldn't need to call this method**. It gets called automatically
     each time you make a request to the Spotify API.
     
     If the access and/or refresh tokens are refreshed, then `self.didChange`
     will emit a signal, which causes `SpotifyAPI.authorizationManagerDidChange`
     to emit a signal.
     
     # Thread Safety
     
     Calling this method is thread-safe. If a network request to refresh the
     tokens is already in progress, additional calls will return a reference
     to the same publisher as a class instance.
     
     **However**, no guarentees are made about the thread that the publisher
     returned by this method will emit on.
     
     - Parameters:
       - onlyIfExpired: Only refresh the access token if it is expired.
       - tolerance: The tolerance in seconds to use when determining
             if the token is expired. Defaults to 120, meaning that
             a new token will be retrieved if the current one has expired
             or will expire in the next two minutes. The token is
             considered expired if `expirationDate` - `tolerance` is
             equal to or before the current date. This parameter has
             no effect if `onlyIfExpired` is `false`.
     */
    func refreshTokens(
        onlyIfExpired: Bool,
        tolerance: Double = 120
    ) -> AnyPublisher<Void, Error> {
        
        do {
            
            return try self.updateAuthInfoDispatchQueue
                .sync { () -> AnyPublisher<Void, Error> in
                    
                    if onlyIfExpired && !self.accessTokenIsExpiredNOTTHreadSafe(
                        tolerance: tolerance
                    ) {
                        Self.logger.trace(
                            "access token not expired; returning early"
                        )
                        return Result<Void, Error>
                            .Publisher(())
                            .eraseToAnyPublisher()
                    }
                    
                    Self.logger.notice("refreshing tokens...")
                
                    // If another request to refresh the tokens is currently
                    // in progress, return the same request instead of creating
                    // a new network request.
                    if let refreshTokensPublisher = self.refreshTokensPublisher {
                        Self.logger.notice("using previous publisher")
                        return refreshTokensPublisher
                    }
                    
                    Self.logger.trace("creating new publisher")
                    
                    guard let refreshToken = self._refreshToken else {
                        let errorMessage =
                                "can't refresh access token: no refresh token"
                        Self.logger.warning("\(errorMessage)")
                        throw SpotifyLocalError.unauthorized(errorMessage)
                    }
                    
                    guard let headers = Headers.basicBase64Encoded(
                        clientId: self.clientId, clientSecret: self.clientSecret
                    )
                    else {
                        // this error should never occur
                        let message = "couldn't base 64 encode " +
                            "client id and client secret"
                        Self.logger.error("\(message)")
                        throw SpotifyLocalError.other(message)
                    }
                    
                    let body = RefreshAccessTokenRequest(
                        refreshToken: refreshToken
                    )
                    .formURLEncoded()
                    
                    let bodyString = String(data: body, encoding: .utf8) ?? "nil"
                    
                    Self.logger.trace(
                        """
                        POST request to "\(Endpoints.getTokens)" \
                        (URL for refreshing access token); body:
                        \(bodyString)
                        """
                    )
                    
                    let refreshTokensPublisher = URLSession.shared.dataTaskPublisher(
                        url: Endpoints.getTokens,
                        httpMethod: "POST",
                        headers: headers,
                        body: body
                    )
                    // Decoding into `AuthInfo` never fails because all of its
                    // properties are optional, so we must try to decode errors
                    // first.
                    .decodeSpotifyErrors()
                    .decodeSpotifyObject(AuthInfo.self)
                    .tryMap { authInfo in
                        
                        Self.logger.trace("received authInfo:\n\(authInfo)")
                        
                        if authInfo.accessToken == nil ||
                                authInfo.expirationDate == nil ||
                                authInfo.scopes == nil {

                            let errorMessage = """
                                missing properties after refreshing \
                                access token (expected access token, \
                                expiration date, and scopes):
                                \(authInfo)
                                """
                            Self.logger.error("\(errorMessage)")
                            throw SpotifyLocalError.other(errorMessage)
                            
                        }
                        
                        self.updateFromAuthInfo(authInfo)
                        
                    }
                    .handleEvents(
                        // Once this publisher finishes, we must
                        // set `self.refreshTokensPublisher` to `nil`
                        // so that the caller does not receive a publisher
                        // that has already finished.
                        receiveCompletion: { _ in
                            self.updateAuthInfoDispatchQueue.sync {
                                self.refreshTokensPublisher = nil
                            }
                        }
                    )
                    .share()
                    .eraseToAnyPublisher()
                    
                    self.refreshTokensPublisher = refreshTokensPublisher
                    return refreshTokensPublisher
                
            }
        
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
}

// MARK: - Custom String Convertible

extension AuthorizationCodeFlowManager: CustomStringConvertible {
    
    /// :nodoc:
    public var description: String {
        // print("AuthorizationCodeFlowManager.description WAITING for queue")
        return self.updateAuthInfoDispatchQueue.sync {
            // print("AuthorizationCodeFlowManager.description INSIDE queue")
            let expirationDateString = _expirationDate?
                    .description(with: .autoupdatingCurrent)
                    ?? "nil"
            
            let scopeString = _scopes.map({ "\($0.map(\.rawValue))" })
                    ?? "nil"
            
            return """
                AuthorizationCodeFlowManager(
                    access_token: "\(_accessToken ?? "nil")"
                    scopes: \(scopeString)
                    expirationDate: \(expirationDateString)
                    refresh_token: "\(_refreshToken ?? "nil")"
                    client id: "\(clientId)"
                    client secret: "\(clientSecret)"
                )
                """
        }
    }

}

// MARK: - Hashable and Equatable -

extension AuthorizationCodeFlowManager: Hashable {

    /// :nodoc:
    public func hash(into hasher: inout Hasher) {
        self.updateAuthInfoDispatchQueue.sync {
            hasher.combine(clientId)
            hasher.combine(clientSecret)
            hasher.combine(_accessToken)
            hasher.combine(_refreshToken)
            hasher.combine(_expirationDate)
            hasher.combine(_scopes)
        }
    }

    /// :nodoc:
    public static func == (
        lhs: AuthorizationCodeFlowManager,
        rhs: AuthorizationCodeFlowManager
    ) -> Bool {
        
        var areEqual = true
        
        let (lhsAccessToken, lhsRefreshToken, lhsScopes, lhsExpirationDate) =
            lhs.updateAuthInfoDispatchQueue
            .sync { () -> (String?, String?, Set<Scope>?, Date?) in
                    return (
                        lhs._accessToken,
                        lhs._accessToken,
                        lhs._scopes, lhs._expirationDate
                    )
                }
        
        let (rhsAccessToken, rhsRefreshToken, rhsScopes, rhsExpirationDate) =
                rhs.updateAuthInfoDispatchQueue
                    .sync { () -> (String?, String?, Set<Scope>?, Date?) in
                        return (
                            rhs._accessToken,
                            rhs._accessToken,
                            rhs._scopes,
                            rhs._expirationDate
                        )
                    }
        
        if lhs.clientId != rhs.clientId ||
                lhs.clientSecret != rhs.clientSecret ||
                lhsAccessToken != rhsAccessToken ||
                lhsRefreshToken != rhsRefreshToken ||
                lhsScopes != rhsScopes {
            areEqual = false
        }
        
        if abs(
            (lhsExpirationDate?.timeIntervalSince1970 ?? 0) -
                (rhsExpirationDate?.timeIntervalSince1970 ?? 0)
        ) > 3 {
            areEqual = false
        }

        return areEqual
        
    }

}
