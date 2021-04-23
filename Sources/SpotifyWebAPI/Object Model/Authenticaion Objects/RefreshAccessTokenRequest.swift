import Foundation

/**
 Used during the [Authorization Code Flow][1] to retrieve a new access
 token using the refresh token. Spotify may also return a new refresh token.
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 */
public struct RefreshAccessTokenRequest: Hashable {
    
    public let grantType = "refresh_token"
    public let refreshToken: String
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }

    public func formURLEncoded() -> Data {
        
        guard let data = [
            CodingKeys.grantType.rawValue: grantType,
            CodingKeys.refreshToken.rawValue: refreshToken
        ].formURLEncoded()
        else {
            fatalError(
                "could not form-url-encode refresh tokens request"
            )
        }
        return data
    }
    
}

extension RefreshAccessTokenRequest: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case refreshToken = "refresh_token"
    }
    
}
