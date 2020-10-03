import Foundation

/**
 After the user has authorized your app and a code has been provided,
 this struct is used to request a refresh and access token for the
 [Authorization Code Flow with Proof Key for Code Exchange][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
 */
struct PKCETokensRequest: Hashable {
    
    let grantType = "authorization_code"
    let code: String
    let redirectURI: String
    let clientId: String
    let codeVerifier: String

    init(
        code: String,
        redirectURI: URL,
        clientId: String,
        codeVerifier: String
    ) {
        self.code = code
        self.redirectURI = redirectURI.absoluteString
        self.clientId = clientId
        self.codeVerifier = codeVerifier
    }
    
    func formURLEncoded() -> Data {
        
        guard let data = [
            "grant_type": grantType,
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientId,
            "code_verifier": codeVerifier
        ].formURLEncoded()
        else {
            fatalError("could not form-url-encode PKCETokensRequest")
        }
        return data
        
    }
    
    
}

extension PKCETokensRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case code
        case redirectURI = "redirect_uri"
        case clientId = "client_id"
        case codeVerifier = "code_verifier"
    }

}
