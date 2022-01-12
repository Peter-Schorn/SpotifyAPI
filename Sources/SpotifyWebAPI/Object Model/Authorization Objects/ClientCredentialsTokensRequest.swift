import Foundation

/**
 Used to request the authorization information for the Client Credentials
 Flow.

 This type should be used in the body of the network request made in the
 ``ClientCredentialsFlowBackend/makeClientCredentialsTokensRequest()`` method of
 your type that conforms to ``ClientCredentialsFlowBackend``.

 - Important: Although this type conforms to `Codable`, it should actually be
       encoded in x-www-form-urlencoded format when sent in the body of a
       network request using ``formURLEncoded()``.

 Read more about the [Client Credentials Flow][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
 */
public struct ClientCredentialsTokensRequest: Hashable {
    
    /// The grant type. Always set to "client_credentials".
    public let grantType = "client_credentials"

    /**
     Creates an instance of this type, which is used to request the
     authorization information for the Client Credentials Flow.
     
     This type should be used by the
     ``ClientCredentialsFlowBackend/makeClientCredentialsTokensRequest()``
     method of your type that conforms to ``ClientCredentialsFlowBackend``.

     - Important: Although this type conforms to `Codable`, it should actually
           be encoded in x-www-form-urlencoded format when sent in the body of a
           network request using ``formURLEncoded()``.

     Read more about the [Client Credentials Flow][1].

     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
     */
    public init() { }

    /**
     Encodes this instance to data using the x-www-form-urlencoded format.
     
     This method should be used to encode this type to data (as opposed to using
     a `JSONEncoder`) before being sent in a network request.
     */
    public func formURLEncoded() -> Data {
        
        guard let data = [
            CodingKeys.grantType.rawValue: self.grantType
        ].formURLEncoded()
        else {
            fatalError(
                "could not form-url-encode `ClientCredentialsTokensRequest`"
            )
        }
        return data
    }

}

extension ClientCredentialsTokensRequest: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
    }

}
