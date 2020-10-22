import Foundation

/**
 Used during the [Authorization Code Flow with Proof Key for Code Exchange][1]
 to retrieve a new access token and refresh token using the refresh token.

 Unlike the Authorization Code Flow, a refresh token that has been obtained using
 the Authorization Code Flow with Proof Key for Code Exchange can be exchanged
 for an access token only once, after which it becomes invalid. This implies that
 Spotify should always return a new refresh token in addition to an access token.
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
 */
struct PKCERefreshAccessTokenRequest: Codable, Hashable {
    
    let grantType = "refresh_token"
    let refreshToken: String
    let clientId: String
    
    func formURLEncoded() -> Data {
        
        guard let data = [
            "grant_type": grantType,
            "refresh_token": refreshToken,
            "client_id": clientId
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
        case clientId = "client_id"
    }
    
}
