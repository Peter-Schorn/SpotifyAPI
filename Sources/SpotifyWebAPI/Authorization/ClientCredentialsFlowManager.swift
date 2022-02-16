import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

/**
 Manages the authorization process for the Client Credentials Flow.
 
 The Client Credentials flow is used in server-to-server authentication. Only
 endpoints that do not access user information can be accessed. This means that
 endpoints that require [authorization scopes][2] cannot be accessed. The
 advantage of this authorization process is that no user interaction is
 required.
 
 **Backend**
 
 This class is generic over a backend. The backend handles the process of
 requesting the authorization information from Spotify. It may do so directly
 (see ``ClientCredentialsFlowClientBackend``), or it may communicate with a
 custom backend server that you configure (see
 ``ClientCredentialsFlowProxyBackend``). This backend server can safely store
 your client id and client secret and retrieve the authorization information
 from Spotify on your behalf, thereby preventing these sensitive credentials
 from being exposed in your frontend app. See ``ClientCredentialsFlowBackend``
 for more information.
 
 **If you do not have a custom backend server, then you are encouraged to use**
 **the concrete subclass of this class,** ``ClientCredentialsFlowManager``
 **instead**. It inherits from
 ``ClientCredentialsFlowBackendManager``<``ClientCredentialsFlowClientBackend``>. This
 class will store your client id and client secret locally.

 **Authorization**

 The only method you must call to authorize your application is ``authorize()``.
 After that, you may begin making requests to the Spotify web API. The access
 token will be refreshed for you automatically when needed.

 Use ``deauthorize()`` to set the ``accessToken`` and ``expirationDate`` to
 `nil`.
 
 **Persistent Storage**

 Note that this type conforms to `Codable`. It is this type that you should
 encode to data using a `JSONEncoder` in order to save the authorization
 information to persistent storage. See
 <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
 information.
 
 Read more about the [Client Credentials Flow][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
 [2]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
 */
