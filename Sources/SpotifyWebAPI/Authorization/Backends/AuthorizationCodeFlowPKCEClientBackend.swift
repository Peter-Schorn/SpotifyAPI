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

    public func makePKCETokensRequest(
        code: String,
        codeVerifier: String,
        redirectURIWithQuery: URL
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        
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
        
        return URLSession.defaultNetworkAdaptor(
            request: tokensRequest
        )
        
    }

    public func makePKCERefreshTokenRequest(
        refreshToken: String
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        
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
        
        return URLSession.defaultNetworkAdaptor(
            request: refreshTokensRequest
        )
        
    }
}

extension AuthorizationCodeFlowPKCEClientBackend: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
    }

}
