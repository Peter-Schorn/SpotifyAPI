import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import Logging

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 Manages the authorization process for the Authorization Code Flow.
 
 For applications where it is unsafe to store your client secret, consider
 using ``AuthorizationCodeFlowPKCEBackendManager``, which manages the
 [Authorization Code Flow with Proof Key for Code Exchange][2]; it provides
 an additional layer of security.
 
 **Backend**
 
 This class is generic over a backend. The backend handles the process of
 requesting the authorization information and refreshing the access token from
 Spotify. It may do so directly (see ``AuthorizationCodeFlowClientBackend``), or
 it may communicate with a custom backend server that you configure (see
 ``AuthorizationCodeFlowProxyBackend``). This backend server can safely store
 your client secret and retrieve the authorization information from Spotify on
 your behalf, thereby preventing these sensitive credentials from being exposed
 in your frontend app. See ``AuthorizationCodeFlowBackend`` for more
 information.

 **If you do not have a custom backend server, then you are encouraged use the**
 **concrete subclass of this class,** ``AuthorizationCodeFlowManager``
 **instead**. It inherits from
 ``AuthorizationCodeFlowBackendManager``<``AuthorizationCodeFlowClientBackend``>.
 This class will store your client id and client secret locally.

 **Authorization**
 
 The first step in the authorization code flow is to make the
 authorization URL using
 ``makeAuthorizationURL(redirectURI:showDialog:state:scopes:)``.
 Open this URL in a browser/webview to allow the user to login to their Spotify
 account and authorize your application.
 
 After they either authorize or deny authorization for your application,
 Spotify will redirect to the redirect URI specified in the authorization
 URL with query parameters appended to it. Pass this URL into
 ``requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`` to request
 the refresh and access tokens. After that, you can begin making requests
 to the Spotify API. The access token will be refreshed for you automatically
 when needed.
 
 Use ``AuthorizationCodeFlowManagerBase/isAuthorized(for:)`` to check if your
 application is authorized for the specified scopes.
 
 Use ``AuthorizationCodeFlowManagerBase/deauthorize()`` to set the
 ``AuthorizationCodeFlowManagerBase/accessToken``,
 ``AuthorizationCodeFlowManagerBase/refreshToken``,
 ``AuthorizationCodeFlowManagerBase/expirationDate``, and
 ``AuthorizationCodeFlowManagerBase/scopes`` to `nil`.
 
 **Persistent Storage**
 
 Note that this type conforms to `Codable`. It is this type that you should
 encode to data using a `JSONEncoder` in order to save the authorization
 information to persistent storage. See
 <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
 information.
 
 Read more about the [Authorization Code Flow][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 [2]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 */
public class AuthorizationCodeFlowBackendManager<Backend: AuthorizationCodeFlowBackend>:
    AuthorizationCodeFlowManagerBase<Backend>,
    SpotifyScopeAuthorizationManager,
    Hashable,
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
                    .authorizationCodeFlowManagerLogger
        }
        set {
            AuthorizationManagerLoggers
                    .authorizationCodeFlowManagerLogger = newValue
        }
    }

    // MARK: - Initializers

    /**
     Creates an authorization manager for the Authorization Code Flow.
     
     **If you do not have a custom backend server, then you are encouraged to**
     **use the concrete subclass of this class,**
     ``AuthorizationCodeFlowManager`` **instead**. It inherits from
     ``AuthorizationCodeFlowBackendManager``<``AuthorizationCodeFlowClientBackend``>.
     This class will store your client id and client secret locally.

     Note that this type conforms to `Codable`. It is this type that you should
     encode to data using a `JSONEncoder` in order to save the authorization
     information to persistent storage. See
     <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
     information.
     
     Read more about the [Authorization Code Flow][1].

     - Parameters:
       - backend: A type that handles the process of requesting the
             authorization information and refreshing the access token from
             Spotify. It may do so directly (see
             ``AuthorizationCodeFlowClientBackend``), or it may communicate with
             a custom backend server that you configure (see
             ``AuthorizationCodeFlowProxyBackend``). See
             ``AuthorizationCodeFlowBackend`` for more information.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     */
    public required init(backend: Backend) {
        super.init(backend: backend)
    }
    
    /**
     Creates an authorization manager for the Authorization Code Flow.
     
     **In general, only use this initializer if you have retrieved the**
     **authorization information from an external source.** Otherwise, use
     ``init(backend:)``.
     
     **If you do not have a custom backend server, then you are encouraged to**
     **use the concrete subclass of this class,**
     ``AuthorizationCodeFlowManager`` **instead**. It inherits from
     ``AuthorizationCodeFlowBackendManager``<``AuthorizationCodeFlowClientBackend``>.
     This class will store your client id and client secret locally.
    
     You are discouraged from individually saving the properties of this
     instance to persistent storage and then retrieving them later and passing
     them into this initializer. Instead, encode this entire instance to data
     using a `JSONEncoder` and then decode the data from storage later. See
     <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
     information.
     
     Read more about the [Authorization Code Flow][1].
     
     - Parameters:
       - backend: A type that handles the process of requesting the
             authorization information and refreshing the access token from
             Spotify. It may do so directly (see
             ``AuthorizationCodeFlowClientBackend``), or it may communicate with
             a custom backend server that you configure (see
             ``AuthorizationCodeFlowProxyBackend``). See
             ``AuthorizationCodeFlowBackend`` for more information.
       - accessToken: The access token.
       - expirationDate: The expiration date of the access token.
       - refreshToken: The refresh token. If `nil` (not recommended), then it
             will not be possible to automatically refresh the access token when
             it expires; instead, you will have to go through the authorization
             process again, as described in the README in the root directory of
             this package. Use
             ``AuthorizationCodeFlowManagerBase/accessTokenIsExpired(tolerance:)``
             to check if the access token is expired.
       - scopes: The scopes that have been authorized for the access token.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     */
    public convenience init(
        backend: Backend,
        accessToken: String,
        expirationDate: Date,
        refreshToken: String?,
        scopes: Set<Scope>
    ) {
        self.init(backend: backend)
        self._accessToken = accessToken
        self._expirationDate = expirationDate
        self._refreshToken = refreshToken
        self._scopes = scopes
    }
    
    // MARK: - Codable, Hashable, CustomStringConvertible
    
    public required override init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
    }
    
    public static func == (
        lhs: AuthorizationCodeFlowBackendManager,
        rhs: AuthorizationCodeFlowBackendManager
    ) -> Bool {
        
        return lhs.isEqualTo(other: rhs)
        
    }
    
    public var description: String {
        // print("AuthorizationCodeFlowBackendManager.description WAITING for queue")
        return self.updateAuthInfoQueue.sync {
            // print("AuthorizationCodeFlowBackendManager.description INSIDE queue")
            let expirationDateString = self._expirationDate?
                    .description(with: .current) ?? "nil"
            
            return """
                AuthorizationCodeFlowBackendManager(
                    access token: \(self._accessToken.quotedOrNil())
                    scopes: \(self._scopes.map(\.rawValue))
                    expiration date: \(expirationDateString)
                    refresh token: \(self._refreshToken.quotedOrNil())
                    backend: \("\(self.backend)".indented(tabEquivalents: 1))
                )
                """
        }
    }

}