public class ClientCredentialsFlowBackendManager<Backend: ClientCredentialsFlowBackend>:
    SpotifyAuthorizationManager,
    CustomStringConvertible
{

    /**
     The logger for this class.
     
     **Note**
     
     This is a computed property which will provide access to the same
     underlying logger for all concrete specializations of this type.
     */
    public static var logger: Logger {
        get {
            return AuthorizationManagerLoggers
                    .clientCredentialsFlowManagerLogger
        }
        set {
            AuthorizationManagerLoggers
                    .clientCredentialsFlowManagerLogger = newValue
        }
    }

    /**
     A type that handles the process of requesting the authorization
     information.
     
     The backend handles the process of requesting the authorization information
     from Spotify. It may do so directly (see
     ``ClientCredentialsFlowClientBackend``), or it may communicate with a
     custom backend server that you configure (see
     ``ClientCredentialsFlowProxyBackend``). This backend server can safely
     store your client id and client secret and retrieve the authorization
     information from Spotify on your behalf, thereby preventing these sensitive
     credentials from being exposed in your frontend app. See
     ``ClientCredentialsFlowBackend`` for more information.
     
     - Warning: Do not mutate this property when a request to retrieve
           authorization information is in progress. Doing so is *not* thread
           safe.
     */
    public var backend: Backend

    /// The Spotify authorization scopes. **Always** an empty set because the
    /// client credentials flow does not support authorization scopes.
    public let scopes: Set<Scope> = []
    
    /**
     The access token used in all of the requests to the Spotify web API.
     
     **Thread Safety**
     
     Access to this property is synchronized; therefore, it is always
     thread-safe.
     */
    public var accessToken: String? {
        return self.updateAuthInfoQueue.sync {
            self._accessToken
        }
    }
    var _accessToken: String?
    
    /**
     The expiration date of the access token.
    
     You are encouraged to use ``accessTokenIsExpired(tolerance:)`` to check if
     the token is expired.

     **Thread Safety**

     Access to this property is synchronized; therefore, it is always
     thread-safe.
     */
    public var expirationDate: Date? {
        return self.updateAuthInfoQueue.sync {
            self._expirationDate
        }
    }
    var _expirationDate: Date?
    
    /**
     A publisher that emits after the authorization information changes.
     
     **You are discouraged from subscribing to this publisher directly.**
     
     Instead, subscribe to the ``SpotifyAPI/authorizationManagerDidChange``
     publisher of ``SpotifyAPI``. This allows you to be notified of changes even
     when you create a new instance of this class and assign it to the
     ``SpotifyAPI/authorizationManager`` instance property of ``SpotifyAPI``.

     Emits after the following events occur:
     * After an access token is retrieved using the ``authorize()`` method.
     * After a new access token is retrieved using
       ``refreshTokens(onlyIfExpired:tolerance:)``.

     See also ``didDeauthorize``, which emits after ``deauthorize()`` is called.
     Subscribe to that publisher in order to remove the authorization
     information from persistent storage when it emits.
     
     **Thread Safety**
     
     No guarantees are made about which thread this publisher will emit on.
     */
    public let didChange = PassthroughSubject<Void, Never>()
    
    /**
     A publisher that emits after ``deauthorize()`` is called.
     
     **You are discouraged from subscribing to this publisher directly.**
     
     Instead, subscribe to the ``SpotifyAPI/authorizationManagerDidDeauthorize``
     publisher of ``SpotifyAPI``. This allows you to be notified even when you
     create a new instance of this class and assign it to the
     ``SpotifyAPI/authorizationManager`` instance property of ``SpotifyAPI``.
     ``deauthorize()`` sets the access token and expiration date to `nil`.

     Subscribe to this publisher in order to remove the authorization
     information from persistent storage when it emits.
     
     See also ``didChange``.
     
     **Thread Safety**
     
     No guarantees are made about which thread this publisher will emit on.
     */
    public let didDeauthorize = PassthroughSubject<Void, Never>()
    
    /// Ensure no data races occur when updating auth info.
    let updateAuthInfoQueue = DispatchQueue(
        label: "SpotifyAPI.ClientCredentialsFlowBackendManager.updateAuthInfo"
    )

    /**
     The request to refresh the access token is stored in this property so that
     if multiple asynchronous requests are made to refresh the access token,
     then only one actual network request is made. Once this publisher finishes,
     it is set to `nil`.
     */
    private var refreshTokensPublisher: AnyPublisher<Void, Error>? = nil
    
    private let refreshTokensQueue = DispatchQueue(
        label: "SpotifyAPI.ClientCredentialsFlowBackendManager. refreshTokens"
    )

    // MARK: - Initializers

    /**
     Creates an authorization manager for the Client Credentials Flow.
     
     Remember, with this authorization flow, only endpoints that do not access
     user information can be accessed. This means that endpoints that require
     [authorization scopes][2] cannot be accessed.
     
     **If you do not have a custom backend server, then you are encouraged to**
     **use the concrete subclass of this class,** ``ClientCredentialsFlowManager``
     **instead**. It inherits from
     ``ClientCredentialsFlowBackendManager``<``ClientCredentialsFlowClientBackend``>.
     This class will store your client id and client secret locally.

     Note that this type conforms to `Codable`. It is this type that you should
     encode to data using a `JSONEncoder` in order to save the authorization
     information to persistent storage. See
     <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
     information.
     
     Read more about the [Client Credentials Flow][1].

     - Parameters:
       - backend: A type that handles the process of requesting the
             authorization information from Spotify. It may do so directly (see
             ``ClientCredentialsFlowClientBackend``), or it may communicate with
             a custom backend server that you configure (see
             ``ClientCredentialsFlowProxyBackend``). See
             ``ClientCredentialsFlowBackend`` for more information.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
     [2]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     [3]: https://developer.spotify.com/dashboard/login
     [5]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public init(backend: Backend) {
        self.backend = backend
    }
    
    /**
     Creates an authorization manager for the Client Credentials Flow.
     
     Remember, with this authorization flow, only endpoints that do not access
     user information can be accessed. This means that endpoints that require
     [authorization scopes][2] cannot be accessed.

     **In general, only use this initializer if you have retrieved the**
     **authorization information from an external source.** Otherwise, use
     ``init(backend:)``.
     
     **If you do not have a custom backend server, then you are encouraged to**
     **use the concrete subclass of this class,** ``ClientCredentialsFlowManager``
     **instead**. It inherits from
     ``ClientCredentialsFlowBackendManager``<``ClientCredentialsFlowClientBackend``>.
     This class will store your client id and client secret locally.
    
     You are discouraged from individually saving the properties of this
     instance to persistent storage and then retrieving them later and passing
     them into this initializer. Instead, encode this entire instance to data
     using a `JSONEncoder` and then decode the data from storage later. See
     <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
     information.
     
     Read more about the [Client Credentials Flow][1].
     
     - Parameters:
       - backend: A type that handles the process of requesting the
             authorization information from Spotify. It may do so directly (see
             ``ClientCredentialsFlowClientBackend``), or it may communicate with
             a custom backend server that you configure (see
             ``ClientCredentialsFlowProxyBackend``). See
             ``ClientCredentialsFlowBackend`` for more information.
       - accessToken: The access token.
       - expirationDate: The expiration date of the access token.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
     [2]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     [3]: https://developer.spotify.com/dashboard/login
     [4]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public convenience init(
        backend: Backend,
        accessToken: String,
        expirationDate: Date
    ) {
        self.init(backend: backend)
        self._accessToken = accessToken
        self._expirationDate = expirationDate
    }

    // MARK: - Codable, Hashable, CustomStringConvertible

    public required init(from decoder: Decoder) throws {
        
        let codingWrapper = try AuthInfo(from: decoder)
        
        let container = try decoder.container(
            keyedBy: AuthInfo.CodingKeys.self
        )
        self.backend = try container.decode(
            Backend.self, forKey: .backend
        )
        self._accessToken = codingWrapper.accessToken
        self._expirationDate = codingWrapper.expirationDate
    }
    
    public func encode(to encoder: Encoder) throws {
        
        let codingWrapper = self.updateAuthInfoQueue.sync {
            AuthInfo(
                accessToken: self._accessToken,
                refreshToken: nil,
                expirationDate: self._expirationDate,
                scopes: []
            )
        }
        
        var container = encoder.container(
            keyedBy: AuthInfo.CodingKeys.self
        )
        try container.encode(self.backend, forKey: .backend)
        try codingWrapper.encode(to: encoder)
        
    }
 
    /// :nodoc:
    public func hash(into hasher: inout Hasher) {
        self.updateAuthInfoQueue.sync {
            hasher.combine(self.backend)
            hasher.combine(self._accessToken)
            hasher.combine(self._expirationDate)
        }
    }
    
    /// :nodoc:
    public static func == (
        lhs: ClientCredentialsFlowBackendManager,
        rhs: ClientCredentialsFlowBackendManager
    ) -> Bool {
        
        let (lhsAccessToken, lhsExpirationDate) =
            lhs.updateAuthInfoQueue.sync {
                return (lhs._accessToken, lhs._expirationDate)
            }
        
        let (rhsAccessToken, rhsExpirationDate) =
            rhs.updateAuthInfoQueue.sync {
                return (rhs._accessToken, rhs._expirationDate)
            }
        
        return lhs.backend == rhs.backend &&
            lhsAccessToken == rhsAccessToken &&
            lhsExpirationDate.isApproximatelyEqual(to: rhsExpirationDate)
        
    }

    /**
     Returns a copy of self.
     
     Copies the following properties:
     * ``backend``
     * ``accessToken``
     * ``expirationDate``
     */
    public func makeCopy() -> ClientCredentialsFlowBackendManager<Backend> {
        let copy = ClientCredentialsFlowBackendManager(
            backend: backend
        )
        return self.updateAuthInfoQueue.sync {
            copy._accessToken = self._accessToken
            copy._expirationDate = self._expirationDate
            return copy
        }
    }
 
    public var description: String {
        // print("ClientCredentialsFlowBackendManager.description: WAITING for queue")
        return self.updateAuthInfoQueue.sync {
            // print("ClientCredentialsFlowBackendManager.description: INSIDE queue")
            let expirationDateString = self._expirationDate?
                .description(with: .current) ?? "nil"
        
            return """
                ClientCredentialsFlowBackendManager(
                    access token: \(self._accessToken.quotedOrNil())
                    expiration date: \(expirationDateString)
                    backend: \("\(self.backend)".indented(tabEquivalents: 1))
                )
                """
        
        }
    }

}

