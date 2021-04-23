import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Logging

public struct AuthorizationCodeFlowProxyBackend: AuthorizationCodeFlowBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "AuthorizationCodeFlowProxyBackend", level: .critical
    )
    
    /// The client id for your application.
	public let clientId: String

	let tokenURL: URL
	let tokenRefreshURL: URL

	public init(clientId: String, tokenURL: URL, tokenRefreshURL: URL) {
		self.clientId = clientId
		self.tokenURL = tokenURL
		self.tokenRefreshURL = tokenRefreshURL
	}

	public func makeTokenRequest(
        code: String,
        redirectURIWithQuery: URL
    ) throws -> URLRequest {
		
        let body = RemoteTokensRequest(code: code)
            .formURLEncoded()

        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
        Self.logger.trace(
            """
            POST request to "\(self.tokenURL)" \
            (URL for requesting access and refresh tokens); body:
            \(bodyString)
            """
        )

		var tokensRequest = URLRequest(url: self.tokenURL)
		tokensRequest.httpMethod = "POST"
		tokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
		tokensRequest.httpBody = body

		return tokensRequest
	}

	public func makeRefreshTokenRequest(refreshToken: String) -> URLRequest {
		
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

		return refreshTokensRequest
	}
}

// MARK: - PKCE -

public struct AuthorizationCodeFlowPKCEProxyBackend: AuthorizationCodeFlowPKCEBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "AuthorizationCodeFlowProxyBackend", level: .critical
    )
    
    /// The client id for your application.
    public let clientId: String

    let tokenURL: URL
    let tokenRefreshURL: URL

    public init(clientId: String, tokenURL: URL, tokenRefreshURL: URL) {
        self.clientId = clientId
        self.tokenURL = tokenURL
        self.tokenRefreshURL = tokenRefreshURL
    }

    public func makePKCETokenRequest(
        code: String,
        codeVerifier: String,
        redirectURIWithQuery: URL
    ) throws -> URLRequest {
        
        let body = RemotePKCETokensRequest(
            code: code,
            codeVerifier: codeVerifier
        )
        .formURLEncoded()

        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
        Self.logger.trace(
            """
            POST request to "\(self.tokenURL)" \
            (URL for requesting access and refresh tokens); body:
            \(bodyString)
            """
        )

        var tokensRequest = URLRequest(url: self.tokenURL)
        tokensRequest.httpMethod = "POST"
        tokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
        tokensRequest.httpBody = body

        return tokensRequest
    }

    public func makePKCERefreshTokenRequest(
        refreshToken: String
    ) -> URLRequest {
        
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

        return refreshTokensRequest
    }
}
