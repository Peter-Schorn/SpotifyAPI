import Foundation

/// After the user has authorized your app via the web
/// and a code has been provided, this struct is used
/// to request a refresh and access token.
public struct TokensRequest: Hashable {
    
    public let grantType = "authorization_code"
    public let code: String
    public let redirectURI: String
    public let clientId: String
    public let clientSecret: String

    public func formURLEncoded() -> Data {
        
        guard let data = formURLEncode([
            "grant_type": grantType,
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientId,
            "client_secret": clientSecret
        ])
        else {
            fatalError("could not form-url-encode tokens request")
        }
        return data
    }
    
    
}

extension TokensRequest: CustomCodable {
    
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

