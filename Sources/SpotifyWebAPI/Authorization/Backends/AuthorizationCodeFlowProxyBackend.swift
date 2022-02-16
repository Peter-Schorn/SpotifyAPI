import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Logging

#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

/**
 Communicates with a backend server that you setup in order to retrieve the
 authorization information and refresh the access token using the Authorization
 Code Flow.

 This server must have the following endpoints:
 
 * ``tokensURL``: Accepts a post request with the authorization code in the
   body in x-www-form-urlencoded format and must return the authorization
   information. See
   ``requestAccessAndRefreshTokens(code:redirectURIWithQuery:)`` for more
   information.
 
 * ``tokenRefreshURL``: Accepts a post request with the refresh token in the body
   in x-www-form-urlencoded format and must return the authorization
   information. See ``refreshTokens(refreshToken:)`` for more information.

 Instead of creating your own server, you can use [SpotifyAPIServer][2] with
 this type by assigning the /authorization-code-flow/retrieve-tokens endpoint to
 ``tokensURL`` and the /authorization-code-flow/refresh-tokens endpoint to
 ``tokenRefreshURL``.

 In contrast with ``AuthorizationCodeFlowClientBackend``, which can be used if
 you are communicating directly with Spotify, this type does not send the
 `clientId`, or `clientSecret` in network requests because these values should
 be securely stored on your backend server.

 This conforms to the ["Token Swap and Refresh"][3] standard used in the Spotify
 iOS SDK.
 
 Read more about the [Authorization Code Flow][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 [2]: https://github.com/Peter-Schorn/SpotifyAPIServer
 [3]: https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
 */
