import Foundation
import Combine
import Logging

/**
 Manages the authorization process for the [Authorization Code Flow][1].
 
 The first step in the authorization code flow is to make the
 authorization URL using
 `makeAuthorizationURL(redirectURI:showDialog:state:scopes:)`.
 
 Open this URL in a broswer/webview to allow the user to login
 to their Spotify account and authorize your application.
 After they either authorize or deny authorization for your application,
 Spotify will redirect to the redirect URI specified in the authorization
 URL with query parameters appended to it. Pass this URL into
 `requestAccessAndRefreshTokens(redirectURIWithQuery:state:)` to request
 the refresh and access tokens. After that you can begin making requests
 to the Spotify API. The access token will be refreshed for you
 automatically when needed.
 
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
 */
public final class AuthorizationCodeFlowManager:
    SpotifyScopeAuthorizationManager, Codable
{
    
    public static var logger = Logger(
        label: "AuthorizationCodeFlowManager", level: .critical
    )
    
    /// The client id for your application.
    public let clientId: String
    
    /// The client secret for your application.
    public let clientSecret: String
    
    /**
     The access token used in all of the requests
     to the Spotify web API.
     
     # Thread Safety
     
     Access to this property is synchronized; therefore, it is always
     thread-safe.
     */
    public var accessToken: String? {
        return self.updateAuthInfoDispatchQueue.sync {
            self._accessToken
        }
    }
    private var _accessToken: String? = nil
    
    /**
     Used to refresh the access token.
     
     # Thread Safety
     
     Access to this property is synchronized; therefore, it is always
     thread-safe.
     */
    public var refreshToken: String? {
        return self.updateAuthInfoDispatchQueue.sync {
            self._refreshToken
        }
    }
    private var _refreshToken: String? = nil
    
    /**
     The expiration date of the access token.
    
     You are encouraged to use `accessTokenIsExpired(tolerance:)`
     to check if the token is expired.
     
     # Thread Safety
     
     Access to this property is synchronized; therefore, it is always
     thread-safe.
     */
    public var expirationDate: Date? {
        return self.updateAuthInfoDispatchQueue.sync {
            self._expirationDate
        }
    }
    private var _expirationDate: Date? = nil
    
    /**
     The scopes that have been authorized for the access token.
    
     You are encouraged to use `isAuthorized(for:)`to check
     which scopes the access token is authorized for.
     
     # Thread Safety
     
     Access to this property is synchronized; therefore, it is always
     thread-safe.
     */
    public var scopes: Set<Scope>? {
        return self.updateAuthInfoDispatchQueue.sync {
            self._scopes
        }
    }
    private var _scopes: Set<Scope>? = nil
    
    /**
     A Publisher that emits **after** this `AuthorizationCodeFlowManager`
     has changed.
     
     Emits after the following events occur:
     * After the access token (and possibly the refresh token as well) is
       refreshed. This occurs in `refreshTokens(onlyIfExpired:tolerance:)`.
     * After the access and refresh tokens are retrieved using
       `requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`.
     * After `deauthorize()`—which sets `accessToken`, `refreshToken`,
       `expirationDate`, and `scopes` to `nil`—is called.
     
     You are discouraged from subscribing to this publisher directly.
     Instead, subscribe to the `SpotifyAPI.authorizationManagerDidChange`
     publisher. This allows you to be notified of changes even
     when you create a new instance of this class and assign it to the
     `authorizationManager` instance property of `SpotifyAPI`.
     
     # Thread Safety
     
     No guarantees are made about which thread this subject will emit on.
     Always receive on the main thread if you plan on updating the UI.
     */
    public let didChange = PassthroughSubject<Void, Never>()
    
    private var cancellables: Set<AnyCancellable> = []
    
    /// Ensure no data races occur when updating the auth info.
    private let updateAuthInfoDispatchQueue = DispatchQueue(
        label: "updateAuthInfoDispatchQueue"
    )

    /**
     The request to refresh the access token is stored in this
     property so that if multiple asyncronous requests are made
     to refresh the access token, then only one actual network
     request is made. Once this publisher finishes, it is set to
     `nil`.
     */
    private var refreshTokensPublisher: AnyPublisher<Void, Error>? = nil
    
    /**
     Creates an authorization manager for the [Authorization Code Flow][1].
     
     To get your client id and secret,
     see the [guide for registering your app][1].
     
     - Parameters:
       - clientId: The client id for your application.
       - clientSecret: The client secret for your application.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: https://developer.spotify.com/documentation/general/guides/app-settings/
     */
    public init(
        clientId: String,
        clientSecret: String
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    public init(from decoder: Decoder) throws {
        
        let codingWrapper = try AuthInfo(from: decoder)
        
        self._accessToken = codingWrapper.accessToken
        self._refreshToken = codingWrapper.refreshToken
        self._expirationDate = codingWrapper.expirationDate
        self._scopes = codingWrapper.scopes
        
        let container = try decoder.container(
            keyedBy: AuthInfo.CodingKeys.self
        )
        self.clientId = try container.decode(
            String.self, forKey: .clientId
        )
        self.clientSecret = try container.decode(
            String.self, forKey: .clientSecret
        )
        
    }
    
    public func encode(to encoder: Encoder) throws {
        let codingWrapper = self.updateAuthInfoDispatchQueue.sync {
            return AuthInfo(
                accessToken: self._accessToken,
                refreshToken: self._refreshToken,
                expirationDate: self._expirationDate,
                scopes: self._scopes
            )
        }
        
        var container = encoder.container(
            keyedBy: AuthInfo.CodingKeys.self
        )
        
        try container.encode(
            self.clientId, forKey: .clientId
        )
        try container.encode(
            self.clientSecret, forKey: .clientSecret
        )
        try codingWrapper.encode(to: encoder)
        
    }
    
}

public extension AuthorizationCodeFlowManager {
    
    /**
     Sets `accessToken`, `refreshToken`, `expirationDate`, and
     `scopes` to `nil`. Does not change `clientId` or `clientSecret`,
     which are immutable.
     
     After calling this method, you must authorize your application
     again before accessing any of the Spotify web API endpoints.
     
     If this instance is stored in persistent storage, consider
     removing it after calling this method.
     
     # Thread Safety
     
     This method is thread-safe.
     */
    func deauthorize() {
        self.updateAuthInfoDispatchQueue.sync {
            self._accessToken = nil
            self._refreshToken = nil
            self._expirationDate = nil
            self._scopes = nil
            self.refreshTokensPublisher = nil
        }
        self.didChange.send()
    }
    
    /**
     Determines whether the access token is expired
     within the given tolerance.
     
     See also `isAuthorized(for:)`.
     
     The access token is refreshed automatically when necessary
     before each request to the spotify web API is made.
     Therefore, **you should never need to call this method directly.**
     
     - Parameter tolerance: The tolerance in seconds.
           Default 120.
     - Returns: `true` if `expirationDate` - `tolerance` is
           equal to or before the current date or if `accessToken`
           is `nil`. Else, `false`.
     
     # Thread Safety
     
     This method is thread-safe.
     */
    func accessTokenIsExpired(tolerance: Double = 120) -> Bool {
        return self.updateAuthInfoDispatchQueue.sync {
            return accessTokenIsExpiredNOTTHreadSafe(tolerance: tolerance)
        }
    }
    
    /**
     Returns `true` if `accessToken` is not `nil` and the application
     is authorized for the specified scopes, else `false`.
     
     - Parameter scopes: A set of [Spotify Authorizaion Scopes][1].
           Use an empty set (default) to check if an `accessToken`
           has been retrieved for the application, which is still
           required for all endpoints, even those that do not require
           scopes.
     
     # Thread Safety
     
     This method is thread-safe.
     
     [1]: https://developer.spotify.com/documentation/general/guides/scopes/
     */
    func isAuthorized(for scopes: Set<Scope> = []) -> Bool {
        return self.updateAuthInfoDispatchQueue.sync {
            if _accessToken == nil { return false }
            return scopes.isSubset(of: self._scopes ?? [])
        }
    }
    
    /**
     The first step in the [Authorization Code Flow][1].
     
     Creates the URL that is used to request authorization for
     your app. Open the URL in a browser/webview so that the user can
     login to their Spotify account and authorize your app.
     
     After the user either authorizes or denies authorization for your
     application, Spotify will redirect to `redirectURI` with query parameters
     appended to it. Pass that URL into
     `requestAccessAndRefreshTokens(redirectURIWithQuery:state:)` to complete
     the authorization process.
     
     - Warning: **DO NOT add a forward-slash to the end of the redirect URI**.

     - Parameters:
       - redirectURI: The location that Spotify will redirect to
             after the user authorizes or denies authorization for your app.
             Usually, this should link to a location in your app.
             This URI needs to have been entered in the Redirect URI whitelist
             that you specified when you registered your application.
             The value must exactly match one of the values you entered when
             you registered your application, including upper or lowercase,
             terminating slashes, and such.
       - showDialog: Whether or not to force the user to approve the app again
             if they’ve already done so. If `false`,
             a user who has already approved the application
             may be automatically redirected to the `redirectURI`.
             If `true`, the user will not be automatically
             redirected and will have to approve the app again.
       - state: Optional, but strongly recommended. **If you provide a value**
             **for this parameter, you must pass the same value to**
             `requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`,
             **otherwise an error will be thrown.** The state can be useful for
             correlating requests and responses. Because your redirect_uri can
             be guessed, using a state value can increase your assurance that
             an incoming connection is the result of an authentication request
             that you made. If you generate a random string or encode the hash of
             some client state (e.g., a cookie) in this state variable, you can
             validate the response to additionally ensure that the request and
             response originated in the same browser. This provides protection
             against attacks such as cross-site request forgery.
       - scopes: A set of [Spotify Authorization scopes][2].
     - Returns: The URL that must be opened to authorize your app. May return
           `nil` if the URL could not be created.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: x-source-tag://Scopes
     
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
            queryItems: removeIfNil([
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
     
     - Parameters:
       - redirectURIWithQuery: The redirect URI with query parameters appended to it.
       - state: The value of the state parameter that you provided when
             making the authorization URL. **If the state parameter in**
             redirectURIWithQuery **doesn't match this value, then an error will**
             **be thrown.** If `nil`, then the state parameter must not be present
             in the redirect URI, otherwise an error will be thrown.
     
     # Thread Safety
     
     Calling this method is thread-safe. If a network request to refresh the tokens
     is already in progress, additional calls will return a reference to the same
     publisher as a class instance.
     
     **However**, no guarentees are made about the thread that the publisher
     returned by this method will emit on.
     
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
                .anyFailingPublisher(Void.self)
            }
            
            Self.logger.error("unkown error")
            return SpotifyLocalError.other(
                """
                an unknown error occured when handling the redirect URI: \
                expected to find 'code' or 'error' parameter in query string: \
                '\(redirectURIWithQuery.absoluteString)'
                """
            )
            .anyFailingPublisher(Void.self)
            
        }
        
        // if a state parameter was provided in the query string of the
        // redirect URI, then ensure that it matches the value for the state
        // parameter passed to this method.
        guard state == queryDict["state"] else {
            return SpotifyLocalError.invalidState(
                supplied: queryDict["state"], received: state
            )
            .anyFailingPublisher(Void.self)
        }
        
        let baseRedirectURI = redirectURIWithQuery
            .removingQueryItems()
            .removingTrailingSlashInPath()
        
        let body = TokensRequest(
            code: code,
            redirectURI: baseRedirectURI,
            clientId: clientId,
            clientSecret: clientSecret
        ).formURLEncoded()
        
        Self.logger.trace("sending request for refresh and access tokens")
        
        return URLSession.shared.dataTaskPublisher(
            url: Endpoints.getTokens,
            httpMethod: "POST",
            headers: Headers.formURLEncoded,
            body: body
        )
        // decoding into `AuthInfo` never fails, so we must
        // try to decode errors first.
        .decodeSpotifyErrors()
        .decodeSpotifyObject(AuthInfo.self)
        .map { authInfo in
            
            Self.logger.trace("received authInfo:\n\(authInfo)")
            
            if authInfo.accessToken == nil ||
                    authInfo.refreshToken == nil ||
                    authInfo.expirationDate == nil ||
                    authInfo.scopes == nil {
                
                Self.logger.critical(
                    """
                    missing properties after requesting \
                    access and refresh tokens:
                    \(authInfo)
                    """
                )
            }
            
            self.updateFromAuthInfo(authInfo)
            
        }
        .eraseToAnyPublisher()
        
    }

    /**
     Uses the refresh token to get a new access token.
    
     **You shouldn't need to call this method**. It gets
     called automatically each time you make a request to the
     Spotify API.
     
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
                    
                    guard let header = Headers.basicBase64Encoded(
                        clientId: self.clientId, clientSecret: self.clientSecret
                    )
                    else {
                        // this error should never occur
                        let message = "couldn't base 64 encode " +
                            "client id and client secret"
                        Self.logger.critical("\(message)")
                        throw SpotifyLocalError.other(message)
                    }
                    
                    let requestBody = RefreshAccessTokenRequest(
                        refreshToken: refreshToken
                    ).formURLEncoded()
                    
                    let refreshTokensPublisher = URLSession.shared.dataTaskPublisher(
                        url: Endpoints.getTokens,
                        httpMethod: "POST",
                        headers: header,
                        body: requestBody
                    )
                    // decoding into `AuthInfo` never fails because all of its,
                    // properties are optional, so we must try to decode errors
                    // first.
                    .decodeSpotifyErrors()
                    .decodeSpotifyObject(AuthInfo.self)
                    .map { authInfo in
                        
                        Self.logger.trace("received authInfo:\n\(authInfo)")
                        
                        if authInfo.accessToken == nil ||
                                authInfo.expirationDate == nil ||
                                authInfo.scopes == nil {
                            Self.logger.critical(
                                """
                            missing properties after refreshing access token:
                            \(authInfo)
                            """
                            )
                        }
                        
                        self.updateFromAuthInfo(authInfo)
                        
                    }
                    .handleEvents(
                        // once this publisher finishes, we must
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
            return error.anyFailingPublisher(Void.self)
        }
        
    }
    
}

private extension AuthorizationCodeFlowManager {
    
    func updateFromAuthInfo(_ authInfo: AuthInfo) {
        self.updateAuthInfoDispatchQueue.sync {
            self._accessToken = authInfo.accessToken
            if let refreshToken = authInfo.refreshToken {
                self._refreshToken = refreshToken
            }
            self._expirationDate = authInfo.expirationDate
            self._scopes = authInfo.scopes
            self.refreshTokensPublisher = nil
        }
        Self.logger.trace("didChange.send()")
        self.didChange.send()
    }
    
    /// This method should **ALWAYS** be called within
    /// `updateAuthInfoDispatchQueue`.
    func accessTokenIsExpiredNOTTHreadSafe(tolerance: Double = 120) -> Bool {
        if (_accessToken == nil) != (_expirationDate == nil) {
            let expirationDateString = _expirationDate?
                .description(with: .current) ?? "nil"
            Self.logger.critical(
                """
                    accessToken or expirationDate was nil, but not both:
                    accessToken == nil: \(_accessToken == nil); \
                    expiration date: \(expirationDateString)
                    """
            )
        }
        if _accessToken == nil { return true }
        guard let expirationDate = _expirationDate else { return true }
        return expirationDate.addingTimeInterval(-tolerance) <= Date()
    }
    
}

extension AuthorizationCodeFlowManager {
    
    func assertNotOnUpdateAuthInfoDispatchQueue() {
        dispatchPrecondition(
            condition: .notOnQueue(self.updateAuthInfoDispatchQueue)
        )
    }

}


// MARK: - Hashable and Equatable -

extension AuthorizationCodeFlowManager: Hashable {

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

// MARK: - Custom String Convertible

extension AuthorizationCodeFlowManager: CustomStringConvertible {
    
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

// MARK: - Testing -

extension AuthorizationCodeFlowManager {
    
    /// This method sets random values for various properties
    /// for testing purposes. Do not call it outside the context
    /// of tests.
    func mockValues() {
        self.updateAuthInfoDispatchQueue.sync {
            self._accessToken = UUID().uuidString
            self._refreshToken = UUID().uuidString
            self._expirationDate = Date()
            self._scopes = Set(Scope.allCases.shuffled().prefix(5))
        }
    }
    
    /// Only use for testing purposes.
    func makeCopy() -> Self {
        let instance = Self(
            clientId: self.clientId, clientSecret: self.clientSecret
        )
        return self.updateAuthInfoDispatchQueue.sync {
            instance._accessToken = self._accessToken
            instance._refreshToken = self._refreshToken
            instance._expirationDate = self._expirationDate
            instance._scopes = self._scopes
            return instance
        }
    }
    
    /// Only use for testing purposes.
    func subscribeToDidChange() {
        
        self.didChange
            .print(
                "AuthorizationCodeFlowManager.subscribeToDidChange"
            )
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)
        
    }
    
    /// Only use for testing purposes.
    func setExpirationDate(to date: Date) {
        self.updateAuthInfoDispatchQueue.sync {
            Self.logger.notice(
                "mock date: \(date.description(with: .current))"
            )
            self._expirationDate = date
        }
    }
    
}
