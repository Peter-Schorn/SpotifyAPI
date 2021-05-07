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
 authoriation information and refresh the access token using the [Authorization
 Code Flow][1].

 Compare with `AuthorizationCodeFlowClientBackend`.

 This type requires a custom backend server that can store your client secret
 and redirect URI. It conforms to the ["Token Swap and Refresh"][2] standard
 used in the Spotify iOS SDK.

 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 [2]: https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
 */
public struct AuthorizationCodeFlowProxyBackend: AuthorizationCodeFlowBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "AuthorizationCodeFlowProxyBackend", level: .critical
    )
    
    /**
     The client id that you received when you [registered your application][1].
     
     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
	public let clientId: String

    /**
     The URL to your custom backend server that accepts a post request with the
     authorization code in the body in x-www-form-urlencoded format and which
     must return the authorization information.
     
     See `self.makeTokensRequest(code:redirectURIWithQuery:)` for more
     information.
     */
	public let tokensURL: URL

    /**
     The URL to your custom backend server that accepts a post request with the
     refresh token in the body in x-www-form-urlencoded format and which must
     return the authorization information.
     
     See `self.makeRefreshTokenRequest(refreshToken:)` for more information.
     */
    public let tokenRefreshURL: URL

    /**
     A hook for decoding an error produced by your backend server into an error
     type, which will then be thrown to downstream subscribers.

     After the response from your server is received following a call to
     `self.makeTokensRequest(code:redirectURIWithQuery:)` or
     `self.makeRefreshTokenRequest(refreshToken:)`, this function is called with
     the raw data and response metadata from the server. If you return an error
     from this function, then this error will be thrown to downstream
     subscribers. If you return `nil`, then the response from the server will be
     passed through unmodified to downstream subscribers.

     - Important: Do not use this function to decode the documented error
           objects produced by Spotify, such as `SpotifyAuthenticationError`.
           This will be done elsewhere. Only use this function to decode error
           objects produced by your custom backend server.
     
     # Thread Safety

     No guarentees are made about which thread this function will be called on.
     Do not mutate this property while a request is being made for the
     authorization information.
     */
    public var decodeServerError: ((Data, HTTPURLResponse) -> Error?)?

    /**
     Creates an instance that manages the authorization process for the
     [Authorization Code Flow][1] by communicating with a custom backend server.
     
     This type requires a custom backend server that can store your client
     secret and redirect URI. It conforms to the ["Token Swap and Refresh"][2]
     standard used in the Spotify iOS SDK.

     - Parameters:
       - clientId: The client id that you received when you [registered your
             application][3].
       - tokensURL: The URL to a server that accepts a post request with the
             authorization code in the body in "x-www-form-urlencoded" format
             and which must return the authorization information. See
             `self.makeTokensRequest(code:redirectURIWithQuery:)` for more
             information.
       - tokenRefreshURL: The URL to a server that accepts a post request with
             the refresh token in the body in "x-www-form-urlencoded" format and
             which must return the new authorization information. See
             `self.makeRefreshTokenRequest(refreshToken:)` for more information.
       - decodeServerError: A hook for decoding an error produced by your
             backend server into an error type, which will then be thrown to
             downstream subscribers Do not use this function to decode the
             documented error objects produced by Spotify, such as
             `SpotifyAuthenticationError`. This will be done elsewhere.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
     [3]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
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
     
     This method makes a post request to `self.tokensURL`. The headers will
     contain the "Content-Type: application/x-www-form-urlencoded" header
     and the body will contain a key called "code" with the value set to the
     authorization code in x-www-form-urlencoded format. For example:
     "code=AQDy8...xMhKNA". See `RemoteTokensRequest`.
     
     The endpoint at `self.tokensURL` must return the authorization information
     as JSON data that can be decoded into `AuthInfo`. The `accessToken`,
     `refreshToken`, and `expirationDate` (which can be decoded from the
     "expires_in" JSON key) properties must be non-`nil`. For example:
     
     ```
     {
         "access_token": "NgCXRK...MzYjw",
         "token_type": "Bearer",
         "scope": "user-read-private user-read-email",
         "expires_in": 3600,
         "refresh_token": "NgAagA...Um_SHo"
     }
     ```
     
     After the response is retrieved from the server, `self.decodeServerError`
     is called in order to decode any custom error objects that your server
     might return.

     Read about the underlying request that must be made to Spotify by your
     server in order to retrieve this data [here][1].
     
     - Parameters:
       - code: The authorization code, which will also be present in
             `redirectURIWithQuery`.
       - redirectURIWithQuery: The URL that spotify redirected to after the user
             logged in to their Spotify account, with query parameters appended
             to it.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#:~:text=2.%20have%20your%20application%20request%20refresh%20and%20access%20tokens%3B%20spotify%20returns%20access%20and%20refresh%20tokens
     */
	public func makeTokensRequest(
        code: String,
        redirectURIWithQuery: URL
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
		
        let body = RemoteTokensRequest(code: code)
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
        // can substitue different networking clients for testing purposes.
        // In your own code, you can just use `URLSession.dataTaskPublisher`
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
     using this method. This method will be called by
     `AuthorizationCodeFlowBackendManager.refreshTokens(onlyIfExpired:tolerance:)`.

     This method makes a post request to `self.tokenRefreshURL`. The headers
     will contain the "Content-Type: application/x-www-form-urlencoded" header
     and the body will contain a key called "refresh_token" with the value set
     to the the refresh token and a key called "grant_type" with the value set
     to "refresh_token" in x-www-form-urlencoded format. For example:
     "refresh_token=AQDy8...xMhKNA&grant_type=refresh_token". See
     `RefreshAccessTokenRequest`.
     
     The endpoint at `self.tokenRefreshURL` must return the authorization
     information as JSON data that can be decoded into `AuthInfo`. The
     `accessToken`, and `expirationDate` (which can be decoded from the
     "expires_in" JSON key) properties must be non-`nil`. For example:

     ```
     {
         "access_token": "NgCXRK...MzYjw",
         "token_type": "Bearer",
         "scope": "user-read-private user-read-email",
         "expires_in": 3600
     }
     ```
     
     After the response is retrieved from the server, `self.decodeServerError`
     is called in order to decode any custom error objects that your server
     might return.

     Read about the underlying request that must be made to Spotify by your
     server in order to retrieve this data [here][1].
     
     - Parameters:
       - code: The authorization code, which will also be present in
             `redirectURIWithQuery`.
       - redirectURIWithQuery: The URL that spotify redirected to after the user
             logged in to their Spotify account, with query parameters appended
             to it.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#:~:text=4.%20requesting%20a%20refreshed%20access%20token%3B%20spotify%20returns%20a%20new%20access%20token%20to%20your%20app
     */
	public func makeRefreshTokenRequest(
        refreshToken: String
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
		
        let body = RefreshAccessTokenRequest(
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
        // can substitue different networking clients for testing purposes.
        // In your own code, you can just use `URLSession.dataTaskPublisher`
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
