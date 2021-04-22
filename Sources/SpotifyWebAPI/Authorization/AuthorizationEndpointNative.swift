import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct AuthorizationEndpointNative: AuthorizationCodeFlowEndpoint {
	/// The client id for your application.
	public let clientId: String
	
	/// The client secret for your application.
	public let clientSecret: String
	
	/// The base 64 encoded authorization header with the client id
	/// and client secret
	let basicBase64EncodedCredentialsHeader: [String: String]

	public init(clientId: String, clientSecret: String) {
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.basicBase64EncodedCredentialsHeader = Headers.basicBase64Encoded(
			clientId: self.clientId,
			clientSecret: self.clientSecret
		)!
	}

	public func makeTokenRequest(code: String, redirectURIWithQuery: URL) -> URLRequest {
		let baseRedirectURI = redirectURIWithQuery
			.removingQueryItems()
			.removingTrailingSlashInPath()
		
		let body = TokensRequest(
			code: code,
			redirectURI: baseRedirectURI,
			clientId: clientId,
			clientSecret: clientSecret
		)
		.formURLEncoded()
	
		var tokensRequest = URLRequest(url: Endpoints.getTokens)
		tokensRequest.httpMethod = "POST"
		tokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
		tokensRequest.httpBody = body

		return tokensRequest
	}

	public func makeTokenRefreshRequest(refreshToken: String) -> URLRequest {
		let headers = basicBase64EncodedCredentialsHeader +
				Headers.formURLEncoded

		let body = RefreshAccessTokenRequest(
			refreshToken: refreshToken
		)
		.formURLEncoded()
		
		var refreshTokensRequest = URLRequest(
			url: Endpoints.getTokens
		)
		refreshTokensRequest.httpMethod = "POST"
		refreshTokensRequest.allHTTPHeaderFields = headers
		refreshTokensRequest.httpBody = body

		return refreshTokensRequest
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(
			keyedBy: AuthInfo.CodingKeys.self
		)
		self.clientId = try container.decode(
			String.self, forKey: .clientId
		)
		self.clientSecret = try container.decode(
			String.self, forKey: .clientSecret
		)
		self.basicBase64EncodedCredentialsHeader = Headers.basicBase64Encoded(
			clientId: self.clientId,
			clientSecret: self.clientSecret
		)!		
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(
			keyedBy: AuthInfo.CodingKeys.self
		)

		try container.encode(
			self.clientId, forKey: .clientId
		)
		try container.encode(
			self.clientSecret, forKey: .clientSecret
		)
	}
}

extension AuthorizationEndpointNative: AuthorizationCodeFlowPKCEEndpoint {
	public func makePKCETokenRequest(code: String, codeVerifier: String, redirectURIWithQuery: URL) -> URLRequest {
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
		
		var tokensRequest = URLRequest(url: Endpoints.getTokens)
		tokensRequest.httpMethod = "POST"
		tokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
		tokensRequest.httpBody = body
		
		return tokensRequest
	}
	
	public func makePKCETokenRefreshRequest(refreshToken: String) -> URLRequest {
		let body = PKCERefreshAccessTokenRequest(
			refreshToken: refreshToken,
			clientId: self.clientId
		)
		.formURLEncoded()
				
		var refreshTokensRequest = URLRequest(
			url: Endpoints.getTokens
		)
		refreshTokensRequest.httpMethod = "POST"
		refreshTokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
		refreshTokensRequest.httpBody = body
		
		return refreshTokensRequest
	}
}
