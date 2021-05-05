import Foundation

public struct ClientCredentialsTokensRequest: Hashable {
    
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

extension ClientCredentialsTokensRequest: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let grantType = try container.decode(String.self, forKey: .grantType)
        if grantType != self.grantType {
            throw DecodingError.dataCorruptedError(
                forKey: CodingKeys.grantType,
                in: container,
                debugDescription: """
                    value for key '\(CodingKeys.grantType.stringValue)' must \
                    be '\(self.grantType)', not '\(grantType)'
                    """
            )
        }

    }

    public enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
    }

}
