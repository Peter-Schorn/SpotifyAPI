import Foundation

/**
 After the user has authorized your app and a code has been provided,
 this struct is used to request a refresh and access token for the
 [Authorization Code Flow][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 */
public struct TokensRequest: Hashable {
    
    public let grantType = "authorization_code"
    public let code: String
    public let redirectURI: String
    public let clientId: String
    public let clientSecret: String

    public func formURLEncoded() -> Data {
        
        guard let data = [
            "grant_type": grantType,
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientId,
            "client_secret": clientSecret
        ].formURLEncoded()
        else {
            fatalError("could not form-url-encode tokens request")
        }
        return data
        
    }
    
    
}

extension TokensRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case code
        case redirectURI = "redirect_uri"
        case clientId = "client_id"
        case clientSecret = "client_secret"
    }

}


// MARK: Convienence intializer for redirectURI as URL

public extension TokensRequest {
    
    init(
        code: String,
        redirectURI: URL,
        clientId: String,
        clientSecret: String
    ) {
        self.code = code
        self.redirectURI = redirectURI.absoluteString
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
}

