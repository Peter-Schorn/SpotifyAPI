import Foundation

/// A namespace of HTTP Headers.
enum Headers {
    
    
    /// Makes the bearer authorization header using the access token.
    ///
    /// ```
    /// ["Authorization": "Bearer \(accessToken)"]
    /// ```
    static func bearerAuthorization(
        _ accessToken: String
    ) -> [String: String] {
        return ["Authorization": "Bearer \(accessToken)"]
    }
    
    /// ```
    /// ["Content-Type": "application/x-www-form-urlencoded"]
    /// ```
    static let formURLEncoded = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    /// ```
    /// ["Accept": "application/json"]
    /// ```
    static let acceptApplicationJSON = [
        "Accept": "application/json"
    ]
    
    /**
     Makes the base64Encoded authorization header.
     
     ```
     guard let encodedString = "\(clientID):\(clientSecret)"
     .base64Encoded()
     else {
     return nil
     }
     
     return ["Authorization": "Basic \(encodedString)"]
     ```
     */
    static func basicBase64Encoded(
        clientID: String, clientSecret: String
    ) -> [String: String]? {
        
        guard let encodedString = "\(clientID):\(clientSecret)"
            .base64Encoded()
            else {
                return nil
        }
        
        return ["Authorization": "Basic \(encodedString)"]
        
    }
    
}
