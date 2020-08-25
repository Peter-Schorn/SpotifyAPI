import Foundation

/**
 A request to play Spotify content for the current user.
 
 Used in the body of
 */
public struct PlaybackRequest: Hashable {
    
    /**
     The context in which to play the content.
     
     One of the following:
     
     * `contextURI(String)`: A URI for the context in which to play the content.
       Must correspond to one of the following:
       * Album
       * Artist
       * Playlist
     
     * `uris([String])`: An array of track/episode uris.
     
     */
    public let context: ContextOption
    
    /**
     Indicates where in the context playback should start.
     
     Only available when `contextURI` is an album or playlist (not an artist)
     or when `uris([String])` is used for the context. One of the following:
     
     * `position(Int)`: The index of the item in the context at which to
           start playback.
     *  `uri(String)`: The URI of the item to start playback at.
     
     If `nil`, then either the first item or a random item in the context
     will be played, depending on whether the user has shuffle on.
     */
    public let offset: OffsetOption?
    
    /**
     Indicates from what position to start playback.
    
     If `nil`, then the track/episode will start from the beginning.
     Must be a positive number. Passing in a position that is
     greater than the length of the track will cause the player
     to start playing the next song.
     */
    public let positionMS: Int?
    
    
    /**
     Creates a request to play Spotify content for the current user.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - context: The context in which to play the content.
         One of the following:
         * `contextURI(String)`: A URI for the context in which to play
           the content. Must correspond to one of the following:
           * Album
           * Artist
           * Playlist
         * `uris([String])`: An array of track/episode uris.
     
       - offset: Indicates where in the context playback should start.
         Only available when `contextURI` is an album or playlist
         (not an artist) or when `uris([String])` is used for the context.
         One of the following:
         
         * `position(Int)`: The index of the item in the context at which to
             start playback.
         *  `uri(String)`: The URI of the item to start playback at.
         
         If `nil`, then either the first item or a random item in the context
         will be played, depending on whether the user has shuffle on.
     
       - positionMS: Indicates from what position to start playback.
         Must be a positive number. If `nil`, then the track/episode
         will start from the beginning. Passing in a position that is
         greater than the length of the track will cause the player
         to start playing the next song.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/player/start-a-users-playback/
     */
    public init(
        context: ContextOption,
        offset: OffsetOption?,
        positionMS: Int? = nil
    ) {
        self.context = context
        self.offset = offset
        self.positionMS = positionMS
    }
    
}

extension PlaybackRequest: Codable {
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self.context {
            case .contextURI(let context):
                try container.encode(
                    context.uri, forKey: .contextURI
                )
            case .uris(let uris):
                try container.encode(
                    uris.map(\.uri), forKey: .uris
                )
        }
        
        switch self.offset {
            case .position(let index):
                try container.encode(
                    ["position": index],
                    forKey: .offset
                )
            case .uri(let uri):
                try container.encode(
                    ["uri": uri.uri],
                    forKey: .offset
                )
            case nil:
                break
        }
        
        try container.encodeIfPresent(
            self.positionMS, forKey: .positionMS
        )
        
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let contextURI = try container.decodeIfPresent(
            String.self, forKey: .contextURI
        ) {
            self.context = .contextURI(contextURI)
        }
        else if let uris = try container.decodeIfPresent(
            [String].self,
            forKey: .uris
        ) {
            self.context = .uris(uris)
        }
        else {
            let debugDescription = """
                expected to find either a single string value for key \
                "context_uri" or an array of strings for key "uris"
                """
            throw DecodingError.dataCorruptedError(
                forKey: .uris,
                in: container,
                debugDescription: debugDescription
            )
        }
        if let positionDictionary = try? container.decodeIfPresent(
            [String: Int].self,
            forKey: .offset
        ) {
            guard let position = positionDictionary["position"] else {
                let debugDescription = """
                    exptected to find key "position" in the following \
                    dictionary:
                    \(positionDictionary)
                    """
                throw DecodingError.dataCorruptedError(
                    forKey: .offset,
                    in: container,
                    debugDescription: debugDescription
                )
            }
            self.offset = .position(position)
        }
        else if let uriOffsetDictionary = try? container.decodeIfPresent(
            [String: String].self,
            forKey: .offset
        ) {
            guard let uriOffset = uriOffsetDictionary["uri"] else {
                let debugDescription = """
                    expected to find key "uri" in the following \
                    dictionary:
                    \(uriOffsetDictionary)
                    """
                throw DecodingError.dataCorruptedError(
                    forKey: .offset,
                    in: container,
                    debugDescription: debugDescription
                )
            }
            self.offset = .uri(uriOffset)
        }
        else {
            self.offset = nil
        }
        
        self.positionMS = try container.decodeIfPresent(
            Int.self, forKey: .positionMS
        )
        
    }
 
    
    public enum CodingKeys: String, CodingKey {
        case contextURI = "context_uri"
        case uris
        case offset
        case positionMS = "position_ms"
    }
    
}

public enum ContextOption: Hashable {
    
    case contextURI(SpotifyURIConvertible)
    case uris([SpotifyURIConvertible])
    
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

public enum OffsetOption: Hashable {
    
    case position(Int)
    case uri(SpotifyURIConvertible)
    
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
