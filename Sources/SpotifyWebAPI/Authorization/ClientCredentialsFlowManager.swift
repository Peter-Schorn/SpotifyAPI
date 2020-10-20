import Foundation
import Combine
import Logging


/**
 Manages the authorization proccess for the [Client Credentials Flow][1].

 The Client Credentials flow is used in server-to-server authentication. Only
 endpoints that do not access user information can be accessed. This means that
 endpoints that require [authorization scopes][2] cannot be accessed.
 
 The only method you must call to authorize your application is `authorize()`.
 After that, you may begin making requests to the Soptify web API.

 The advantage of this authorization proccess is that no user interaction is
 required.
 
 Note that this type conforms to `Codable`. It is this type that you should
 encode to data using a `JSONEncoder` in order to save it to persistent storage.
 See this [article][3] for more information.
 
 Contains the following properties:
 
 * The client id
 * The client secret
 * The access token
 * The expiration date of the access token
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
 [2]: https://developer.spotify.com/documentation/general/guides/scopes/
 [3]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
 */
public final class ClientCredentialsFlowManager: SpotifyAuthorizationManager {
    
    /// The logger for this class. By default, its level is `critical`.
    public static var logger = Logger(
        label: "ClientCredentialsFlowManager", level: .critical
    )
    
    /// The client id for your application.
    public let clientId: String
    
    /// The client secret for your application.
    public let clientSecret: String
    
    /// The Spotify authorization scopes. **Always** an empty set
    /// because the client credentials flow does not support
    /// authorization scopes.
    public let scopes: Set<Scope>? = []
    
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
    private var _accessToken: String?
    
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
    private var _expirationDate: Date?
    
    /**
     A Publisher that emits **after** this `ClientCredentialsFlowManager`
     has changed.
     
     **You are discouraged from subscribing to this publisher directly.**
     
     Instead, subscribe to the `SpotifyAPI.authorizationManagerDidChange`
     publisher. This allows you to be notified of changes even
     when you create a new instance of this class and assign it to the
     `authorizationManager` instance property of `SpotifyAPI`.
     
     Emits after the following events occur:
     * After the access token is retrieved using the `authorize()` method.
     * After a new access token is retrieved. This occurs in
       `refreshTokens(onlyIfExpired:tolerance:)`.
     * After `deauthorize()`—which sets `accessToken` and `expirationDate`
       to `nil`—is called.
     
     # Thread Safety
     
     No guarantees are made about which thread this subject will emit on.
     Always receive on the main thread if you plan on updating the UI.
     */
    public let didChange = PassthroughSubject<Void, Never>()
    
    /// Ensure no data races occur when updating auth info.
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
     Creates an authorization manager for the [Client Credentials Flow][1].
     
     Remember, with this authorization flow, only endpoints that do not
     access user information can be accessed. This means that endpoints
     that require [authorization scopes][2] cannot be accessed.
     
     To get a client id and client secret, go to the
     [Spotify Developer Dashboard][3] and create an app.
     see the README in the root directory of this package for more information.

     Note that this type conforms to `Codable`. It is this type that you should
     encode to data using a `JSONEncoder` in order to save it to persistent storage.
     See this [article][4] for more information.
     
     - Parameters:
       - clientId: The client id for your application.
       - clientSecret: The client secret for your application.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
     [2]: https://developer.spotify.com/documentation/general/guides/scopes/
     [3]: https://developer.spotify.com/dashboard/login
     [4]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
     */
    public init(
        clientId: String,
        clientSecret: String
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }

    // MARK: - Codable -

