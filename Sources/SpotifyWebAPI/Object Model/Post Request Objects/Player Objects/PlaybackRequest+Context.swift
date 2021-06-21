import Foundation

public extension PlaybackRequest {
    
    /**
     The context in which to play Spotify content. See ``PlaybackRequest``.
     
     One of the following:
     
     * `contextURI(SpotifyURIConvertible)`: A URI for the context in which to
     play the content. Must correspond to one of the following:
     * Album
     * Artist
     * Show
     * Playlist
     
     * `uris([SpotifyURIConvertible])`: An array of track/episode URIs.
     */
    enum Context {
        
        /**
         A URI for the context in which to play the content.
         
         Must be one of the following categories:
         * Album
         * Artist
         * Show
         * Playlist
         */
        case contextURI(SpotifyURIConvertible)
        
        /// An array of track/episode URIs. Passing in a single item will cause
        /// that item to be played.
        case uris([SpotifyURIConvertible])
        
    }

}

extension PlaybackRequest.Context: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let contextURI = try container.decodeIfPresent(
            String.self, forKey: .contextURI
        ) {
            self = .contextURI(contextURI)
        }
        else if let uris = try container.decodeIfPresent(
            [String].self,
            forKey: .uris
        ) {
            self = .uris(uris)
        }
        else {
            let debugDescription = """
                expected to find either a single string value for key \
                "context_uri" or an array of strings for key "uris"
                """

            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: debugDescription
                )
            )
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            case .contextURI(let context):
                try container.encode(
                    context.uri, forKey: .contextURI
                )
            case .uris(let uris):
                try container.encode(
                    uris.map(\.uri), forKey: .uris
                )
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case contextURI = "context_uri"
        case uris
    }

}

extension PlaybackRequest.Context: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        switch self {
            case .contextURI(let context):
                hasher.combine(context.uri)
            case .uris(let uris):
                hasher.combine(uris.map(\.uri))
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.contextURI(let lhsContext), .contextURI(let rhsContext)):
                return lhsContext.uri == rhsContext.uri
            case (.uris(let lhsURIs), .uris(let rhsURIs)):
                return lhsURIs.map(\.uri) == rhsURIs.map(\.uri)
            default:
                return false
        }
    }
    
}

