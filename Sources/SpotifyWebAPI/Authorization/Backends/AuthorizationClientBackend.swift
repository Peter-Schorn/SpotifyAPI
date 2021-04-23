import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

public struct AuthorizationCodeFlowClientBackend: AuthorizationCodeFlowBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "AuthorizationCodeFlowClientBackend", level: .critical
    )

    /// The client id for your application.
	public let clientId: String
	
	/// The client secret for your application.
	public let clientSecret: String
	
	/// The base 64 encoded authorization header with the client id
	/// and client secret
	private let basicBase64EncodedCredentialsHeader: [String: String]

	public init(clientId: String, clientSecret: String) {
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.basicBase64EncodedCredentialsHeader = Headers.basicBase64Encoded(
			clientId: self.clientId,
			clientSecret: self.clientSecret
		)!
	}

	public func makeTokenRequest(
        code: String,
        redirectURIWithQuery: URL
    ) -> URLRequest {
        
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

		return tokensRequest
	}

	public func makeRefreshTokenRequest(refreshToken: String) -> URLRequest {
		let headers = self.basicBase64EncodedCredentialsHeader +
				Headers.formURLEncoded

		let body = RefreshAccessTokenRequest(
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

		return refreshTokensRequest
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

// MARK: - PKCE -

public struct  AuthorizationCodeFlowPKCEClientBackend: AuthorizationCodeFlowPKCEBackend {
	
    /// The logger for this struct.
    public static var logger = Logger(
        label: "AuthorizationCodeFlowClientBackend", level: .critical
    )

    /// The client id for your application.
    public let clientId: String
    
    public init(clientId: String) {
        self.clientId = clientId
    }

    public func makePKCETokenRequest(
        code: String,
        codeVerifier: String,
        redirectURIWithQuery: URL
    ) -> URLRequest {
        
		// This must match the redirectURI provided when making the
		// authorization URL.
		let baseRedirectURI = redirectURIWithQuery
			.removingQueryItems()
			.removingTrailingSlashInPath()
				
		let body = PKCETokensRequest(
			code: code,
			redirectURI: baseRedirectURI,
			clientId: self.clientId,
			codeVerifier: codeVerifier
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
		
		return tokensRequest
	}

    public func makePKCERefreshTokenRequest(refreshToken: String) -> URLRequest {
		
        let body = PKCERefreshAccessTokenRequest(
			refreshToken: refreshToken,
			clientId: self.clientId
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
		refreshTokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
		refreshTokensRequest.httpBody = body
		
		return refreshTokensRequest
	}
}

extension AuthorizationCodeFlowPKCEClientBackend: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
    }

}
