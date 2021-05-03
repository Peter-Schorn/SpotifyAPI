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
     authorization code in the body in "x-www-form-urlencoded" format and which
     must return the authorization information. See
     `self.makeTokensRequest(code:redirectURIWithQuery:)` for more information.
     */
	public let tokensURL: URL

    /**
     The URL to your custom backend server that accepts a post request with the
     refresh token in the body in "x-www-form-urlencoded" format and which must
     return the authorization information. See
     `self.makeRefreshTokenRequest(refreshToken:)` for more information.
     */
    public let tokenRefreshURL: URL

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
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
     [3]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
	public init(clientId: String, tokensURL: URL, tokenRefreshURL: URL) {
		self.clientId = clientId
		self.tokensURL = tokensURL
		self.tokenRefreshURL = tokenRefreshURL
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

        return URLSession.defaultNetworkAdaptor(
            request: tokensRequest
        )
        
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

        return URLSession.defaultNetworkAdaptor(
            request: refreshTokensRequest
        )
        
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