public extension ClientCredentialsFlowBackendManager {
    
    // MARK: - Authorization
    
    /**
     Sets ``accessToken`` and ``expirationDate`` to `nil`.

     After calling this method, you must authorize your application again before
     accessing any of the Spotify web API endpoints.

     If this instance is stored in persistent storage, consider removing it
     after calling this method.

     Calling this method causes ``didDeauthorize`` to emit a signal, which will
     also cause the ``SpotifyAPI/authorizationManagerDidDeauthorize`` publisher
     of ``SpotifyAPI`` to emit a signal.
     
     **Thread Safety**
     
     This method is thread-safe.
     */
    func deauthorize() {
        self.updateAuthInfoQueue.sync {
            self._accessToken = nil
            self._expirationDate = nil
            self.refreshTokensPublisher = nil
        }
        Self.logger.trace("self.didDeauthorize.send()")
        self.didDeauthorize.send()
            
    }
    
    /**
     Determines whether the access token is expired within the given tolerance.

     See also ``isAuthorized(for:)``.

     The access token is refreshed automatically when necessary before each
     request to the Spotify web API is made. Therefore, **you should never**
     **need to call this method directly.**
     
     - Parameter tolerance: The tolerance in seconds.
           Default 120.
     - Returns: `true` if ``expirationDate`` - `tolerance` is
           equal to or before the current date or if ``accessToken``
           is `nil`. Else, `false`.
     
     **Thread Safety**
     
     This method is thread-safe.
     */
    func accessTokenIsExpired(tolerance: Double = 120) -> Bool {
        return self.updateAuthInfoQueue.sync {
            return self.accessTokenIsExpiredNOTThreadSafe(tolerance: tolerance)
        }
    }
    
