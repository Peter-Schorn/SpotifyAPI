import Foundation


/**
 The [Regular Error Object][1] returned by the Spotify web API.
 
 See the [Response Status Codes][2].
 
 [1]: https://developer.spotify.com/documentation/web-api/#regular-error-object
 [2]: https://developer.spotify.com/documentation/web-api/#response-status-codes
 */
public struct SpotifyError: LocalizedError, Hashable {
    
    /// A short description of the cause of the error.
    public let message: String
    
    /// The HTTP status code that is also returned in the response header.
    /// For further information, see [Response Status Codes][1].
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#response-status-codes
    public let statusCode: Int
    
    public var errorDescription: String? {
        "\(message) (status code: \(statusCode))"
    }
    
    
}


extension SpotifyError: Decodable {
    
    public init(from decoder: Decoder) throws {
        
        let topLevelContainer = try decoder.container(
            keyedBy: CodingKeys.self
        )

        let container = try topLevelContainer.nestedContainer(
            keyedBy: CodingKeys.self, forKey: .error
        )
        self.message = try container.decode(
            String.self, forKey: .message
        )
        self.statusCode = try container.decode(
            Int.self, forKey: .statusCode
        )
        
    }
    
    enum CodingKeys: String, CodingKey {
        case error
        case message
        case statusCode = "status"
    }
    
}
