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
 The base class for functionality shared between
 ``AuthorizationCodeFlowBackendManager`` and
``AuthorizationCodeFlowPKCEBackendManager``.

 You cannot—and should not—create an instance of this class. Instead, you create
 an instance of one of the sub-classes above.

 Use ``isAuthorized(for:)`` to check if your application is authorized for the
 specified scopes.

 Use ``deauthorize()`` to set the ``accessToken``, ``refreshToken``,
 ``expirationDate``, and ``scopes`` to `nil`.
 */
public class AuthorizationCodeFlowManagerBase<Backend: Codable & Hashable> {
    
    /// The logger for this class. Sub-classes will not use this logger;
    /// instead, they will create their own logger.
    public static var baseLogger: Logger {
        get {
            return AuthorizationManagerLoggers
                    .authorizationCodeFlowManagerBaseLogger
        }
        set {
            AuthorizationManagerLoggers
                    .authorizationCodeFlowManagerBaseLogger = newValue
        }
    }

    /**
     A type that handles the process of requesting the authorization
     information.

     The backend handles the process of requesting the authorization information
     from Spotify. It may do so directly or it may communicate with a custom
     backend server that you configure This backend server can safely store your
     client id and client secret and retrieve the authorization information from
     Spotify on your behalf, thereby preventing these sensitive credentials from
     being exposed in your frontend app. See ``AuthorizationCodeFlowBackend``
     and ``AuthorizationCodeFlowPKCEBackend`` for more information.
     
     - Warning: Do not mutate this property when a request to retrieve
           authorization information is in progress. Doing so is *not* thread
           safe.
     */
    public var backend: Backend

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
    var _accessToken: String? = nil
    
    /**
     Used to refresh the access token.

     **Thread Safety**

     Access to this property is synchronized; therefore, it is always
     thread-safe.
     */
    public var refreshToken: String? {
        return self.updateAuthInfoQueue.sync {
            self._refreshToken
        }
    }
    var _refreshToken: String? = nil
    
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
    var _expirationDate: Date? = nil
    
    /**
     The scopes that have been authorized for the access token.
     
     You are encouraged to use ``isAuthorized(for:)`` to check which scopes the
     access token is authorized for.

     **Thread Safety**

     Access to this property is synchronized; therefore, it is always
     thread-safe.
     */
    public var scopes: Set<Scope> {
        return self.updateAuthInfoQueue.sync {
            self._scopes
        }
    }
    var _scopes: Set<Scope> = []
    
    /**
     A publisher that emits after the authorization information changes.
     
     **You are discouraged from subscribing to this publisher directly.**
     
     Instead, subscribe to the ``SpotifyAPI/authorizationManagerDidChange``
     publisher of ``SpotifyAPI``. This allows you to be notified of changes even
     when you create a new instance of this class and assign it to the
     ``SpotifyAPI/authorizationManager`` instance property of ``SpotifyAPI``.
     
     Emits after the following events occur:
     * After the access and refresh tokens are retrieved using
       ``AuthorizationCodeFlowBackendManager/requestAccessAndRefreshTokens(redirectURIWithQuery:state:)``
       or
       ``AuthorizationCodeFlowPKCEBackendManager/requestAccessAndRefreshTokens(redirectURIWithQuery:codeVerifier:state:)``
     * After the access token (and possibly the refresh token as well) is
       refreshed using
     ``AuthorizationCodeFlowBackendManager/refreshTokens(onlyIfExpired:tolerance:)``
     or
     ``AuthorizationCodeFlowPKCEBackendManager/refreshTokens(onlyIfExpired:tolerance:)``
     .
     
     See also ``AuthorizationCodeFlowManagerBase/didDeauthorize``, which emits
     after ``deauthorize()`` is called. Subscribe to that publisher in order to
     remove the authorization information from persistent storage when it emits.
     
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
     
     ``deauthorize()`` sets the ``accessToken``, ``expirationDate``,
     ``refreshToken``, and ``scopes`` to `nil`.
     
     Subscribe to this publisher in order to remove the authorization
     information from persistent storage when it emits.
     
     See also ``didChange``.
     
     **Thread Safety**
     
     No guarantees are made about which thread this publisher will emit on.
     */
    public let didDeauthorize = PassthroughSubject<Void, Never>()
    
    var cancellables: Set<AnyCancellable> = []
    