    /**
     Returns `true` if ``accessToken`` is not `nil` and the set of scopes is
     empty.
     
     - Parameter scopes: A set of [Spotify Authorization Scopes][1]. This must be
           an empty set, or this method will return `false` because the client
           credentials flow does not support authorization scopes; it only
           supports endpoints that do not access user data.
     
     **Thread Safety**
     
     This method is thread-safe.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     */
    func isAuthorized(for scopes: Set<Scope> = []) -> Bool {
        return self.updateAuthInfoQueue.sync {
            return self._accessToken != nil && scopes.isEmpty
        }
    }
    
    /**
     Authorizes the application for the Client Credentials Flow.
     
     This is the only method you need to call to authorize your application.
     After this publisher finishes normally, you can begin making requests to
     the Spotify web API. The access token will be automatically refreshed for
     you.

     If the authorization request succeeds, then ``didChange`` will emit a
     signal, causing ``SpotifyAPI/authorizationManagerDidChange`` to emit a
     signal.
     
     Read more at the [Spotify web API reference][1].

     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/#request-authorization
     */
    func authorize() -> AnyPublisher<Void, Error> {
        
        Self.logger.trace("backend.makeClientCredentialsTokensRequest")

        return self.backend.makeClientCredentialsTokensRequest()
            .decodeSpotifyObject(AuthInfo.self)
            .receive(on: self.updateAuthInfoQueue)
            .tryMap { authInfo in
                
                Self.logger.trace("received authInfo:\n\(authInfo)")
                
                if authInfo.accessToken == nil ||
                        authInfo.expirationDate == nil {
                    
                    let errorMessage = """
                        missing properties after requesting access token \
                        (expected access token and expiration date):
                        \(authInfo)
                        """
                    Self.logger.error("\(errorMessage)")
                    throw SpotifyGeneralError.other(errorMessage)
                }
                
                self.updateFromAuthInfo(authInfo)
                
            }
            .handleEvents(
                // once this publisher finishes, we must
                // set `self.refreshTokensPublisher` to `nil`
                // so that the caller does not receive a publisher
                // that has already finished.
                receiveCompletion: { _ in
                    Self.logger.trace(
                        """
                        refreshTokensPublisher received completion; \
                        setting to nil
                        """
                    )
                    self.refreshTokensPublisher = nil
                }
            )
            .receive(on: self.refreshTokensQueue)
            .eraseToAnyPublisher()

    }
    
