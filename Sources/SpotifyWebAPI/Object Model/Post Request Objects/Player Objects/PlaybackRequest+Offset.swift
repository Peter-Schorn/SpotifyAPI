import Foundation

public extension PlaybackRequest {
    
    /**
     Indicates where in the context playback should start. See
     ``PlaybackRequest``.
     
     One of the following:
     
     * `position(Int)`: The index of the item in the context at which to start
       playback. Cannot be used if the context is an artist.
     * `uri(SpotifyURIConvertible)`: The URI of the item in the context
       to start playback at.
     */
    enum Offset {
        
        /// The index of the item in the context at which to start playback.
        /// Cannot be used if the context is an artist.
        case position(Int)
        
        /// The URI of the item in the context to start playback at.
        case uri(SpotifyURIConvertible)
    }
}

extension PlaybackRequest.Offset: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        
        if let position = try container.decodeIfPresent(
            Int.self, forKey: .position
        ) {
            self = .position(position)
        }
        else if let uri = try container.decodeIfPresent(
            String.self, forKey: .uri
        ) {
            self = .uri(uri)
        }
        else {
            let debugDescription = """
                expected to find Int value for key "position" or \
                String value for key "uri" in container.
                """
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: debugDescription
            )
            throw DecodingError.dataCorrupted(context)
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        
        switch self {
            case .position(let position):
                try container.encode(position, forKey: .position)
            case .uri(let uri):
                try container.encode(uri.uri, forKey: .uri)
        }
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case position, uri
    }

}

extension PlaybackRequest.Offset: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.position(let lhsIndex), .position(let rhsIndex)):
                return lhsIndex == rhsIndex
            case (.uri(let lhsURI), .uri(let rhsURI)):
                return lhsURI.uri == rhsURI.uri
            default:
                return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
            case .position(let index):
                hasher.combine(index)
            case .uri(let uri):
                hasher.combine(uri.uri)
        }
    }
    
}
