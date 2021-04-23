import Foundation

/**
 After the user has authorized your app and a code has been provided,
 this struct is used to request a refresh and access token for the
 [Authorization Code Flow][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 */
public struct RemoteTokensRequest: Hashable {
	
    public let code: String
    
    public init(code: String) {
        self.code = code
    }
    
    public func formURLEncoded() -> Data {
        guard let data = [
            CodingKeys.code.rawValue: self.code
        ].formURLEncoded() else {
            fatalError("could not form-url-encode tokens request")
        }
        return data
    }

}

extension RemoteTokensRequest: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case code
    }

}