    public init(from decoder: Decoder) throws {
        
        let codingWrapper = try AuthInfo(from: decoder)
        
        self._accessToken = codingWrapper.accessToken
        self._expirationDate = codingWrapper.expirationDate
        
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
            AuthInfo(
                accessToken: self._accessToken,
                refreshToken: nil,
                expirationDate: self._expirationDate,
                scopes: nil
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

public extension ClientCredentialsFlowManager {
    
    // MARK: - Authorization -
    
    /**
     Sets `accessToken` and `expirationDate` to `nil`.
     Does not change `clientId` or `clientSecret`, which are immutable.

     After calling this method, you must authorize your application
     again before accessing any of the Spotify web API endpoints.
     
     If this instance is stored in persistent storage, consider
     removing it after calling this method.
     
     Calling this method causes `self.didChange` to emit a signal, which will
     cause `SpotifyAPI.authorizationManagerDidChange` to emit a signal.
     
     # Thread Safety
     
     This method is thread-safe.
     */
    func deauthorize() {
        self.updateAuthInfoDispatchQueue.sync {
            self._accessToken = nil
            self._expirationDate = nil
            self.refreshTokensPublisher = nil
        }
        self.didChange.send()
    }
    
    /**
     Determines whether the access token is expired
     within the given tolerance.
     
     See also `isAuthorized(for:)`.
     
     The access token is refreshed automatically when necessary
     before each request to the Spotify web API is made.
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
            return self.accessTokenIsExpiredNOTTHreadSafe(tolerance: tolerance)
        }
    }
    
    /**
     Returns `true` if `accessToken` is not `nil` and
     the set of scopes is empty.
     
     - Parameter scopes: A set of [Spotify Authorizaion Scopes][1].
           This must be an empty set, or this method will return `false`
           because the client credentials flow does not support
           authorization scopes; it only supports endpoints that do not
           access user data.
     
     # Thread Safety
     
     This method is thread-safe.
     
     [1]: https://developer.spotify.com/documentation/general/guides/scopes/
     */
    func isAuthorized(for scopes: Set<Scope> = []) -> Bool {
        return self.updateAuthInfoDispatchQueue.sync {
            if self._accessToken == nil { return false }
            return scopes.isEmpty
        }
    }
    
    /**
     Authorizes the application for the [Client Credentials Flow][1].
     
     This is the only method you need to call to authorize your application.
     After this publisher completes successfully, you can begin making
     requests to the Spotify web API.
     
     If the authorization request succeeds, then `self.didChange` will emit
     a signal, causing `SpotifyAPI.authorizationManagerDidChange` to emit
     a signal.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
     */
    func authorize() -> AnyPublisher<Void, Error> {
        
        let body = [
            "grant_type": "client_credentials"
        ].formURLEncoded()!

        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
    
        Self.logger.trace(
            """
            authorizing: POST request to "\(Endpoints.getTokens)"; body:
            \(bodyString)
            """
        )
        
        guard let headers = Headers.basicBase64Encoded(
            clientId: self.clientId, clientSecret: self.clientSecret
        )
        else {
            // this error should never occur
            let message = "couldn't base 64 encode " +
                "client id and client secret"
            Self.logger.critical("\(message)")
            return SpotifyLocalError.other(message)
                .anyFailingPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(
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
                    authInfo.expirationDate == nil {
                
                let errorMessage = """
                    missing properties after requesting access token \
                    (expected access token and expiration date):
                    \(authInfo)
                    """
                Self.logger.critical("\(errorMessage)")
                throw SpotifyLocalError.other(errorMessage)
            }
            
            self.updateFromAuthInfo(authInfo)
            
        }
        .eraseToAnyPublisher()
        
    }
    
    /**
     Retrieves a new access token.
    
     **You shouldn't need to call this method**. It gets
     called automatically each time you make a request to the
     Spotify web API.
     
     The [Client Credentials Flow][1] does not provide a refresh token,
     so calling this method and passing in `false` for `onlyIfExpired`
     is equivalent to calling `authorize`.
     
     If a new access token is successfully retrieved, then `self.didChange`
     will emit a signal, which causes `SpotifyAPI.authorizationManagerDidChange`
     to emit a signal.
     
     - Parameters:
       - onlyIfExpired: Only retrieve a new access token if the current
             one is expired.
       - tolerance: The tolerance in seconds to use when determining
             if the token is expired. Defaults to 120, meaning that
             a new token will be retrieved if the current one has expired
             or will expire in the next two minutes. The token is
             considered expired if `expirationDate` - `tolerance` is
             equal to or before the current date. This parameter has
             no effect if `onlyIfExpired` is `false`.
     
     # Thread Safety
     
     Calling this method is thread-safe. If a network request to refresh the tokens
     is already in progress, additional calls will return a reference to the same
     publisher as a class instance.
     
     **However**, no guarentees are made about the thread that the publisher
     returned by this method will emit on.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
     */
    func refreshTokens(
        onlyIfExpired: Bool,
        tolerance: Double = 120
    ) -> AnyPublisher<Void, Error> {
        
        return updateAuthInfoDispatchQueue
            .sync { () -> AnyPublisher<Void, Error> in
                
                if onlyIfExpired && !self.accessTokenIsExpiredNOTTHreadSafe(
                    tolerance: tolerance
                ) {
                    Self.logger.trace("access token not expired; returning early")
                    return Result<Void, Error>
                        .Publisher(())
                        .eraseToAnyPublisher()
                }
                
                Self.logger.trace("access token is expired; authorizing again")
                
                // If another request to refresh the tokens is currently
                // in progress, return the same request instead of creating
                // a new network request.
                if let publisher = self.refreshTokensPublisher {
                    Self.logger.trace("using previous publisher")
                    return publisher
                }
                
                Self.logger.trace("creating new publisher")
                
                // The process for refreshing the token is the same as that
                // for authorizing the application. The client credentials flow
                // does not return a refresh token, unlike the authorization code
                // flow.
                let refreshTokensPublisher = self.authorize()
                    .handleEvents(
                        // once this publisher finishes, we must
                        // set `self.refreshTokensPublisher` to `nil`
                        // so that the caller does not receive a publisher
                        // that has already finished.
                        receiveCompletion: { _ in
                            self.updateAuthInfoDispatchQueue.sync {
                                Self.logger.trace(
                                    """
                                    refreshTokensPublisher received completion; \
                                    setting to nil"
                                    """
                                )
                                self.refreshTokensPublisher = nil
                            }
                        }
                    )
                    .share()
                    .eraseToAnyPublisher()
                
                self.refreshTokensPublisher = refreshTokensPublisher
                return refreshTokensPublisher
                
            }
    }
    
    
}

private extension ClientCredentialsFlowManager {
    
    func updateFromAuthInfo(_ authInfo: AuthInfo) {
        self.updateAuthInfoDispatchQueue.sync {
            self._accessToken = authInfo.accessToken
            self._expirationDate = authInfo.expirationDate
            self.refreshTokensPublisher = nil
        }
        self.didChange.send()
        Self.logger.trace("self.didChange.send()")
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

extension ClientCredentialsFlowManager {
    
    func assertNotOnUpdateAuthInfoDispatchQueue() {
        dispatchPrecondition(
            condition: .notOnQueue(self.updateAuthInfoDispatchQueue)
        )
    }

}

// MARK: - Hashable and Equatable -

extension ClientCredentialsFlowManager: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        self.updateAuthInfoDispatchQueue.sync {
            hasher.combine(clientId)
            hasher.combine(clientSecret)
            hasher.combine(_accessToken)
            hasher.combine(_expirationDate)
        }
    }
    
    public static func == (
        lhs: ClientCredentialsFlowManager,
        rhs: ClientCredentialsFlowManager
    ) -> Bool {
        
        let (lhsAccessToken, lhsExpirationDate) =
                lhs.updateAuthInfoDispatchQueue.sync {
            return (lhs._accessToken, lhs._expirationDate)
        }
        
        let (rhsAccessToken, rhsExpirationDate) =
                rhs.updateAuthInfoDispatchQueue.sync {
            return (rhs._accessToken, rhs._expirationDate)
        }
       
        if lhs.clientId != rhs.clientId ||
                lhs.clientSecret != rhs.clientSecret ||
                lhsAccessToken != rhsAccessToken {
            return false
        }
        
        return abs(
            (lhsExpirationDate?.timeIntervalSince1970 ?? 0) -
                (rhsExpirationDate?.timeIntervalSince1970 ?? 0)
        ) <= 3
        
    }
    
}

// MARK: - Custom String Convertible

extension ClientCredentialsFlowManager: CustomStringConvertible {
    
    public var description: String {
        // print("ClientCredentialsFlowManager.description: WAITING for queue")
        return self.updateAuthInfoDispatchQueue.sync {
            // print("ClientCredentialsFlowManager.description: INSIDE queue")
            let expirationDateString = _expirationDate?
                .description(with: .autoupdatingCurrent)
                ?? "nil"
        
            return """
                ClientCredentialsFlowManager(
                    access_token: "\(_accessToken ?? "nil")"
                    expirationDate: \(expirationDateString)
                    client id: "\(clientId)"
                    client secret: "\(clientSecret)"
                )
                """
        
        }
    }

}

// MARK: - Testing -

extension ClientCredentialsFlowManager {
    
    /// This method sets random values for various properties
    /// for testing purposes. Do not call it outside of test cases.
    func mockValues() {
        self.updateAuthInfoDispatchQueue.sync {
            self._expirationDate = Date()
            self._accessToken = UUID().uuidString
        }
    }
    
    /// Only use for testing purposes.
    func makeCopy() -> Self {
        let instance = Self(
            clientId: self.clientId, clientSecret: self.clientSecret
        )
        return self.updateAuthInfoDispatchQueue.sync {
            instance._accessToken = self._accessToken
            instance._expirationDate = self._expirationDate
            return instance
        }
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
