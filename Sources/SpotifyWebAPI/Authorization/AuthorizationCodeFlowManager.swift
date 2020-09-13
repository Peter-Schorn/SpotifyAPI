import Foundation
import Combine
import Logger

/**
 Manages the authorization process for the [Authorization Code Flow][1].
 
 Contains the following properties:
 
 * The client id
 * The client secret
 * The access token
 * The refresh token
 * The expiration date for the access token
 * The scopes that have been authorized for the access token
 
 The first step in the authorization code flow is to make the
 authorization URL using
 `makeAuthorizationURL(redirectURI:scopes:showDialog:state:)`.
 
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
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 */
public final class AuthorizationCodeFlowManager: SpotifyAuthorizationManager, Codable {
    
    /// The logger for this class. By default, its level is `critical`.
    public static let logger = Logger(
        label: "AuthorizationCodeFlowManager", level: .critical
    )
    
    /// The client id for your application.
    public let clientId: String
    
    /// The client secret for your application.
    public let clientSecret: String
    
    /// The access token used in all of the requests
    /// to the Spotify web API.
    public private(set) var accessToken: String? = nil
    
    /// Used to refresh the access token.
    public private(set) var refreshToken: String? = nil
    
    /// The expiration date of the access token.
    ///
    /// You are encouraged to use `accessTokenIsExpired(tolerance:)`
    /// to check if the token is expired.
    public private(set) var expirationDate: Date? = nil
    
    /// The scopes that have been authorized for the access token.
    public private(set) var scopes: Set<Scope>? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    
    /// Ensure no data races occur when updating auth info.
    private let updateAuthInfoDispatchQueue = DispatchQueue(
        label: "updateAuthInfoDispatchQueue"
    )

    /**
     A Publisher that emits **after** this
     `AuthorizationCodeFlowManager` has changed.
     
     You are discouraged from subscribing to this publisher directly.
     Intead, subscribe to the `authorizationManagerDidChange` publisher
     of `SpotifyAPI`. This allows you to be notified of changes even
     when you create a new instance of this class and assign it to the
     `authorizationManager` instance property of `SpotifyAPI`.
     
     # Thread Safety
     No guarantees are made about which thread this subject will emit on.
     Always receive on the main thread if you plan on updating the UI.
     */
    public let didChange = PassthroughSubject<Void, Never>()
    
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
        
