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
 Manages the authorization process for the
 [Authorization Code Flow with Proof Key for Code Exchange][1] (PKCE).
 
 The authorization code flow with PKCE is the best option for mobile and desktop
 applications where it is unsafe to store your client secret. It provides an
 additional layer of security compared to the authorization code flow. For further
 information about this flow, see [IETF RFC-7636][2].
 
 Before each authentication request your app should generate a code verifier and
 a code challenge. The code verifier is a cryptographically random string between
 43 and 128 characters in length. It can contain letters, digits, underscores,
 periods, hyphens, or tildes.
 
 In order to generate the code challenge, your app should hash the code verifier
 using the SHA256 algorithm. Then, [base64url][3] encode the hash that you generated.
 **Do not include any** `=` **padding characters** (percent-encoded or not).

 You can use `String.randomURLSafe(length:using:)` or
 `String.randomURLSafe(length:)` to generate the code verifier. You can Use the
 `String.makeCodeChallenge()` instance method to create the code challenge
 from the code verifier. For example:
 
 ```
 let codeVerifier = String.randomURLSafe(length: 128)
 let codeChallenge = codeVerifier.makeCodeChallenge()
 ```
 
 If you use your own method to create these values, you can validate them
 using this [PKCE generator tool][4]. See also `Data.base64URLEncodedString()`
 and `String.urlSafeCharacters`.
 
 The first step in the authorization proccess is to make the authorization
 URL using
 `makeAuthorizationURL(redirectURI:showDialog:codeChallenge:state:scopes:)`.
 Open this URL in a broswer/webview to allow the user to login
 to their Spotify account and authorize your application. It displays a
 permissions dialog to the user.
 
 After the user either authorizes or denies authorization for your application,
 Spotify will redirect to the redirect URI specified in the authorization
 URL with query parameters appended to it. Pass this URL into
 `requestAccessAndRefreshTokens(redirectURIWithQuery:codeVerifier:state:)`
 to request the refresh and access tokens. After that, you can begin making
 requests to the Spotify API. The access token will be refreshed for you
 automatically when needed.
 
 Note that this type conforms to `Codable`. It is this type that you should
 encode to data using a `JSONEncoder` in order to save it to persistent storage.
 See this [article][5] for more information.
 
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
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
 [2]: https://tools.ietf.org/html/rfc7636
 [3]: https://tools.ietf.org/html/rfc4648#section-5
 [4]: https://tonyxu-io.github.io/pkce-generator/
 [5]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
 */
