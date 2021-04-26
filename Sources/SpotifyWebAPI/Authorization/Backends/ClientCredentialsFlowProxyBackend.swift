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

public struct ClientCredentialsFlowProxyBackend: ClientCredentialsFlowBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "ClientCredentialsFlowProxyBackend", level: .critical
    )

    public let tokenURL: URL

    public init(tokenURL: URL) {
        self.tokenURL = tokenURL
    }

    public func makeClientCredentialsTokensRequest(
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {

        let body = ClientCredentialsTokenRequest()
            .formURLEncoded()
        
        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
        Self.logger.trace(
            """
            POST request to "\(Endpoints.getTokens)"; body:
            \(bodyString)
            """
        )

        var tokensRequest = URLRequest(url: self.tokenURL)
        tokensRequest.httpMethod = "POST"
        tokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
        tokensRequest.httpBody = body

        return URLSession.defaultNetworkAdaptor(
            request: tokensRequest
        )

    }

}
