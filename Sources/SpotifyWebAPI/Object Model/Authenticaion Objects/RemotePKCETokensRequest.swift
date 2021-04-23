import Foundation

/**
 After the user has authorized your app and a code has been provided,
 this struct is used to request a refresh and access token for the
 [Authorization Code Flow with Proof Key for Code Exchange][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
 */
public struct RemotePKCETokensRequest: Hashable {
    
    public let code: String
    public let codeVerifier: String
    
    public init(code: String, codeVerifier: String) {
        self.code = code
        self.codeVerifier = codeVerifier
    }
    
    public func formURLEncoded() -> Data {
        guard let data = [
            CodingKeys.code.rawValue: self.code,
            CodingKeys.codeVerifier.rawValue: self.codeVerifier,
        ].formURLEncoded() else {
            fatalError("could not form-url-encode tokens request")
        }
        return data
    }

}

extension RemotePKCETokensRequest: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case code
        case codeVerifier = "code_verifier"
    }

}
