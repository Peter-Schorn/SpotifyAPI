import Foundation

/**
 Used during the Authorization Code Flow to retrieve a new access
 token using the refresh token. Spotify may also return a new refresh token.
 
 This type should be used in the body of the network request made in the
 ``AuthorizationCodeFlowBackend/refreshTokens(refreshToken:)`` method of your
 type that conforms to ``AuthorizationCodeFlowBackend``.

 - Important: Although this type conforms to `Codable`, it should actually be
       encoded in x-www-form-urlencoded format when sent in the body of a
       network request using ``formURLEncoded()``.

 Read more at the [Spotify web API reference][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 */
public struct RefreshTokensRequest: Hashable {
    
    /// The grant type. Always set to "refresh_token".
    public let grantType = "refresh_token"
    
    /// The refresh token.
    public let refreshToken: String
    
    /**
     Creates an instance which refreshes the access token using the
     Authorization Code Flow.
     
     This type should be used in the body of the network request made in the
     ``AuthorizationCodeFlowBackend/refreshTokens(refreshToken:)`` method of
     your type that conforms to ``AuthorizationCodeFlowBackend``.

     - Important: Although this type conforms to `Codable`, it should actually
           be encoded in x-www-form-urlencoded format when sent in the body of a
           network request using ``formURLEncoded()``.
     
     Read more about the [Authorization Code Flow][1].

     - Parameter refreshToken: The refresh token.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     */
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }

    /**
     Encodes this instance to data using the x-www-form-urlencoded format.
     
     This method should be used to encode this type to data (as opposed to using
     a `JSONEncoder`) before being sent in a network request.
     */
    public func formURLEncoded() -> Data {
        
        guard let data = [
            CodingKeys.grantType.rawValue: self.grantType,
            CodingKeys.refreshToken.rawValue: self.refreshToken
        ].formURLEncoded()
        else {
            fatalError(
                "could not form-url-encode `RefreshTokensRequest`"
            )
        }
        return data
    }
    
}

extension RefreshTokensRequest: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case refreshToken = "refresh_token"
    }
    
}
