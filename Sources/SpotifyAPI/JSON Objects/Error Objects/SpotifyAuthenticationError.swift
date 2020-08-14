import Foundation


/// This error is used when there is an authentication error.
public struct SpotifyAuthenticationError: CustomCodable, LocalizedError, Hashable {
    
    public let error: String
    public let description: String

    public var errorDescription: String? {
        "\(error): \(description)"
    }
    
    enum CodingKeys: String, CodingKey {
        case error
        case description = "error_description"
    }
    
}
