import Foundation

/// A namespace of HTTP Headers.
public enum Headers {
    
    
    /// Makes the bearer authorization header using the access token.
    ///
    /// ```
    /// ["Authorization": "Bearer \(accessToken)"]
    /// ```
    /// - Parameter accessToken: The access token from Spotify.
    public static func bearerAuthorization(
        _ accessToken: String
    ) -> [String: String] {
        return ["Authorization": "Bearer \(accessToken)"]
    }
    
    
    /// ```
    /// ["Accept": "application/json"]
    /// ```
    public static let acceptApplicationJSON = [
        "Accept": "application/json"
    ]
    
    /// The bearer authorization and accept application JSON headers.
    ///
    /// Equivalent to `bearerAuthorization(accessToken) + acceptApplicationJSON`
    ///
    /// - Parameter accessToken: The access token from Spotify.
    public static func bearerAuthorizationAndAcceptApplicationJSON(
        _ accessToken: String
    ) -> [String: String] {
        return bearerAuthorization(accessToken) + acceptApplicationJSON
    }
    
    /// ```
    /// ["Content-Type": "application/x-www-form-urlencoded"]
    /// ```
    public static let formURLEncoded = [
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
    public static func basicBase64Encoded(
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
    public static let imageJpeg = ["Accept": "image/jpeg"]
    
    
}