    /// Ensure no data races occur when updating the auth info.
    let updateAuthInfoQueue = DispatchQueue(
        label: "SpotifyAPI.AuthorizationCodeFlowManagerBase.updateAuthInfo"
    )
    
    let refreshTokensQueue = DispatchQueue(
        label: "SpotifyAPI.AuthorizationCodeFlowManagerBase.refreshTokens"
    )

    /**
     The request to refresh the access token is stored in this
     property so that if multiple asynchronous requests are made
     to refresh the access token, then only one actual network
     request is made. Once this publisher finishes, it is set to
     `nil`.
     */
    var refreshTokensPublisher: AnyPublisher<Void, Error>? = nil
    
    required init(backend: Backend) {
        self.backend = backend
        
    }
    
    // MARK: - Codable, Hashable -
    
    init(from decoder: Decoder) throws {
        
        let codingWrapper = try AuthInfo(from: decoder)
        
        self._accessToken = codingWrapper.accessToken
        self._refreshToken = codingWrapper.refreshToken
        self._expirationDate = codingWrapper.expirationDate
        self._scopes = codingWrapper.scopes
        
        let container = try decoder.container(
            keyedBy: AuthInfo.CodingKeys.self
        )
        self.backend = try container.decode(
            Backend.self, forKey: .backend
        )
        
    }
    
    func encode(to encoder: Encoder) throws {
        let codingWrapper = self.updateAuthInfoQueue.sync {
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
			self.backend, forKey: .backend
		)
        try codingWrapper.encode(to: encoder)
        
    }
    
    func hash(into hasher: inout Hasher) {
        self.updateAuthInfoQueue.sync {
            hasher.combine(self.backend)
            hasher.combine(self._accessToken)
            hasher.combine(self._refreshToken)
            hasher.combine(self._expirationDate)
            hasher.combine(self._scopes)
        }
    }

    /**
     Returns a copy of self.
     
     Copies the following properties:
     * ``backend``
     * ``accessToken``
     * ``refreshToken``
     * ``expirationDate``
     * ``scopes``
     */
    public func makeCopy() -> Self {
        let copy = Self(
            backend: self.backend
        )
        return self.updateAuthInfoQueue.sync {
            copy._accessToken = self._accessToken
            copy._refreshToken = self._refreshToken
            copy._expirationDate = self._expirationDate
            copy._scopes = self._scopes
            return copy
        }
    }
}

public extension AuthorizationCodeFlowManagerBase {
    
    // MARK: - Authorization -
    
    /**
     Sets ``accessToken``, ``refreshToken``, ``expirationDate``, and ``scopes`` to
     `nil`.

     After calling this method, you must authorize your application again before
     accessing any of the Spotify web API endpoints.

     If this instance is stored in persistent storage, consider removing it
     after calling this method.

     Calling this method causes
     ``AuthorizationCodeFlowManagerBase/didDeauthorize`` to emit a signal, which
     will also cause the ``SpotifyAPI/authorizationManagerDidDeauthorize``
     publisher of ``SpotifyAPI`` to emit a signal.
     
     **Thread Safety**
     
     This method is thread-safe.
     */
    func deauthorize() {
        self.updateAuthInfoQueue.sync {
            self._accessToken = nil
            self._refreshToken = nil
            self._expirationDate = nil
            self._scopes = []
            self.refreshTokensPublisher = nil
        }
        Self.baseLogger.trace("\(Self.self): didDeauthorize.send()")
        self.didDeauthorize.send()
    }
    
    /**
     Determines whether the access token is expired within the given tolerance.
     
     See also ``isAuthorized(for:)``.
     
     The access token is refreshed automatically when necessary before each
     request to the Spotify web API is made. Therefore, **you should never**
     **need to call this method directly.**
     
     - Parameter tolerance: The tolerance in seconds. Default 120.
     - Returns: `true` if ``expirationDate`` - `tolerance` is equal to or before
           the current date or if ``accessToken`` is `nil`. Else, `false`.
     
     **Thread Safety**
     
     This method is thread-safe.
     */
    func accessTokenIsExpired(tolerance: Double = 120) -> Bool {
        return self.updateAuthInfoQueue.sync {
            return accessTokenIsExpiredNOTThreadSafe(tolerance: tolerance)
        }
    }
    