public final class AuthorizationCodeFlowPKCEManager<Endpoint: AuthorizationCodeFlowPKCEEndpoint>:
    AuthorizationCodeFlowManagerBase<Endpoint>,
    SpotifyScopeAuthorizationManager
{
    
    /// The logger for this class.
    public static var logger: Logger {
        get {
            return AuthorizationManagerLoggers
                    .authorizationCodeFlowPKCEManagerLogger
        }
        set {
            AuthorizationManagerLoggers
                    .authorizationCodeFlowPKCEManagerLogger = newValue
        }
    }
        
    /**
     Creates an authorization manager for the
     [Authorization Code Flow with Proof Key for Code Exchange][1].
     
     To get a client id and client secret, go to the
     [Spotify Developer Dashboard][2] and create an app.
     see the README in the root directory of this package for more information.
     
     Note that this type conforms to `Codable`. It is this type that you should
     encode to data using a `JSONEncoder` in order to save it to persistent storage.
     See this [article][3] for more information.
     
     - Parameters:
       - clientId: The client id for your application.
       - clientSecret: The client secret for your application.
       - networkAdaptor: A function that gets called everytime this class—and
             only this class—needs to make a network request. Use this
             function if you need to use a custom networking client. The `url`
             and `httpMethod` properties of the `URLRequest` parameter are
             guaranteed to be non-`nil`. No guarentees are made about which
             thread this function will be called on. The default is `nil`,
             in which case `URLSession` will be used for the network requests.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
     [2]: https://developer.spotify.com/dashboard/login
     [3]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
     */
    public required init(
        endpoint: Endpoint,
        networkAdaptor: (
            (URLRequest) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
        )? = nil
    ) {
        super.init(
            endpoint: endpoint,
            networkAdaptor: networkAdaptor
        )
    }
    
    /**
     Creates an authorization manager for the
     [Authorization Code Flow with Proof Key for Code Exchange][1].
     
     **In general, only use this initializer if you have retrieved the**
     **authorization information from an external source.** Otherwise, use
     ``init(clientId:clientSecret:networkAdaptor:)``.
    
     You are discouraged from individually saving the properties of this instance
     to persistent storage and then retrieving them later and passing them into
     this initializer. Instead, encode this entire instance to data using a
     `JSONEncoder` and then decode the data from storage later. See
     [Saving authorization information to persistent storage][2] for more
     information.
     
     To get a client id and client secret, go to the
     [Spotify Developer Dashboard][3] and create an app. see the README in the root
     directory of this package for more information.
     
     - Parameters:
       - clientId: The client id for your application.
       - clientSecret: The client secret for your application.
       - accessToken: The access token.
       - expirationDate: The expiration date of the access token.
       - refreshToken: The refresh token. If `nil` (not recommended), then it will
             not be possible to automatically refresh the access token when it
             expires; instead, you will have to go through the authorization process
             again, as described in the README in the root directory of this package.
             Use `accessTokenIsExpired(tolerance:)` to check if the access token is
             expired.
       - scopes: The scopes that have been authorized for the access token.
       - networkAdaptor: A function that gets called everytime this class—and
             only this class—needs to make a network request. Use this
             function if you need to use a custom networking client. The `url`
             and `httpMethod` properties of the `URLRequest` parameter are
             guaranteed to be non-`nil`. No guarentees are made about which
             thread this function will be called on. The default is `nil`,
             in which case `URLSession` will be used for the network requests.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
     [2]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
     [3]: https://developer.spotify.com/dashboard/login
     */
    public convenience init(
		endpoint: Endpoint,
        accessToken: String,
        expirationDate: Date,
        refreshToken: String?,
        scopes: Set<Scope>,
        networkAdaptor: (
            (URLRequest) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
        )? = nil
    ) {
        self.init(
			endpoint: endpoint,
            networkAdaptor: networkAdaptor
        )
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
    
    /// :nodoc:
    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
    }

}

public extension AuthorizationCodeFlowPKCEManager {
    
    // MARK: - Authorization -
    
