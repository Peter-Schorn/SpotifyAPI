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
 authoriation information using the [Client Credentials Flow][1].
 
 Compare with `ClientCredentialsFlowClientBackend`.
 
 This type requires a custom backend server that can store your client id and
 client secret.
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
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
     
     See `self.makeClientCredentialsTokensRequest()` for more information.
     */
    public let tokensURL: URL

    /**
     Creates an instance that manages the authorization process for the [Client
     Credentials Flow][1] by communicating with a custom backend server.

     - Parameters:
       - tokensURL: The URL to your custom backend server that accepts a post
             request for the authorization information. The body will contain a
             key called "grant_type" with the value set to "client_credentials"
             in x-www-form-urlencoded format. See
             `self.makeClientCredentialsTokensRequest()` for more information.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
     */
    public init(tokensURL: URL) {
        self.tokensURL = tokensURL
    }

    /**
     Makes a request for the authorization information.

     This method is called by either the `authorize()` or
     `refreshTokens(onlyIfExpired:tolerance:)` methods of
     `ClientCredentialsFlowBackendManager`. The client credentials flow does not
     provide a refresh token, so in both cases, the same network request should
     be made.

     This method makes a post request to `self.tokensURL`. The headers will
     contain the "Content-Type: application/x-www-form-urlencoded" header and
     the body will contain a key called "grant_type" with the value set to
     "client_credentials" in x-www-form-urlencoded format. For example:
     "grant_type=client_credentials". See `ClientCredentialsTokenRequest`.

     This method must return the authorization information as JSON data that can
     be decoded into `AuthInfo`. The `accessToken`, and `expirationDate` (which
     can be decoded from the "expires_in" JSON key) properties must be
     non-`nil`. For example:

     ```
     {
         "access_token": "NgCXRKc...MzYjw",
         "token_type": "bearer",
         "expires_in": 3600,
     }
     ```

     Read about the underlying request that must be made to Spotify in order to
     retrieve this data [here][1].
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#:~:text=the%20request%20is%20sent%20to%20the%20%2Fapi%2Ftoken%20endpoint%20of%20the%20accounts%20service%3A
     */
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

        var tokensRequest = URLRequest(url: self.tokensURL)
        tokensRequest.httpMethod = "POST"
        tokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
        tokensRequest.httpBody = body

        return URLSession.defaultNetworkAdaptor(
            request: tokensRequest
        )

    }

}

