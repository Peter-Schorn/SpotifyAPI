import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct AuthorizationCodeFlowProxyBackend: AuthorizationCodeFlowBackend {
    /// The client id for your application.
    public let clientId: String

    let tokenURL: URL
    let tokenRefreshURL: URL

    public init(clientId: String, tokenURL: URL, tokenRefreshURL: URL) {
        self.clientId = clientId
        self.tokenURL = tokenURL
        self.tokenRefreshURL = tokenRefreshURL
    }

    public func makeTokenRequest(code: String, redirectURIWithQuery: URL) -> URLRequest {
        let body = RemoteTokensRequest(code: code)
            .formURLEncoded()
                
        var tokensRequest = URLRequest(url: tokenURL)
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
                
        var refreshTokensRequest = URLRequest(url: tokenRefreshURL)
        refreshTokensRequest.httpMethod = "POST"
        refreshTokensRequest.httpBody = body

        return refreshTokensRequest
    }
}