public extension AuthorizationCodeFlowBackendManager {
    
    // MARK: - Authorization
    
    /**
     The first step in the Authorization Code Flow.
     
     Creates the URL that is used to request authorization for your app. It
     displays a permissions dialog to the user. Open the URL in a
     browser/webview so that the user can login to their Spotify account and
     authorize your app.

     After the user either authorizes or denies authorization for your
     application, Spotify will redirect to `redirectURI` with query parameters
     appended to it. Pass that URL into
     ``requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`` to complete
     the authorization process.
     
     **Warning**
     
     **DO NOT add a forward-slash to the end of the redirect URI**.
     
     All of these values will be automatically percent-encoded. Therefore, do
     not percent-encode them yourself before passing them into this method.

     Read more at the [Spotify web API reference][1].

     - Parameters:
       - redirectURI: The location that Spotify will redirect to after the user
             authorizes or denies authorization for your app. Usually, this
             should contain a custom URL scheme that redirects to a location in
             your app. This URI needs to have been entered in the Redirect URI
             whitelist that you specified when you [registered your
             application][2].
       - showDialog: Whether or not to force the user to approve the app again
             if they’ve already done so. If `false`, a user who has already
             approved the application may be automatically redirected to the
             `redirectURI`. If `true`, the user will not be automatically
             redirected and will have to approve the app again.
       - state: Optional, but strongly recommended. **If you provide a value**
             **for this parameter, you must pass the same value to**
             ``requestAccessAndRefreshTokens(redirectURIWithQuery:state:)``,
             **otherwise an error will be thrown.** The state can be useful for
             correlating requests and responses. Because your redirect URI can
             be guessed, using a state value can increase your assurance that an
             incoming connection is the result of an authentication request that
             you made. If you generate a random string or encode the hash of
             some client state (e.g., a cookie) in this state variable, you can
             validate the response to additionally ensure that the request and
             response originated in the same browser. This provides protection
             against attacks such as cross-site request forgery.
       - scopes: A set of [Spotify Authorization scopes][3].
     - Returns: The URL that must be opened to authorize your app. May return
           `nil` if the URL could not be created.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-user-authorization
     [2]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     [3]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     
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
                "client_id": self.backend.clientId,
                "response_type": "code",
                "redirect_uri": redirectURI.absoluteString,
                "scope": Scope.makeString(scopes),
                "show_dialog": showDialog,
                "state": state
            ])
        )
        
    }
    
    /**
     The second and final step in the Authorization Code Flow.
     
     After you open the URL from
     ``makeAuthorizationURL(redirectURI:showDialog:state:scopes:)`` and the user
     either authorizes or denies authorization for your app, Spotify will
     redirect to the redirect URI you specified with query parameters appended
     to it. Pass this URL into this method to request access and refresh tokens.
     The access token is required for all endpoints, even those that do not
     access user data.

     If the user denied your app's authorization request or the request failed
     for some other reason, then ``SpotifyAuthorizationError`` will be thrown to
     downstream subscribers. Use the
     ``SpotifyAuthorizationError/accessWasDenied`` boolean property of this
     error to check if the user denied your app's authorization request.

     If the request for the access and refresh tokens succeeds,
     ``AuthorizationCodeFlowManagerBase/didChange`` will emit a signal, which
     causes ``SpotifyAPI/authorizationManagerDidChange`` to emit a signal.
     
     **Warning**
     
     All of these values will be automatically percent-encoded. Therefore, do
     not percent-encode them yourself before passing them into this method.

     Read more at the [Spotify web API reference][1].

     - Parameters:
       - redirectURIWithQuery: The redirect URI with query parameters appended
             to it.
       - state: The value of the state parameter that you provided when making
             the authorization URL. The state can be useful for correlating
             requests and responses. Because your redirect URI can be guessed,
             using a state value can increase your assurance that an incoming
             connection is the result of an authentication request that you
             made. **If the state parameter in the query string of**
             `redirectURIWithQuery` **doesn't match this value, then an error**
             **will be thrown.** If `nil`, then the state parameter must not be
             present in `redirectURIWithQuery` either, otherwise an error will
             be thrown. After this request has been made, you should generate a
             new value for this parameter in preparation for the next
             authorization process.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-access-token
     
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

        // If the code is found in the query, then the user successfully
        // authorized the application. This is required for requesting the
        // access and refresh tokens.
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
            
            Self.logger.error("unknown error")
            return SpotifyGeneralError.other(
                """
                an unknown error occurred when handling the redirect URI: \
                expected to find 'code' or 'error' parameter in query string: \
                '\(redirectURIWithQuery.absoluteString)'
                """
            )
            .anyFailingPublisher()
            
        }
        
        // Ensure the state parameter in the query string of the redirect
        // URI matches the value provided to this method.
        guard state == queryDict["state"] else {
            return SpotifyGeneralError.invalidState(
                supplied: state, received: queryDict["state"]
            )
            .anyFailingPublisher()
        }
        
        Self.logger.trace("backend.requestAccessAndRefreshTokens")
        
        return self.backend.requestAccessAndRefreshTokens(
            code: code,
            redirectURIWithQuery: redirectURIWithQuery
        )
        .decodeSpotifyObject(AuthInfo.self)
        .tryMap { authInfo in
            
            Self.logger.trace("received authInfo:\n\(authInfo)")
            
            if authInfo.accessToken == nil ||
                authInfo.refreshToken == nil ||
                authInfo.expirationDate == nil {
                
                let errorMessage = """
                    missing properties after requesting access and \
                    refresh tokens (expected access token, refresh token, \
                    and expiration date):
                    \(authInfo)
                    """
                Self.logger.error("\(errorMessage)")
                throw SpotifyGeneralError.other(errorMessage)
                
            }
            
            self.updateFromAuthInfo(authInfo)
            
        }
        .eraseToAnyPublisher()
            
    }

    /**
     Uses the refresh token to get a new access token.
    
     **You shouldn't need to call this method**. It gets called automatically
     each time you make a request to the Spotify API.

     If the access and/or refresh tokens are refreshed, then
     ``AuthorizationCodeFlowManagerBase/didChange`` will emit a signal, which
     causes ``SpotifyAPI/authorizationManagerDidChange`` to emit a signal.
     
     **Thread Safety**
     
     Calling this method is thread-safe. If a network request to refresh the
     tokens is already in progress, additional calls will return a reference to
     the same publisher.

     **However**, no guarantees are made about the thread that the publisher
     returned by this method will emit on.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - onlyIfExpired: Only refresh the access token if it is expired.
       - tolerance: The tolerance in seconds to use when determining if the
             token is expired. Defaults to 120, meaning that a new token will be
             retrieved if the current one has expired or will expire in the next
             two minutes. The token is considered expired if
             ``AuthorizationCodeFlowManagerBase/expirationDate`` - `tolerance`
             is equal to or before the current date. This parameter has no
             effect if `onlyIfExpired` is `false`.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-a-refreshed-access-token
     */
    func refreshTokens(
        onlyIfExpired: Bool,
        tolerance: Double = 120
    ) -> AnyPublisher<Void, Error> {
        
        do {
            
            return try self.updateAuthInfoQueue
                .sync { () -> AnyPublisher<Void, Error> in
                    
                    if onlyIfExpired && !self.accessTokenIsExpiredNOTThreadSafe(
                        tolerance: tolerance
                    ) {
                        Self.logger.trace(
                            "access token not expired; returning early"
                        )
                        return ResultPublisher(())
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
                        throw SpotifyGeneralError.unauthorized(errorMessage)
                    }
                    
                    Self.logger.trace("backend.refreshTokens")
                    let refreshTokensPublisher = self.backend.refreshTokens(
                        refreshToken: refreshToken
                    )
                    .decodeSpotifyObject(AuthInfo.self)
                    .receive(on: self.updateAuthInfoQueue)
                    .tryMap { authInfo in
                        
                        Self.logger.trace("received authInfo:\n\(authInfo)")
                        
                        if authInfo.accessToken == nil ||
                                authInfo.expirationDate == nil {

                            let errorMessage = """
                                missing properties after refreshing \
                                access token (expected access token \
                                and expiration date):
                                \(authInfo)
                                """
                            Self.logger.error("\(errorMessage)")
                            throw SpotifyGeneralError.other(errorMessage)
                            
                        }
                        
                        self.updateFromAuthInfo(authInfo)
                        
                    }
                    .handleEvents(
                        // Once this publisher finishes, we must
                        // set `self.refreshTokensPublisher` to `nil`
                        // so that the caller does not receive a publisher
                        // that has already finished.
                        receiveCompletion: { _ in
                            self.refreshTokensPublisher = nil
                        }
                    )
                    .receive(on: self.refreshTokensQueue)
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

// MARK: - Authorization Code Flow Manager -

/**
 Manages the authorization process for the Authorization Code Flow.
 
 For applications where it is unsafe to store your client secret, consider
 using ``AuthorizationCodeFlowPKCEManager``, which manages the
 [Authorization Code Flow with Proof Key for Code Exchange][2]; it provides
 an additional layer of security.
 
 This class stores the client id and client secret locally. Consider using
 ``AuthorizationCodeFlowBackendManager``<``AuthorizationCodeFlowProxyBackend``>,
 which allows you to setup a custom backend server that can store these
 sensitive credentials and which communicates with Spotify on your behalf in
 order to retrieve the authorization information.
 
 **Authorization**
 
 The first step in the authorization code flow is to make the authorization URL
 using
 ``AuthorizationCodeFlowBackendManager/makeAuthorizationURL(redirectURI:showDialog:state:scopes:)``.
 Open this URL in a browser/webview to allow the user to login to their Spotify
 account and authorize your application.
 
 After they either authorize or deny authorization for your application, Spotify
 will redirect to the redirect URI specified in the authorization URL with query
 parameters appended to it. Pass this URL into
 ``AuthorizationCodeFlowBackendManager/requestAccessAndRefreshTokens(redirectURIWithQuery:state:)``
 to request the refresh and access tokens. After that, you can begin making
 requests to the Spotify API. The access token will be refreshed for you
 automatically when needed.
 
 Use ``AuthorizationCodeFlowManagerBase/isAuthorized(for:)`` to check if your
 application is authorized for the specified scopes.
 
 Use ``AuthorizationCodeFlowManagerBase/deauthorize()`` to set the
 ``AuthorizationCodeFlowManagerBase/accessToken``,
 ``AuthorizationCodeFlowManagerBase/refreshToken``,
 ``AuthorizationCodeFlowManagerBase/expirationDate``, and
 ``AuthorizationCodeFlowManagerBase/scopes`` to `nil`. Does not change
 ``AuthorizationCodeFlowManager/clientId`` or
 ``AuthorizationCodeFlowManager/clientSecret``, which are immutable.
 
 **Persistent Storage**
 
 Note that this type conforms to `Codable`. It is this type that you should
 encode to data using a `JSONEncoder` in order to save the authorization
 information to persistent storage. See
 <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
 information.
 
 Read more about the [Authorization Code Flow][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 [2]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 */
public final class AuthorizationCodeFlowManager:
    AuthorizationCodeFlowBackendManager<AuthorizationCodeFlowClientBackend>
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
     Creates an authorization manager for the Authorization Code Flow.
     
     To get a client id and client secret, go to the [Spotify Developer
     Dashboard][2] and create an app. see the README in the root directory of
     this package for more information.
     
     Note that this type conforms to `Codable`. It is this type that you should
     encode to data using a `JSONEncoder` in order to save the authorization
     information to persistent storage. See
     <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
     information.
     
     - Parameters:
       - clientId: The client id that you received when you [registered your
             application][3].
       - clientSecret: The client secret that you received when you [registered
             your application][3].

     Read more about the [Authorization Code Flow][1].

     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     [2]: https://developer.spotify.com/dashboard/login
     [3]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public convenience init(
        clientId: String,
        clientSecret: String
    ) {
        
        let backend = AuthorizationCodeFlowClientBackend(
            clientId: clientId,
            clientSecret: clientSecret
        )
        self.init(backend: backend)
        
    }
    
    /**
     Creates an authorization manager for the Authorization Code Flow.
     
     **In general, only use this initializer if you have retrieved the**
     **authorization information from an external source.** Otherwise, use
     ``init(clientId:clientSecret:)``.
    
     You are discouraged from individually saving the properties of this
     instance to persistent storage and then retrieving them later and passing
     them into this initializer. Instead, encode this entire instance to data
     using a `JSONEncoder` and then decode the data from storage later. See
     <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for more
     information.
     
     To get a client id and client secret, go to the [Spotify Developer
     Dashboard][2] and create an app. see the README in the root directory of
     this package for more information.
     
     Read more about the [Authorization Code Flow][1].

     - Parameters:
       - clientId: The client id that you received when you [registered your
             application][4].
       - clientSecret: The client secret that you received when you [registered
             your application][4].
       - accessToken: The access token.
       - expirationDate: The expiration date of the access token.
       - refreshToken: The refresh token. If `nil` (not recommended), then it
             will not be possible to automatically refresh the access token when
             it expires; instead, you will have to go through the authorization
             process again, as described in the README in the root directory of
             this package. Use
             ``AuthorizationCodeFlowManagerBase/accessTokenIsExpired(tolerance:)``
             to check if the access token is expired.
       - scopes: The scopes that have been authorized for the access token.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     [2]: https://developer.spotify.com/dashboard/login
     [4]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public convenience init(
        clientId: String,
        clientSecret: String,
        accessToken: String,
        expirationDate: Date,
        refreshToken: String?,
        scopes: Set<Scope>
    ) {
        self.init(
            clientId: clientId,
            clientSecret: clientSecret
        )
        self._accessToken = accessToken
        self._expirationDate = expirationDate
        self._refreshToken = refreshToken
        self._scopes = scopes
    }

    public override var description: String {
        // print("AuthorizationCodeFlowBackendManager.description WAITING for queue")
        return self.updateAuthInfoQueue.sync {
            // print("AuthorizationCodeFlowBackendManager.description INSIDE queue")
            let expirationDateString = self._expirationDate?
                    .description(with: .current) ?? "nil"
            
            return """
                AuthorizationCodeFlowManager(
                    access token: \(self._accessToken.quotedOrNil())
                    scopes: \(self._scopes.map(\.rawValue))
                    expiration date: \(expirationDateString)
                    refresh token: \(self._refreshToken.quotedOrNil())
                    clientId: "\(self.clientId)"
                    clientSecret: "\(self.clientSecret)"
                
                )
                """
        }
    }

}
