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
 Communicates *directly* with the Spotify web API in order to retrieve the
 authorization information and refresh the access token using the Authorization
 Code Flow.

 If you are communicating with a custom backend server, then use
 ``AuthorizationCodeFlowProxyBackend`` instead, which does not send the
 `clientId` and `clientSecret` in network requests because these values should
 be securely stored on your backend server.

 Usually you should not need to create instances of this type directly.
 ``AuthorizationCodeFlowManager`` uses this type internally by inheriting from
 ``AuthorizationCodeFlowBackendManager``<``AuthorizationCodeFlowClientBackend``>.
 
 Read more about the [Authorization Code Flow][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 */
public struct AuthorizationCodeFlowClientBackend: AuthorizationCodeFlowBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "AuthorizationCodeFlowClientBackend", level: .critical
    )

    /**
     The client id that you received when you registered your application.
    
     Read more about [registering your application][1].

     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public let clientId: String
	
    /**
     The client secret that you received when you registered your
     application.
     
     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
	public let clientSecret: String
	
	/// The base 64 encoded authorization header with the client id
	/// and client secret
	private let basicBase64EncodedCredentialsHeader: [String: String]

    /**
     Creates an instance that manages the authorization process for the
     [Authorization Code Flow][1] by communicating *directly* with the Spotify
     web API.
     
     Usually you should not need to create instances of this type directly.
     ``AuthorizationCodeFlowManager`` uses this type internally by inheriting
     from
     ``AuthorizationCodeFlowBackendManager``<``AuthorizationCodeFlowClientBackend``>.

     - Parameters:
       - clientId: The client id that you received when you [registered your
             application][2].
       - clientSecret: The client secret that you received when you [registered
             your application][2].
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     [2]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
	public init(clientId: String, clientSecret: String) {
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.basicBase64EncodedCredentialsHeader = Headers.basicBase64Encoded(
			clientId: self.clientId,
			clientSecret: self.clientSecret
		)!
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
     
     This method returns the authorization information as JSON data that can be
     decoded into ``AuthInfo``. The ``AuthInfo/accessToken``,
     ``AuthInfo/refreshToken``, and ``AuthInfo/expirationDate`` (which can be
     decoded from the "expires_in" JSON key) properties should be non-`nil`. For
     example:
     
     ```
     {
         "access_token": "NgCXRK...MzYjw",
         "token_type": "Bearer",
         "scope": "user-read-private user-read-email",
         "expires_in": 3600,
         "refresh_token": "NgAagA...Um_SHo"
     }
     ```
     
     Read about the underlying request that is made to Spotify in order to
     retrieve this data [here][1].

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
        
		let baseRedirectURI = redirectURIWithQuery
			.removingQueryItems()
			.removingTrailingSlashInPath()
		
		let body = TokensRequest(
			code: code,
			redirectURI: baseRedirectURI,
			clientId: self.clientId,
			clientSecret: self.clientSecret
		)
		.formURLEncoded()
        
        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
        
        Self.logger.trace(
            """
            POST request to "\(Endpoints.getTokens)" \
            (URL for requesting access and refresh tokens); body:
            \(bodyString)
            """
        )
	
		var tokensRequest = URLRequest(url: Endpoints.getTokens)
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
        
	}

    /**
     Refreshes an access token using the refresh token.

     Access tokens expire after an hour, after which they must be refreshed
     using this method. This method will be called by the
     ``AuthorizationCodeFlowBackendManager/refreshTokens(onlyIfExpired:tolerance:)``
     method of ``AuthorizationCodeFlowBackendManager``.

     This method returns the authorization information as JSON data that can be
     decoded into ``AuthInfo``. The ``AuthInfo/accessToken`` and
     ``AuthInfo/expirationDate`` (which can be decoded from the "expires_in"
     JSON key) properties should be non-`nil`. For example:

     ```
     {
        "access_token": "NgCXRK...MzYjw",
        "token_type": "Bearer",
        "scope": "user-read-private user-read-email",
        "expires_in": 3600
     }
     ```

     Read about the underlying request that is made to Spotify in order to
     retrieve this data [here][1].

     - Parameter refreshToken: The refresh token, which can be exchanged for
           a new access token.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-a-refreshed-access-token
     */
	public func refreshTokens(
        refreshToken: String
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
		
        let headers = self.basicBase64EncodedCredentialsHeader.merging(
            Headers.formURLEncoded, uniquingKeysWith: { lhs, rhs in lhs }
        )

		let body = RefreshTokensRequest(
			refreshToken: refreshToken
		)
		.formURLEncoded()
        
        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
        
        Self.logger.trace(
            """
            POST request to "\(Endpoints.getTokens)" \
            (URL for refreshing access token); body:
            \(bodyString)
            """
        )
		
        var refreshTokensRequest = URLRequest(
			url: Endpoints.getTokens
		)
		refreshTokensRequest.httpMethod = "POST"
		refreshTokensRequest.allHTTPHeaderFields = headers
		refreshTokensRequest.httpBody = body

        // `URLSession.defaultNetworkAdaptor` is used so that the test targets
        // can substitute different networking clients for testing purposes. In
        // your own code, you can just use `URLSession.dataTaskPublisher`
        // directly, or a different networking client, if necessary.
        return URLSession.defaultNetworkAdaptor(
            request: refreshTokensRequest
        )
        
	}
    
}

extension AuthorizationCodeFlowClientBackend: Codable {
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(
			keyedBy: CodingKeys.self
		)
		let clientId = try container.decode(
			String.self, forKey: .clientId
		)
		let clientSecret = try container.decode(
			String.self, forKey: .clientSecret
		)
        self.init(
            clientId: clientId,
            clientSecret: clientSecret
        )
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(
			keyedBy: CodingKeys.self
		)

		try container.encode(
			self.clientId, forKey: .clientId
		)
		try container.encode(
			self.clientSecret, forKey: .clientSecret
		)
	}
    
    private enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
    }
    
}

extension AuthorizationCodeFlowClientBackend: CustomStringConvertible {
    
    public var description: String {
        return """
            AuthorizationCodeFlowClientBackend(
                clientId: "\(self.clientId)"
                clientSecret: "\(self.clientSecret)"
            )
            """
    }

}
