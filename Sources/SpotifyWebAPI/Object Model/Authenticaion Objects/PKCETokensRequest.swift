import Foundation

/**
 After the user has authorized your app and a code has been provided,
 this struct is used to request a refresh and access token for the
 [Authorization Code Flow with Proof Key for Code Exchange][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
 */
public struct PKCETokensRequest: Hashable {
    
    public let grantType = "authorization_code"
    public let code: String
    public let redirectURI: String
    public let clientId: String
    public let codeVerifier: String

    public init(
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
    
    public func formURLEncoded() -> Data {
        
        guard let data = [
            CodingKeys.grantType.rawValue: self.grantType,
            CodingKeys.code.rawValue: self.code,
            CodingKeys.redirectURI.rawValue: self.redirectURI,
            CodingKeys.clientId.rawValue: self.clientId,
            CodingKeys.codeVerifier.rawValue: self.codeVerifier
        ].formURLEncoded()
        else {
            fatalError("could not form-url-encode PKCETokensRequest")
        }
        return data
        
    }
    
    
}

extension PKCETokensRequest: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case code
        case redirectURI = "redirect_uri"
        case clientId = "client_id"
        case codeVerifier = "code_verifier"
    }

}
