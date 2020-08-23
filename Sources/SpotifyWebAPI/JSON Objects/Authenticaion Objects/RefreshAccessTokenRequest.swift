import Foundation

/// Used to retrieve a fresh access token using the refresh token.
/// Spotify may also return a new refresh token.
struct RefreshAccessTokenRequest: Codable, Hashable {
    
    let grantType = "refresh_token"
    let refreshToken: String
    
    public func formURLEncoded() -> Data {
           
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