    /**
     The first step in the authorization process for the
     [Authorization Code Flow with Proof Key for Code Exchange][1].
     
     Creates the URL that is used to request authorization for your app. It
     displays a permissins dialog to the user. Open the URL in a
     browser/webview so that the user can login to their Spotify account and
     authorize your app.

     Before each authentication request your app should generate a code verifier
     and a code challenge. The code verifier is a cryptographically random string
     between 43 and 128 characters in length. It can contain letters, digits,
     underscores, periods, hyphens, or tildes.
     
     In order to generate the code challenge, your app should hash the code verifier
     using the SHA256 algorithm. Then, [base64url][2] encode the hash that you
     generated.  **Do not include any** `=` **padding characters**
     (percent-encoded or not).

     You can use `String.randomURLSafe(length:using:)` or
     `String.randomURLSafe(length:)` to generate the code verifier. You can Use the
     `String.makeCodeChallenge()` instance method to create the code challenge
     from the code verifier. For example:
     
     ```
     let codeVerifier = String.randomURLSafe(length: 128)
     let codeChallenge = codeVerifier.makeCodeChallenge()
     ```
     
     If you use your own method to create these values, you can validate them
     using this [PKCE generator tool][3]. See also `Data.base64URLEncodedString()`
     and `String.urlSafeCharacters`.
     
     After the user either authorizes or denies authorization for your
     application, Spotify will redirect to `redirectURI` with query parameters
     appended to it. Pass that URL into
     `requestAccessAndRefreshTokens(redirectURIWithQuery:codeVerifier:state:)`
     to complete the authorization process.
     
     # Warning:
     
     **DO NOT add a forward-slash to the end of the redirect URI**.
     
     All of these values will be automatically percent-encoded.
     Therefore, do not percent-encode them yourself before passing them
     into this method.

     - Parameters:
       - redirectURI: The location that Spotify will redirect to
             after the user authorizes or denies authorization for your app.
             Usually, this should be a custom URL scheme that redirects to a
             location in your app. This URI needs to have been entered in the
             Redirect URI whitelist that you specified when you
             [registered your application][4].
       - codeChallenge: The code challenge. See above.
       - state: Optional, but strongly recommended. **If you provide a value**
             **for this parameter, you must pass the same value to**
             `requestAccessAndRefreshTokens(redirectURIWithQuery:codeVerifier:state:)`,
             **otherwise an error will be thrown.** The state can be useful for
             correlating requests and responses. Because your redirect URI can
             be guessed, using a state value can increase your assurance that
             an incoming connection is the result of an authentication request
             that you made. If you generate a random string or encode the hash of
             some client state (e.g., a cookie) in this state variable, you can
             validate the response to additionally ensure that the request and
             response originated in the same browser. This provides protection
             against attacks such as cross-site request forgery.
       - scopes: A set of [Spotify Authorization scopes][5].
     - Returns: The URL that must be opened to authorize your app. May return
           `nil` if the URL could not be created.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
     [2]: https://tools.ietf.org/html/rfc4648#section-5
     [3]: https://tonyxu-io.github.io/pkce-generator/
     [4]: https://developer.spotify.com/dashboard/applications
     [5]: https://developer.spotify.com/documentation/general/guides/scopes/
     
     - Tag: PKCEmakeAuthorizationURL
     */
    func makeAuthorizationURL(
        redirectURI: URL,
        codeChallenge: String,
        state: String?,
        scopes: Set<Scope>
    ) -> URL? {
        
        return URL(
            scheme: "https",
            host: Endpoints.accountsBase,
            path: Endpoints.authorize,
            queryItems: urlQueryDictionary([
				"client_id": endpoint.clientId,
                "response_type": "code",
                "redirect_uri": redirectURI.absoluteString,
                "scope": Scope.makeString(scopes),
                "state": state,
                "code_challenge_method": "S256",
                "code_challenge": codeChallenge
            ])
        )
        
    }
    
    /**
     This method is deprecated.

     Use `makeAuthorizationURL(redirectURI:codeChallenge:state:scopes:)`
     instead (the `showDialog` parameter was removed because it is not
     used by the Spotify web API for this authorization flow).
     
     :nodoc:
     */
    @available(
        *,
        deprecated,
        message: """
            Use `makeAuthorizationURL(redirectURI:codeChallenge:state:scopes:)` \
            instead (the `showDialog` parameter was removed because it is not \
            used by the Spotify web API for this authorization flow).
            """
    )
    func makeAuthorizationURL(
        redirectURI: URL,
        showDialog: Bool,
        codeChallenge: String,
        state: String?,
        scopes: Set<Scope>
    ) -> URL? {
        
        return self.makeAuthorizationURL(
            redirectURI: redirectURI,
            codeChallenge: codeChallenge,
            state: state,
            scopes: scopes
        )
        
    }