    /**
     Returns `true` if ``accessToken`` is not `nil` and the application is
     authorized for the specified scopes, else `false`.
     
     - Parameter scopes: A set of [Spotify Authorization Scopes][1]. Use an
           empty set (default) to check if an ``accessToken`` has been retrieved
           for the application, which is still required for all endpoints, even
           those that do not require scopes.
     
     **Thread Safety**
     
     This method is thread-safe.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     */
    func isAuthorized(for scopes: Set<Scope> = []) -> Bool {
        return self.updateAuthInfoQueue.sync {
            if self._accessToken == nil { return false }
            return scopes.isSubset(of: self._scopes)
        }
    }
    
}

extension AuthorizationCodeFlowManagerBase {

    // MARK: - Internal -
    
    func updateFromAuthInfo(_ authInfo: AuthInfo) {
        self._accessToken = authInfo.accessToken
        if let refreshToken = authInfo.refreshToken {
            self._refreshToken = refreshToken
        }
        self._expirationDate = authInfo.expirationDate
        self._scopes = authInfo.scopes
        self.refreshTokensPublisher = nil
        self.refreshTokensQueue.async {
            Self.baseLogger.trace("\(Self.self): didChange.send()")
            self.didChange.send()
        }
    }
    
    /// This method should **ALWAYS** be called within
    /// ``updateAuthInfoDispatchQueue``, or the thread-safety guarantees
    /// of this class will be violated.
    func accessTokenIsExpiredNOTThreadSafe(tolerance: Double = 120) -> Bool {
        if (self._accessToken == nil) != (self._expirationDate == nil) {
            let expirationDateString = self._expirationDate?
                .description(with: .current) ?? "nil"
            Self.baseLogger.error(
                """
                \(Self.self): accessToken or expirationDate was nil, but not both:
                accessToken == nil: \(self._accessToken == nil); \
                expiration date: \(expirationDateString)
                """
            )
        }
        if self._accessToken == nil { return true }
        guard let expirationDate = self._expirationDate else { return true }
        return expirationDate.addingTimeInterval(-tolerance) <= Date()
    }
    
    /// Used internally by this library. Do not call this method directly.
    public func _assertNotOnUpdateAuthInfoDispatchQueue() {
        #if DEBUG
        dispatchPrecondition(
            condition: .notOnQueue(self.updateAuthInfoQueue)
        )
        #endif
    }
    
    func isEqualTo(other: AuthorizationCodeFlowManagerBase) -> Bool {
        
        let (lhsAccessToken, lhsRefreshToken, lhsScopes, lhsExpirationDate) =
            self.updateAuthInfoQueue
                .sync { () -> (String?, String?, Set<Scope>?, Date?) in
                    return (
                        self._accessToken,
                        self._refreshToken,
                        self._scopes,
                        self._expirationDate
                    )
                }
        
        let (rhsAccessToken, rhsRefreshToken, rhsScopes, rhsExpirationDate) =
                other.updateAuthInfoQueue
                    .sync { () -> (String?, String?, Set<Scope>?, Date?) in
                        return (
                            other._accessToken,
                            other._refreshToken,
                            other._scopes,
                            other._expirationDate
                        )
                    }
        
		return self.backend == other.backend &&
                lhsAccessToken == rhsAccessToken &&
                lhsRefreshToken == rhsRefreshToken &&
                lhsScopes == rhsScopes &&
                lhsExpirationDate.isApproximatelyEqual(to: rhsExpirationDate)

    }

}

extension AuthorizationCodeFlowManagerBase {

    // MARK: - Testing -
    
    /// This method sets random values for various properties for testing
    /// purposes. Do not call it outside the context of tests.
    func mockValues() {
        self.updateAuthInfoQueue.sync {
            self._accessToken = UUID().uuidString
            self._refreshToken = UUID().uuidString
            self._expirationDate = Date()
            self._scopes = Set(Scope.allCases.shuffled().prefix(5))
        }
    }
    
	/// Only use for testing purposes.
    func subscribeToDidChange() {
        
        self.didChange
            .print("\(Self.self): subscribeToDidChange")
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)
        
    }
    
    /**
     Sets the expiration date of the access token to the specified date.
     **Only use for testing purposes**.
     
     - Parameter date: The date to set the expiration date to.
     */
    public func setExpirationDate(to date: Date) {
        self.updateAuthInfoQueue.sync {
            Self.baseLogger.notice(
                "\(Self.self): mock expiration date: \(date.description(with: .current))"
            )
            self._expirationDate = date
        }
    }
    
}
