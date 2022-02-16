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
 authorization information using the Client Credentials Flow.
 
 If you are communicating with a custom backend server, then use
 ``ClientCredentialsFlowProxyBackend`` instead, which does not send the
 `clientId` and `clientSecret` in network requests because these values should
 be securely stored on your backend server.
 
 Usually you should not need to create instances of this type directly.
 ``ClientCredentialsFlowManager`` uses this type internally by inheriting from
 ``ClientCredentialsFlowBackendManager``<``ClientCredentialsFlowClientBackend``>.
 
 Read more about the [Client Credentials Flow][1]

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
 */
public struct ClientCredentialsFlowClientBackend: ClientCredentialsFlowBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "ClientCredentialsFlowClientBackend", level: .critical
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
     
     Read more about [registering your application][1].

     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public let clientSecret: String
    
    /// The base 64 encoded authorization header with the client id
    /// and client secret
    private let basicBase64EncodedCredentialsHeader: [String: String]

    /**
     Creates an instance that manages the authorization process for the Client
     Credentials Flow by communicating *directly* with the Spotify web API.
     
     Usually you should not need to create instances of this type directly.
     ``ClientCredentialsFlowManager`` uses this type internally by inheriting
     from
     ``ClientCredentialsFlowBackendManager``<``ClientCredentialsFlowClientBackend``>.

     Read more about the [Client Credentials Flow][1]

     - Parameters:
       - clientId: The client id that you received when you [registered your
             application][2].
       - clientSecret: The client secret that you received when you [registered
             your application][2].
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
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
     Makes a request for the authorization information.

     This method is called by either the
     ``ClientCredentialsFlowBackendManager/authorize()`` or
     ``ClientCredentialsFlowBackendManager/refreshTokens(onlyIfExpired:tolerance:)``
     methods of ``ClientCredentialsFlowBackendManager``. The client credentials
     flow does not provide a refresh token, so in both cases, the same network
     request is made.

     This method returns the authorization information as JSON data that can be
     decoded into ``AuthInfo``. The ``AuthInfo/accessToken`` and
     ``AuthInfo/expirationDate`` (which can be decoded from the "expires_in"
     JSON key) properties should be non-`nil`. For example:
     
     ```
     {
         "access_token": "NgCXRKc...MzYjw",
         "token_type": "bearer",
         "expires_in": 3600,
     }
     ```
     
     Read about the underlying request that is made to Spotify in order to
     retrieve this data [here][1].
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/#request-authorization
     */
    public func makeClientCredentialsTokensRequest(
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {

        let body = ClientCredentialsTokensRequest()
            .formURLEncoded()

        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
    
        Self.logger.trace(
            """
            POST request to "\(Endpoints.getTokens)"; body:
            \(bodyString)
            """
        )
        
        let headers = self.basicBase64EncodedCredentialsHeader.merging(
            Headers.formURLEncoded, uniquingKeysWith: { lhs, rhs in lhs }
        )
        
        var tokensRequest = URLRequest(url: Endpoints.getTokens)
        tokensRequest.httpMethod = "POST"
        tokensRequest.allHTTPHeaderFields = headers
        tokensRequest.httpBody = body

        // `URLSession.defaultNetworkAdaptor` is used so that the test targets
        // can substitute different networking clients for testing purposes. In
        // your own code, you can just use `URLSession.dataTaskPublisher`
        // directly, or a different networking client, if necessary.
        return URLSession.defaultNetworkAdaptor(
            request: tokensRequest
        )

    }

}

extension ClientCredentialsFlowClientBackend: CustomStringConvertible {
    
    public var description: String {
        return """
            ClientCredentialsFlowClientBackend(
                clientId: "\(self.clientId)"
                clientSecret: "\(self.clientSecret)"
            )
            """
    }

}
