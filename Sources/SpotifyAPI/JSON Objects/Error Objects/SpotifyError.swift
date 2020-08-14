import Foundation


/// The [Regular Error Object][1] returned by the Spotify web API.
///
/// [1]: https://developer.spotify.com/documentation/web-api/#regular-error-object:~:text=%7D-,Regular%20Error%20Object,Apart%20from%20the%20response%20code%2C%20unsuccessful%20responses%20return%20a%20JSON%20object%20containing%20the%20following%20information%3A,-Key
public struct SpotifyError: LocalizedError, Hashable {
    
    /// A short description of the cause of the error.
    public let message: String
    /// The HTTP status code that is also returned in the response header.
    /// For further information, see [Response Status Codes][1].
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#response-status-codes
    public let statusCode: Int
 
    public var errorDescription: String? {
        "\(message) (status code: \(statusCode)"
    }
    
    
}


extension SpotifyError: CustomDecodable {
    
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
