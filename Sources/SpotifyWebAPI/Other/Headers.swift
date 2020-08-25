import Foundation

/// A namespace of HTTP Headers.
enum Headers {
    
    
    /// Makes the bearer authorization header using the access token.
    ///
    /// ```
    /// ["Authorization": "Bearer \(accessToken)"]
    /// ```
    /// - Parameter accessToken: The Access token from Spotify.
    static func bearerAuthorization(
        _ accessToken: String
    ) -> [String: String] {
        return ["Authorization": "Bearer \(accessToken)"]
    }
    
    
    /// ```
    /// ["Accept": "application/json"]
    /// ```
    static let acceptApplicationJSON = [
        "Accept": "application/json"
    ]
    
    /// ```
    /// ["Content-Type": "application/x-www-form-urlencoded"]
    /// ```
    static let formURLEncoded = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]

    /**
     Makes the base64Encoded authorization header
     with the client id and secret.
     
     ```
     guard let encodedString = "\(clientId):\(clientSecret)"
             .base64Encoded()
     else {
         return nil
     }
     return ["Authorization": "Basic \(encodedString)"]
     ```
     
     - Parameters:
       - clientId: The client id.
       - clientSecret: The client secret.
     */
    static func basicBase64Encoded(
        clientId: String, clientSecret: String
    ) -> [String: String]? {
        
        guard let encodedString = "\(clientId):\(clientSecret)"
                .base64Encoded()
        else {
            return nil
        }
        
        return ["Authorization": "Basic \(encodedString)"]
        
    }
    
    /// ```
    /// ["Accept": "image/jpeg"]
    /// ```
    static let imageJpeg = ["Accept": "image/jpeg"]
    
    
}