    /**
     The second and final step in the authorization process for the
     [Authorization Code Flow with Proof Key for Code Exchange][1].
     
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
       - redirectURIWithQuery: The redirect URI with query parameters appended to it.
       - codeVerifier: The code verifier that you generated when creating the
             authorization URL. **This must be between 43 and 128 characters long.**
             After this request has completed, you should generate a new
             code verifer and code challenge in preparation for the next
             authorization process.
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
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce

     - Tag: PKCErequestAccessAndRefreshTokens-redirectURIWithQuery
     */
    func requestAccessAndRefreshTokens(
        redirectURIWithQuery: URL,
        codeVerifier: String,
        state: String?
    ) -> AnyPublisher<Void, Error> {

        let count = codeVerifier.count
        assert(
            (43...128).contains(count),
            "The code verifier must be between 43 and 128 characters " +
            "(recevied \(count))"
        )
        
        Self.logger.trace(
            "redirectURIWithQuery: '\(redirectURIWithQuery)'"
        )
        
        // A dictionary of the query items in the URL
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
        
		let tokensRequest = endpoint.makePKCETokenRequest(code: code, codeVerifier: codeVerifier, redirectURIWithQuery: redirectURIWithQuery)
		
		let bodyString = String(data: tokensRequest.httpBody!, encoding: .utf8) ?? "nil"
        
        Self.logger.trace(
            """
            POST request to "\(Endpoints.getTokens)" \
            (URL for requesting access and refresh tokens); body:
            \(bodyString)
            """
        )
        
        return self.networkAdaptor(tokensRequest)
            .castToURLResponse()
            // Decoding into `AuthInfo` never fails because all of its
            // properties are optional, so we must try to decode errors
            // first.
            .decodeSpotifyErrorsNoRetry()
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
                        throw SpotifyLocalError.unauthorized(errorMessage)
                    }
                    
					let refreshTokensRequest = endpoint.makePKCETokenRefreshRequest(refreshToken: refreshToken)
					
					let bodyString = String(data: refreshTokensRequest.httpBody!, encoding: .utf8) ?? "nil"
					
                    Self.logger.trace(
                        """
                        POST request to "\(Endpoints.getTokens)" \
                        (URL for refreshing access token); body:
                        \(bodyString)
                        """
                    )
                    
                    let refreshTokensPublisher = self.networkAdaptor(
                        refreshTokensRequest
                    )
                    .castToURLResponse()
                    // Decoding into `AuthInfo` never fails because all of its
                    // properties are optional, so we must try to decode errors
                    // first.
                    .decodeSpotifyErrorsNoRetry()
                    .decodeSpotifyObject(AuthInfo.self)
                    .tryMap { authInfo in
                        
                        Self.logger.trace("received authInfo:\n\(authInfo)")
                        
                        /*
                         Unlike the Authorization Code Flow, a refresh token that
                         has been obtained using the Authorization Code Flow with
                         Proof Key for Code Exchange can be exchanged for an
                         access token only once, after which it becomes invalid.
                         This implies that Spotify should always return a new
                         refresh token in addition to an access token.
                         */
                        if authInfo.accessToken == nil ||
                                authInfo.refreshToken == nil ||
                                authInfo.expirationDate == nil {
                            
                            let errorMessage = """
                                missing properties after refreshing access token \
                                (expected access token, refresh token, \
                                expiration date, and scopes):
                                \(authInfo)
                                """
                            Self.logger.error("\(errorMessage)")
                            throw SpotifyLocalError.other(errorMessage)
                            
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
            return error.anyFailingPublisher()
        }
        
    }
    
}

// MARK: - Custom String Convertible

extension AuthorizationCodeFlowPKCEManager: CustomStringConvertible {
    
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
                AuthorizationCodeFlowPKCEManager(
                    access token: "\(_accessToken ?? "nil")"
                    scopes: \(scopeString)
                    expiration date: \(expirationDateString)
                    refresh token: "\(_refreshToken ?? "nil")"
                    endpoint: "\(endpoint)"
                )
                """
        }
    }

}

// MARK: - Hashable and Equatable -

extension AuthorizationCodeFlowPKCEManager: Hashable {

    /// :nodoc:
    public static func == (
        lhs: AuthorizationCodeFlowPKCEManager,
        rhs: AuthorizationCodeFlowPKCEManager
    ) -> Bool {
        
       return lhs.isEqualTo(other: rhs)
        
    }

}