        self.accessToken = codingWrapper.accessToken
        self.refreshToken = codingWrapper.refreshToken
        self.expirationDate = codingWrapper.expirationDate
        self.scopes = codingWrapper.scopes
        
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
        let codingWrapper = updateAuthInfoDispatchQueue.sync {
            AuthInfo(
                accessToken: self.accessToken,
                refreshToken: self.refreshToken,
                expirationDate: self.expirationDate,
                scopes: self.scopes
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
    
    func updateFromAuthInfo(_ authInfo: AuthInfo) {
        updateAuthInfoDispatchQueue.sync {
            self.accessToken = authInfo.accessToken
            if let refreshToken = authInfo.refreshToken {
                self.refreshToken = refreshToken
            }
            self.expirationDate = authInfo.expirationDate
            self.scopes = authInfo.scopes
            
            Self.logger.trace("didChange.send()")
            self.didChange.send()
        }
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
     */
    func deauthorize() {
        updateAuthInfoDispatchQueue.sync {
            self.accessToken = nil
            self.refreshToken = nil
            self.expirationDate = nil
            self.scopes = nil
            self.didChange.send()
        }
    }
    
    /**
     Determines whether the access token is expired
     within the given tolerance.
     
     The access token is refreshed automatically if needed
     before each request to the spotify web API is made.
     Therefore, you should never need to call this method directly.
     
     - Parameter tolerance: The tolerance in seconds.
           Default 120.
     - Returns: `true` if `expirationDate` - `tolerance` is
           equal to or before the current date or if `accessToken`
           is `nil`. Else, `false`.
     */
    func accessTokenIsExpired(tolerance: Double = 120) -> Bool {
        if (accessToken == nil) != (self.expirationDate == nil) {
            let expirationDateString = self.expirationDate?
                    .description(with: .current) ?? "nil"
            Self.logger.critical(
                "accessToken or expirationDate was nil, but not both: " +
                "accessToken == nil: \(accessToken == nil);" +
                "expiration date: \(expirationDateString)"
            )
        }
        guard accessToken != nil else { return true }
        guard let expirationDate = expirationDate else { return true }
        return expirationDate.addingTimeInterval(-tolerance) <= Date()
    }
    
    /**
     Returns `true` if `accessToken` is not `nil` and the application
     is authorized for the specified scopes, else `false`.
     
     - Parameter scopes: A set of [Spotify Authorizaion Scopes][1].
           Use an empty set (default) to check if an `accessToken`
           has been retrieved for the application,
           which is still required for all endpoints,
           even if no scopes are required.
     
     [1]: https://developer.spotify.com/documentation/general/guides/scopes/
     */
    func isAuthorized(for scopes: Set<Scope> = []) -> Bool {
        if accessToken == nil { return false }
        return scopes.isSubset(of: self.scopes ?? [])
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
       - state: Optional, but strongly recommended. The state can be useful for
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
                "show_dialog": "\(showDialog)",
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
     access and refresh tokens. The access token is required in all endpoints,
     even those that do not access user data.
     
     - Parameters:
       - redirectURI: The redirect URI with query parameters appended to it.
       - state: The value of the state parameter that you provided when
             making the authorization URL. **If the state parameter is found**
             **in redirectURIWithQuery and it doesn't match this value,**
             **then an error will be thrown.**
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     
     - Tag: requestAccessAndRefreshTokens-redirectURIWithQuery
     */
    func requestAccessAndRefreshTokens(
        redirectURIWithQuery redirectURI: URL,
        state: String? = nil
    ) -> AnyPublisher<Void, Error> {

        Self.logger.trace(
            "redirectURIWithQuery: '\(redirectURI)'"
        )
        
        let queryDict = redirectURI.queryItemsDict

        // if the code is found in the query,
        // then the user successfully authorized the application.
        // this is required for requesting the access and refresh tokens.
        guard let code = queryDict["code"] else {
            
            if let error = queryDict["error"] {
                Self.logger.warning("redirect uri query has error")
                // this is the way that the authorization should fail
                return SpotifyAuthorizationError(
                    error: error, state: queryDict["state"]
                )
                .anyFailingPublisher(Void.self)
            }
            
            Self.logger.error("unkown error")
            return SpotifyLocalError.other(
                """
                an unknown error occured when handling the redirect URI: \
                (expected to find value for 'code' parameter): \
                '\(redirectURI.absoluteString)'
                """
            )
            .anyFailingPublisher(Void.self)
            
        }
        
        // if the client supplied a state and a state parameter was
        // provided in the query string of the redirect URI,
        // then ensure that they match.
        if let redirectURIstate = queryDict["state"] {
            guard redirectURIstate == state else {
                return SpotifyLocalError.invalidState(
                    supplied: state ?? "nil", received: redirectURIstate
                )
                .anyFailingPublisher(Void.self)
            }
        }
        
        let baseRedirectURI = redirectURI
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
       - onlyIfExpired: Only refresh the token if it is expired.
       - tolerance: The tolerance in seconds to use when determining
             if the token is expired. Defaults to 120. The token is
             considered expired if `expirationDate` - `tolerance` is
             equal to or before the current date. This parameter has
             no effect if `onlyIfExpired` is `false`.
     */
    func refreshTokens(
        onlyIfExpired: Bool,
        tolerance: Double = 120
    ) -> AnyPublisher<Void, Error> {
        
        do {
            
            if onlyIfExpired && !self.accessTokenIsExpired(tolerance: tolerance) {
                Self.logger.trace("access token not expired; returning early")
                return Result<Void, Error>
                    .Publisher(())
                    .eraseToAnyPublisher()
            }
        
            guard let refreshToken = self.refreshToken else {
                Self.logger.warning(
                    "can't refresh access token: no refresh token"
                )
                throw SpotifyLocalError.unauthorized(
                    "can't refresh access token: no refresh token"
                )
                
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
        
            Self.logger.notice("refreshing tokens...")
            
            return URLSession.shared.dataTaskPublisher(
                url: Endpoints.getTokens,
                httpMethod: "POST",
                headers: header,
                body: requestBody
            )
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
            .eraseToAnyPublisher()
        
        } catch {
            return error.anyFailingPublisher(Void.self)
        }
        
    }
    
}

// MARK: - Hashable and Equatable -

extension AuthorizationCodeFlowManager: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(clientId)
        hasher.combine(clientSecret)
        hasher.combine(accessToken)
        hasher.combine(refreshToken)
        hasher.combine(expirationDate)
        hasher.combine(scopes)
    }

    public static func == (
        lhs: AuthorizationCodeFlowManager,
        rhs: AuthorizationCodeFlowManager
    ) -> Bool {
        if lhs.clientId != rhs.clientId ||
                lhs.clientSecret != rhs.clientSecret ||
                lhs.accessToken != rhs.accessToken ||
                lhs.refreshToken != rhs.refreshToken ||
                lhs.scopes != rhs.scopes {
            return false
        }
        return abs(
            (lhs.expirationDate?.timeIntervalSince1970 ?? 0) -
            (rhs.expirationDate?.timeIntervalSince1970 ?? 0)
        ) <= 5
        
        
    }

}

// MARK: - Custom String Convertible

extension AuthorizationCodeFlowManager: CustomStringConvertible {
    
    public var description: String {
        return updateAuthInfoDispatchQueue.sync {
            
            let expirationDateString = expirationDate?
                    .description(with: .autoupdatingCurrent)
                    ?? "nil"
            
            let scopeString = scopes.map({ "\($0.map(\.rawValue))" })
                    ?? "nil"
            
            return """
                AuthorizationCodeFlowManager(
                    access_token: "\(accessToken ?? "nil")"
                    scopes: \(scopeString)
                    expirationDate: \(expirationDateString)
                    refresh_token: "\(refreshToken ?? "nil")"
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
        updateAuthInfoDispatchQueue.sync {
            self.accessToken = UUID().uuidString
            self.refreshToken = UUID().uuidString
            self.expirationDate = Date()
            self.scopes = Set(Scope.allCases.shuffled().prefix(5))
        }
    }
    
    /// Only use for testing purposes.
    static func fromCopy(_ copy: AuthorizationCodeFlowManager) -> Self {
        
        let instance = Self(
            clientId: copy.clientId, clientSecret: copy.clientSecret
        )
        instance.accessToken = copy.accessToken
        instance.refreshToken = copy.refreshToken
        instance.expirationDate = copy.expirationDate
        instance.scopes = copy.scopes

        return instance
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
        updateAuthInfoDispatchQueue.sync {
            Self.logger.notice(
                "mock date: \(date.description(with: .current))"
            )
            self.expirationDate = date
        }
    }
    
}