    /**
     Retrieves a new access token.
    
     **You shouldn't need to call this method**. It gets called automatically
     each time you make a request to the Spotify web API.
     
     The [Client Credentials Flow][1] does not provide a refresh token, so
     calling this method and passing in `false` for `onlyIfExpired` is
     equivalent to calling ``authorize()``.

     If a new access token is successfully retrieved, then ``didChange`` will
     emit a signal, which causes ``SpotifyAPI/authorizationManagerDidChange`` to
     emit a signal.
     
     **Thread Safety**
     
     Calling this method is thread-safe. If a network request to refresh the
     tokens is already in progress, additional calls will return a reference to
     the same publisher.

     **However**, No guarantees are made about the thread that the publisher
     returned by this method will emit on.

     - Parameters:
       - onlyIfExpired: Only retrieve a new access token if the current one is
             expired.
       - tolerance: The tolerance in seconds to use when determining if the
             token is expired. Defaults to 120, meaning that a new token will be
             retrieved if the current one has expired or will expire in the next
             two minutes. The token is considered expired if ``expirationDate``
             - `tolerance` is equal to or before the current date. This
             parameter has no effect if `onlyIfExpired` is `false`.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
     */
    func refreshTokens(
        onlyIfExpired: Bool,
        tolerance: Double = 120
    ) -> AnyPublisher<Void, Error> {
        
        return self.updateAuthInfoQueue
            .sync { () -> AnyPublisher<Void, Error> in
                
                if onlyIfExpired && !self.accessTokenIsExpiredNOTThreadSafe(
                    tolerance: tolerance
                ) {
                    Self.logger.trace("access token not expired; returning early")
                    return ResultPublisher(())
                        .eraseToAnyPublisher()
                }
                
                Self.logger.trace("access token is expired; authorizing again")
                
                // If another request to refresh the tokens is currently in
                // progress, return the same request instead of creating a new
                // network request.
                if let publisher = self.refreshTokensPublisher {
                    Self.logger.trace("using previous publisher")
                    return publisher
                }
                
                Self.logger.trace("creating new publisher")
                
                // The process for refreshing the token is the same as that for
                // authorizing the application. The client credentials flow does
                // not return a refresh token, unlike the authorization code
                // flow.
                let refreshTokensPublisher = self.authorize()
                    .share()
                    .eraseToAnyPublisher()
                
                self.refreshTokensPublisher = refreshTokensPublisher
                return refreshTokensPublisher
                
            }
    }
    
}


extension ClientCredentialsFlowBackendManager {
    
    // MARK: - Internal
    
    /// Used internally by this library. Do not call this method directly.
    public func _assertNotOnUpdateAuthInfoDispatchQueue() {
        #if DEBUG
        dispatchPrecondition(
            condition: .notOnQueue(self.updateAuthInfoQueue)
        )
        #endif
    }
    
}

private extension ClientCredentialsFlowBackendManager {
    
    // MARK: - Private

    func updateFromAuthInfo(_ authInfo: AuthInfo) {
        self._accessToken = authInfo.accessToken
        self._expirationDate = authInfo.expirationDate
        self.refreshTokensPublisher = nil
        self.refreshTokensQueue.async {
            Self.logger.trace("self.didChange.send()")
            self.didChange.send()
        }
    }
    
    /// This method should **ALWAYS** be called within
    /// ``updateAuthInfoDispatchQueue``.
    func accessTokenIsExpiredNOTThreadSafe(tolerance: Double = 120) -> Bool {
        if (self._accessToken == nil) != (self._expirationDate == nil) {
            let expirationDateString = self._expirationDate?
                .description(with: .current) ?? "nil"
            Self.logger.error(
                """
                accessToken or expirationDate was nil, but not both:
                accessToken == nil: \(_accessToken == nil); \
                expiration date: \(expirationDateString)
                """
            )
        }
        if self._accessToken == nil { return true }
        guard let expirationDate = self._expirationDate else { return true }
        return expirationDate.addingTimeInterval(-tolerance) <= Date()
    }
    
}

extension ClientCredentialsFlowBackendManager {
    
    // MARK: - Testing
    
    /// This method sets random values for various properties for testing
    /// purposes. Do not call it outside of test cases.
    func mockValues() {
        self.updateAuthInfoQueue.sync {
            self._expirationDate = Date()
            self._accessToken = UUID().uuidString
        }
    }
    
    /**
     Sets the expiration date of the access token to the specified date.
     **Only use for testing purposes**.
     
     - Parameter date: The date to set the expiration date to.
     */
    public func setExpirationDate(to date: Date) {
        self.updateAuthInfoQueue.sync {
            Self.logger.notice(
                "mock expiration date: \(date.description(with: .current))"
            )
            self._expirationDate = date
        }
    }
    
}

// MARK: - ClientCredentialsFlowManager -