public struct AuthorizationCodeFlowProxyBackend: AuthorizationCodeFlowBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "AuthorizationCodeFlowProxyBackend", level: .critical
    )
    
    /**
     The client id that you received when you registered your application.
     
     Read more about [registering your application][1].

     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
	public let clientId: String

    /**
     The URL to your custom backend server that accepts a post request with the
     authorization code in the body in x-www-form-urlencoded format and which
     must return the authorization information.
     
     The [/authorization-code-flow/retrieve-tokens][1] endpoint of
     SpotifyAPIServer can be used for this URL.

     See ``requestAccessAndRefreshTokens(code:redirectURIWithQuery:)`` for more
     information.
     
     [1]: https://github.com/Peter-Schorn/SpotifyAPIServer#post-authorization-code-flowretrieve-tokens
     */
	public let tokensURL: URL

    /**
     The URL to your custom backend server that accepts a post request with the
     refresh token in the body in x-www-form-urlencoded format and which must
     return the authorization information.
     
     The [/authorization-code-flow/refresh-tokens][1] endpoint of
     SpotifyAPIServer can be used for this URL.

     See ``refreshTokens(refreshToken:)`` for more information.
     
     [1]: https://github.com/Peter-Schorn/SpotifyAPIServer#post-authorization-code-flowrefresh-tokens
     */
    public let tokenRefreshURL: URL

    /**
     A hook for decoding an error produced by your backend server into an error
     type, which will then be thrown to downstream subscribers.

     After the response from your server is received following a call to
     ``requestAccessAndRefreshTokens(code:redirectURIWithQuery:)`` or
     ``refreshTokens(refreshToken:)``, this function is called with the raw data
     and response metadata from the server. If you return an error from this
     function, then this error will be thrown to downstream subscribers. If you
     return `nil`, then the response from the server will be passed through
     unmodified to downstream subscribers.

     - Important: Do not use this function to decode the documented error
           objects produced by Spotify, such as ``SpotifyAuthenticationError``.
           This will be done elsewhere. Only use this function to decode error
           objects produced by your custom backend server.
     
     **Thread Safety**

     No guarantees are made about which thread this function will be called on.
     Do not mutate this property while a request is being made for the
     authorization information.
     */
    public var decodeServerError: ((Data, HTTPURLResponse) -> Error?)?

    /**
     Creates an instance that manages the authorization process for the
     Authorization Code Flow by communicating with a custom backend server.
     
     This type requires a custom backend server that can store your client
     secret and redirect URI. It conforms to the ["Token Swap and Refresh"][2]
     standard used in the Spotify iOS SDK.
     
     Instead of creating your own server, you can use [SpotifyAPIServer][3] with
     this type by assigning the /authorization-code-flow/retrieve-tokens
     endpoint to ``tokensURL`` and the /authorization-code-flow/refresh-tokens
     endpoint to ``tokenRefreshURL``.

     - Parameters:
       - clientId: The client id that you received when you [registered your
             application][4].
       - tokensURL: The URL to a server that accepts a post request with the
             authorization code in the body in "x-www-form-urlencoded" format
             and which must return the authorization information. See
             ``requestAccessAndRefreshTokens(code:redirectURIWithQuery:)`` for
             more information.
       - tokenRefreshURL: The URL to a server that accepts a post request with
             the refresh token in the body in "x-www-form-urlencoded" format and
             which must return the new authorization information. See
             ``refreshTokens(refreshToken:)`` for more information.
       - decodeServerError: A hook for decoding an error produced by your
             backend server into an error type, which will then be thrown to
             downstream subscribers. Do not use this function to decode the
             documented error objects produced by Spotify, such as
             ``SpotifyAuthenticationError``. This will be done elsewhere.
     
     Read more about the [Authorization Code Flow][1]

     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     [2]: https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
     [3]: https://github.com/Peter-Schorn/SpotifyAPIServer
     [4]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
	public init(
        clientId: String,
        tokensURL: URL,
        tokenRefreshURL: URL,
        decodeServerError: ((Data, HTTPURLResponse) -> Error?)? = nil
    ) {
		self.clientId = clientId
		self.tokensURL = tokensURL
		self.tokenRefreshURL = tokenRefreshURL
        self.decodeServerError = decodeServerError
	}

    /**
     Exchanges an authorization code for the access and refresh tokens.
     
     After validating the `redirectURIWithQuery`, the
     ``AuthorizationCodeFlowBackendManager/requestAccessAndRefreshTokens(redirectURIWithQuery:state:)``
     method of ``AuthorizationCodeFlowBackendManager`` calls this method in
     order to retrieve the authorization information.
     
     If the `redirectURIWithQuery` contains an error parameter or the value for
     the state parameter doesn't match the value passed in as an argument to the
     above method, then an error will be thrown *before* this method is called.
     
     This method makes a post request to ``tokensURL``. The headers will contain
     the "Content-Type: application/x-www-form-urlencoded" header and the body
     will contain the following in x-www-form-urlencoded format:
     
     * "grant_type": set to "authorization_code"
     * "code": the authorization code
     * "redirect_uri": the redirect URI
     
     For example: "grant_type=authorization_code&code=asd...xbdjc
     &redirect_uri=http://localhost:8080". See ``ProxyTokensRequest``, which is
     used to encode this data.
     
     The endpoint at ``tokensURL`` must return the authorization information as
     JSON data that can be decoded into ``AuthInfo``. The
     ``AuthInfo/accessToken``, ``AuthInfo/refreshToken``, and
     ``AuthInfo/expirationDate`` (which can be decoded from the "expires_in"
     JSON key) properties must be non-`nil`. For example:
     
     ```
     {
         "access_token": "NgCXRK...MzYjw",
         "token_type": "Bearer",
         "scope": "user-read-private user-read-email",
         "expires_in": 3600,
         "refresh_token": "NgAagA...Um_SHo"
     }
     ```
     
     Any error that your backend server receives from the Spotify web API, along
     with the headers and status code, should be forwarded directly to the
     client, as this library already knows how to decode these errors.
     
     After the response is retrieved from the server, ``decodeServerError`` is
     called in order to decode any custom error objects that your server might
     return.

     Read about the underlying request that must be made to Spotify by your
     server in order to retrieve this data [here][1].
     
     - Parameters:
       - code: The authorization code, which will also be present in
             `redirectURIWithQuery`.
       - redirectURIWithQuery: The URL that spotify redirected to after the user
             logged in to their Spotify account, with query parameters appended
             to it.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-access-token
     */
	public func requestAccessAndRefreshTokens(
        code: String,
        redirectURIWithQuery: URL
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
		
        // This must match the redirectURI provided when making the
        // authorization URL.
        let baseRedirectURI = redirectURIWithQuery
            .removingQueryItems()
            .removingTrailingSlashInPath()

        let body = ProxyTokensRequest(
            code: code,
            redirectURI: baseRedirectURI
        )
        .formURLEncoded()

        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
        Self.logger.trace(
            """
            POST request to "\(self.tokensURL)" \
            (URL for requesting access and refresh tokens); body:
            \(bodyString)
            """
        )

		var tokensRequest = URLRequest(url: self.tokensURL)
		tokensRequest.httpMethod = "POST"
		tokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
		tokensRequest.httpBody = body

        // `URLSession.defaultNetworkAdaptor` is used so that the test targets
        // can substitute different networking clients for testing purposes. In
        // your own code, you can just use `URLSession.dataTaskPublisher`
        // directly, or a different networking client, if necessary.
        return URLSession.defaultNetworkAdaptor(
            request: tokensRequest
        )
        .tryMap { data, response in
            if let error = self.decodeServerError?(data, response) {
                throw error
            }
            return (data: data, response: response)
        }
        .eraseToAnyPublisher()
        
	}

    /**
     Refreshes an access token using the refresh token.
     
     Access tokens expire after an hour, after which they must be refreshed
     using this method. This method will be called by the
     ``AuthorizationCodeFlowBackendManager/refreshTokens(onlyIfExpired:tolerance:)``
     method of ``AuthorizationCodeFlowBackendManager``.

     This method makes a post request to ``tokenRefreshURL``. The headers will
     contain the "Content-Type: application/x-www-form-urlencoded" header and
     the body will contain the following in x-www-form-urlencoded format:
     
     * "grant_type": set to "refresh_token"
     * "refresh_token": the refresh token
     
     For example: "grant_type=refresh_token&refresh_token=djsnd...dnvnbfr". See
     ``RefreshTokensRequest``, which is used to encode this data.
     
     The endpoint at ``tokenRefreshURL`` must return the authorization
     information as JSON data that can be decoded into ``AuthInfo``. The
     ``AuthInfo/accessToken`` and ``AuthInfo/expirationDate`` (which can be
     decoded from the "expires_in" JSON key) properties must be non-`nil`. For
     example:

     ```
     {
         "access_token": "NgCXRK...MzYjw",
         "token_type": "Bearer",
         "scope": "user-read-private user-read-email",
         "expires_in": 3600
     }
     ```
     
     Any error that your backend server receives from the Spotify web API, along
     with the headers and status code, should be forwarded directly to the
     client, as this library already knows how to decode these errors.
     
     After the response is retrieved from the server, ``decodeServerError`` is
     called in order to decode any custom error objects that your server might
     return.

     Read about the underlying request that must be made to Spotify by your
     server in order to retrieve this data [here][1].
     
     - Parameters:
       - code: The authorization code, which will also be present in
             `redirectURIWithQuery`.
       - redirectURIWithQuery: The URL that spotify redirected to after the user
             logged in to their Spotify account, with query parameters appended
             to it.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-a-refreshed-access-token
     */
	public func refreshTokens(
        refreshToken: String
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
		
        let body = RefreshTokensRequest(
			refreshToken: refreshToken
		)
		.formURLEncoded()
				
        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
        
        Self.logger.trace(
            """
            POST request to "\(self.tokenRefreshURL)" \
            (URL for refreshing access token); body:
            \(bodyString)
            """
        )

		var refreshTokensRequest = URLRequest(url: self.tokenRefreshURL)
		refreshTokensRequest.httpMethod = "POST"
        refreshTokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
		refreshTokensRequest.httpBody = body

        // `URLSession.defaultNetworkAdaptor` is used so that the test targets
        // can substitute different networking clients for testing purposes. In
        // your own code, you can just use `URLSession.dataTaskPublisher`
        // directly, or a different networking client, if necessary.
        return URLSession.defaultNetworkAdaptor(
            request: refreshTokensRequest
        )
        .tryMap { data, response in
            if let error = self.decodeServerError?(data, response) {
                throw error
            }
            return (data: data, response: response)
        }
        .eraseToAnyPublisher()
        
	}
}

extension AuthorizationCodeFlowProxyBackend: CustomStringConvertible {
    
    public var description: String {
        return """
            AuthorizationCodeFlowProxyBackend(
                clientId: "\(self.clientId)"
                tokenURL: "\(self.tokensURL)"
                tokenRefreshURL: "\(self.tokenRefreshURL)"
            )
            """
    }

}

extension AuthorizationCodeFlowProxyBackend: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.clientId == rhs.clientId &&
                lhs.tokensURL == rhs.tokensURL &&
                lhs.tokenRefreshURL == rhs.tokenRefreshURL
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.clientId)
        hasher.combine(self.tokensURL)
        hasher.combine(self.tokenRefreshURL)
    }

}

extension AuthorizationCodeFlowProxyBackend: Codable {

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case tokensURL = "tokens_url"
        case tokenRefreshURL = "token_refresh_url"
    }

}
