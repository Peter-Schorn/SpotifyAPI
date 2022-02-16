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
 authorization information using the Client Credentials Flow.
 
 The server must have an endpoint (``tokensURL``) that accepts a post request
 for the authorization information from Spotify. See
 ``makeClientCredentialsTokensRequest()`` for more information.

 Instead of creating your own server, you can use [SpotifyAPIServer][2] with
 this type by assigning the /client-credentials-flow/retrieve-tokens endpoint to
 ``tokensURL``.

 In contrast with ``ClientCredentialsFlowClientBackend``, which can be used if
 you are communicating directly with Spotify, this type does not send the
 `clientId`, or `clientSecret` in network requests because these values should
 be securely stored on your backend server.

 Read more about the [Client Credentials Flow][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
 [2]: https://github.com/Peter-Schorn/SpotifyAPIServer
 */
public struct ClientCredentialsFlowProxyBackend: ClientCredentialsFlowBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "ClientCredentialsFlowProxyBackend", level: .critical
    )

    /**
     The URL to your custom backend server that accepts a post request for
     the authorization information. The body will contain a key called
     "grant_type" with the value set to "client_credentials" in
     x-www-form-urlencoded format.
     
     The [/client-credentials-flow/retrieve-tokens][1] endpoint of
     SpotifyAPIServer can be used for this URL.

     See ``makeClientCredentialsTokensRequest()`` for more information.
     
     [1]: https://github.com/Peter-Schorn/SpotifyAPIServer#post-client-credentials-flowretrieve-tokens
     */
    public let tokensURL: URL

    /**
     A hook for decoding an error produced by your backend server into an error
     type, which will then be thrown to downstream subscribers.
     
     After the response from your server is received following a call to
     ``makeClientCredentialsTokensRequest()``, this function is called with the
     raw data and response metadata from the server. If you return an error from
     this function, then this error will be thrown to downstream subscribers. If
     you return `nil`, then the response from the server will be passed through
     unmodified to downstream subscribers.
     
     - Important: Do not use this function to decode the documented error
           objects produced by Spotify, such as ``SpotifyAuthenticationError``.
           This will be done elsewhere. Only use this function to decode error
           objects produced by your custom backend server.
     
     **Thread Safety**
     
     No guarantees are made about which thread this function will be called on.
     Do not mutate this property while a request is being made for the
     authorization information.
     */
    public var decodeServerError: ((Data, HTTPURLResponse) -> Error?)?

    /**
     Creates an instance that manages the authorization process for the Client
     Credentials Flow by communicating with a custom backend server.

     This type requires a custom backend server that can store your client id
     and client secret.

     Instead of creating your own server, you can use [SpotifyAPIServer][2] with
     this type by assigning the /client-credentials-flow/retrieve-tokens
     endpoint to ``tokensURL``.

     Read more about the [Client Credentials Flow][1].

     - Parameters:
       - tokensURL: The URL to your custom backend server that accepts a post
             request for the authorization information. The body will contain a
             key called "grant_type" with the value set to "client_credentials"
             in x-www-form-urlencoded format. See
             ``makeClientCredentialsTokensRequest()`` for more information.
       - decodeServerError: A hook for decoding an error produced by your
             backend server into an error type, which will then be thrown to
             downstream subscribers. Do not use this function to decode the
             documented error objects produced by Spotify, such as
             ``SpotifyAuthenticationError``. This will be done elsewhere.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
     [2]: https://github.com/Peter-Schorn/SpotifyAPIServer#post-client-credentials-flowretrieve-tokens
     */
    public init(
        tokensURL: URL,
        decodeServerError: ((Data, HTTPURLResponse) -> Error?)? = nil
    ) {
        self.tokensURL = tokensURL
        self.decodeServerError = decodeServerError
    }

    /**
     Makes a request for the authorization information.

     This method is called by either the
     ``ClientCredentialsFlowBackendManager/authorize()`` or
     ``ClientCredentialsFlowBackendManager/refreshTokens(onlyIfExpired:tolerance:)``
     methods of ``ClientCredentialsFlowBackendManager``. The client credentials
     flow does not provide a refresh token, so in both cases, the same network
     request should be made.

     This method makes a post request to ``tokensURL``. The headers will contain
     the "Content-Type: application/x-www-form-urlencoded" header and the body
     will contain a key called "grant_type" with the value set to
     "client_credentials" in x-www-form-urlencoded format. For example:
     "grant_type=client_credentials". See ``ClientCredentialsTokensRequest``,
     which is used to encode this data.

     This method must return the authorization information as JSON data that can
     be decoded into ``AuthInfo``. The ``AuthInfo/accessToken`` and
     ``AuthInfo/expirationDate`` (which can be decoded from the "expires_in"
     JSON key) properties must be non-`nil`. For example:

     ```
     {
         "access_token": "NgCXRKc...MzYjw",
         "token_type": "bearer",
         "expires_in": 3600,
     }
     ```
     
     Any error that your backend server receives from the Spotify web API, along
     with the headers and status code, should be forwarded directly to the
     client, as this library already knows how to decode these errors.

     After the response is retrieved from the server, ``decodeServerError`` is
     called in order to decode any custom error objects that your server might
     return.

     Read about the underlying request that must be made to Spotify in order to
     retrieve this data [here][1].
     
     The [/client-credentials-flow/retrieve-tokens][2] endpoint of
     SpotifyAPIServer can be used for this URL.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/#request-authorization
     [2]: https://github.com/Peter-Schorn/SpotifyAPIServer#post-client-credentials-flowretrieve-tokens
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

        var tokensRequest = URLRequest(url: self.tokensURL)
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
        .tryMap { data, response in
            if let error = self.decodeServerError?(data, response) {
                throw error
            }
            return (data: data, response: response)
        }
        .eraseToAnyPublisher()

    }

}

extension ClientCredentialsFlowProxyBackend: CustomStringConvertible {
    
    public var description: String {
        return """
            ClientCredentialsFlowProxyBackend(
                tokensURL: "\(self.tokensURL)"
            )
            """
    }
    
}

extension ClientCredentialsFlowProxyBackend: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.tokensURL == rhs.tokensURL
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.tokensURL)
    }
    
}

extension ClientCredentialsFlowProxyBackend: Codable {
    
    enum CodingKeys: String, CodingKey {
        case tokensURL = "tokens_url"
    }
    
}