/**
 Manages the authorization process for the Client Credentials Flow.

 The Client Credentials flow is used in server-to-server authentication. Only
 endpoints that do not access user information can be accessed. This means that
 endpoints that require [authorization scopes][2] cannot be accessed. The
 advantage of this authorization process is that no user interaction is
 required.

 This class stores the client id and client secret locally. Consider using
 ``ClientCredentialsFlowBackendManager``<``ClientCredentialsFlowProxyBackend``>,
 which allows you to setup a custom backend server that can store these
 sensitive credentials and which communicates with Spotify on your behalf in
 order to retrieve the authorization information.

 **Authorization**

 The only method you must call to authorize your application is
 ``ClientCredentialsFlowBackendManager/authorize()``. After that, you may begin
 making requests to the Spotify web API. The access token will be refreshed for
 you automatically when needed.
 
 Use ``ClientCredentialsFlowBackendManager/deauthorize()`` to set the
 ``ClientCredentialsFlowBackendManager/accessToken`` and
 ``ClientCredentialsFlowBackendManager/expirationDate`` to `nil`. Does not
 change ``clientId`` or ``clientSecret``, which are immutable.

 **Persistent Storage**

 Note that this type conforms to `Codable`. It is this type that you should
 encode to data using a `JSONEncoder` in order to save the authorization
 information to persistent storage. See
 <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
 information.
 
 Read more about the [Client Credentials Flow][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
 [2]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
 */
public final class ClientCredentialsFlowManager:
    ClientCredentialsFlowBackendManager<ClientCredentialsFlowClientBackend>
{
    
    /**
     The client id that you received when you registered your application.
     
     Read more about [registering your application][1].

     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public var clientId: String {
        return self.backend.clientId
    }
    
    /**
     The client secret that you received when you registered your
     application.
     
     Read more about [registering your application][1].

     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public var clientSecret: String {
        return self.backend.clientSecret
    }
    
    /**
     Creates an authorization manager for the Client Credentials Flow.

     Remember, with this authorization flow, only endpoints that do not access
     user information can be accessed. This means that endpoints that require
     [authorization scopes][2] cannot be accessed.

     To get a client id and client secret, go to the [Spotify Developer
     Dashboard][3] and create an app. see the README in the root directory of
     this package for more information.

     Note that this type conforms to `Codable`. It is this type that you should
     encode to data using a `JSONEncoder` in order to save the authorization
     information to persistent storage. See
     <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
     information.
     
     Read more about the [Client Credentials Flow][1].

     - Parameters:
       - clientId: The client id that you received when you [registered your
             application][5].
       - clientSecret: The client secret that you received when you [registered
             your application][5].

     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
     [2]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     [3]: https://developer.spotify.com/dashboard/login
     [5]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public convenience init(
        clientId: String,
        clientSecret: String
    ) {
        let backend = ClientCredentialsFlowClientBackend(
            clientId: clientId,
            clientSecret: clientSecret
        )
        self.init(backend: backend)
    }
    
    /**
     Creates an authorization manager for the Client Credentials Flow.
     
     **In general, only use this initializer if you have retrieved the**
     **authorization information from an external source.** Otherwise, use
     ``init(clientId:clientSecret:)``.
    
     Remember, with this authorization flow, only endpoints that do not access
     user information can be accessed. This means that endpoints that require
     [authorization scopes][2] cannot be accessed.

     You are discouraged from individually saving the properties of this
     instance to persistent storage and then retrieving them later and passing
     them into this initializer. Instead, encode this entire instance to data
     using a `JSONEncoder` and then decode the data from storage later. See
     <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
     information.
     
     To get a client id and client secret, go to the [Spotify Developer
     Dashboard][3] and create an app. see the README in the root directory of
     this package for more information.
     
     Read more about the [Client Credentials Flow][1].

     - Parameters:
       - clientId: The client id that you received when you [registered your
             application][4].
       - clientSecret: The client secret that you received when you [registered
             your application][4].
       - accessToken: The access token.
       - expirationDate: The expiration date of the access token.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
     [2]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     [3]: https://developer.spotify.com/dashboard/login
     [4]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public convenience init(
        clientId: String,
        clientSecret: String,
        accessToken: String,
        expirationDate: Date
    ) {

        self.init(
            clientId: clientId,
            clientSecret: clientSecret
        )
        self._accessToken = accessToken
        self._expirationDate = expirationDate
        
    }

    /// A textual representation of this instance.
    public override var description: String {
        return self.updateAuthInfoQueue.sync {
            let expirationDateString = self._expirationDate?
                .description(with: .current) ?? "nil"
        
            return """
                ClientCredentialsFlowManager(
                    access token: \(self._accessToken.quotedOrNil())
                    expiration date: \(expirationDateString)
                    clientId: "\(self.clientId)"
                    clientSecret: "\(self.clientSecret)"
                )
                """
        
        }
    }

}
