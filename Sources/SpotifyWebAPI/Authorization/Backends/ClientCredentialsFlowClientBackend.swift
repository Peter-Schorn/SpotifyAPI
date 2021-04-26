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

public struct ClientCredentialsFlowClientBackend: ClientCredentialsFlowBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "ClientCredentialsFlowClientBackend", level: .critical
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
        
        let headers = self.basicBase64EncodedCredentialsHeader +
                Headers.formURLEncoded
        
        var tokensRequest = URLRequest(url: Endpoints.getTokens)
        tokensRequest.httpMethod = "POST"
        tokensRequest.allHTTPHeaderFields = headers
        tokensRequest.httpBody = body

        return URLSession.defaultNetworkAdaptor(
            request: tokensRequest
        )

    }

}
