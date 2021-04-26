import Foundation

public struct ClientCredentialsTokenRequest: Hashable {
    
    public let grantType = "client_credentials"

    public init() { }

    public func formURLEncoded() -> Data {
        
        guard let data = [
            CodingKeys.grantType.rawValue: self.grantType
        ].formURLEncoded()
        else {
            fatalError(
                "could not form-url-encode client credentials token request"
            )
        }
        return data
    }

}

extension ClientCredentialsTokenRequest: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
    }

}
