import Foundation

/**
 Used during the Authorization Code Flow with Proof Key for Code Exchange
 to retrieve a new access token and refresh token using the refresh token.

 Unlike the Authorization Code Flow, a refresh token that has been obtained
 using the Authorization Code Flow with Proof Key for Code Exchange can be
 exchanged for an access token only once, after which it becomes invalid. This
 implies that Spotify should always return a new refresh token in addition to an
 access token.
 
 When creating a type that conforms to ``AuthorizationCodeFlowPKCEBackend`` and
 which communicates with a custom backend server, use this type in the body of
 the network request made in the
 ``AuthorizationCodeFlowPKCEBackend/refreshTokens(refreshToken:)`` method.
 
 In contrast with ``PKCERefreshTokensRequest``, which should be used if you are
 communicating directly with Spotify, this type does not contain the
 `clientId` because this value should be securely stored on your backend
 server.

 - Important: Although this type conforms to `Codable`, it should actually be
       encoded in x-www-form-urlencoded format when sent in the body of a
       network request using ``formURLEncoded()``.

 Read more at the [Spotify web API reference][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 */
public struct ProxyPKCERefreshTokensRequest: Hashable {
    
    /// Always set to "PKCE". Disambiguates this type from
    /// ``RefreshTokensRequest`` when represented as data, which would otherwise
    /// have all of the same fields.
    public let method = "PKCE"
    
    /// The grant type. Always set to "refresh_token".
    public let grantType = "refresh_token"
    
    /// The refresh token.
    public let refreshToken: String

    /**
     Creates an instance which refreshes the access token using the
     Authorization Code Flow with Proof Key for Code Exchange.

     When creating a type that conforms to ``AuthorizationCodeFlowPKCEBackend``
     and which communicates with a custom backend server, use this type in the
     body of the network request made in the
     ``AuthorizationCodeFlowPKCEBackend/refreshTokens(refreshToken:)`` method.

     In contrast with ``PKCERefreshTokensRequest``, which should be used if you
     are communicating directly with Spotify, this type does not contain the
     `clientId` because this value should be securely stored on your backend
     server.

     - Important: Although this type conforms to `Codable`, it should actually
           be encoded in x-www-form-urlencoded format when sent in the body of a
           network request using ``formURLEncoded()``.
     
     Read more about the [Authorization Code Flow with Proof Key for Code
     Exchange][1].

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
            CodingKeys.method.rawValue: self.method,
            CodingKeys.grantType.rawValue: self.grantType,
            CodingKeys.refreshToken.rawValue: self.refreshToken
        ].formURLEncoded()
        else {
            fatalError(
                "could not form-url-encode `ProxyPKCERefreshTokensRequest`"
            )
        }
        return data
    }
    
}

extension ProxyPKCERefreshTokensRequest: Codable {

    private enum CodingKeys: String, CodingKey {
        case method
        case grantType = "grant_type"
        case refreshToken = "refresh_token"
    }
    
}
