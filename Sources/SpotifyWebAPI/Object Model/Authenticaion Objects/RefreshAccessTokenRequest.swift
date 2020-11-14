import Foundation

/**
 Used during the [Authorization Code Flow][1] to retrieve a new access
 token using the refresh token. Spotify may also return a new refresh token.
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 */
struct RefreshAccessTokenRequest: Codable, Hashable {
    
    let grantType = "refresh_token"
    let refreshToken: String
    
    func formURLEncoded() -> Data {
        
        guard let data = [
            "grant_type": grantType,
            "refresh_token": refreshToken
        ].formURLEncoded()
        else {
            fatalError(
                "could not form-url-encode refresh tokens request"
            )
        }
        return data
    }
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case grantType = "grant_type"
    }
    
}
