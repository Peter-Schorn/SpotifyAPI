import Foundation

/**
 A request to play Spotify content for the current user.
 
 Used in the body of `SpotifyAPI.resumePlayback(_:deviceId:)`.
 
 Read more at the [Spotify web API reference][1].
 
 * context: The context in which to play the content. One of the following:
   * `contextURI(SpotifyURIConvertible)`: A URI for the context in which to
     play the content. Must be one of the following types:
     * Album
     * Artist
     * Playlist
 
   * `uris([SpotifyURIConvertible])`: An array of track/episode URIs.
 
 * offset: Indicates where in the context playback should start.
   Only available when `contextURI` is an album or playlist (not an artist)
   or when `uris([SpotifyURIConvertible])` is used for the context.
   One of the following:
 
   * `position(Int)`: The index of the item in the context at which to
     start playback.
   *  `uri(SpotifyURIConvertible)`: The URI of the item to start playback at.
 
 * positionMS: Indicates from what position to start playback in
   milliseconds. If `nil`, then the track/episode will start from
   the beginning. Passing in a position that is greater than the
   length of the track/episode will cause the player to start playing
   the next item.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/player/start-a-users-playback/
 */
public struct PlaybackRequest: Hashable {
    
    /**
     The context in which to play the content.
     
     One of the following:
     
     * `contextURI(SpotifyURIConvertible)`: A URI for the context in which to
       play the content. Must correspond to one of the following:
       * Album
       * Artist
       * Playlist
     
     * `uris([SpotifyURIConvertible])`: An array of track/episode URIs.
     */
    public var context: ContextOption
    
    /**
     Indicates where in the context playback should start.
     
     Only available when `contextURI` is an album or playlist (not an artist)
     or when `uris([SpotifyURIConvertible])` is used for the context.
     One of the following:
     
     * `position(Int)`: The index of the item in the context at which to
           start playback.
     *  `uri(SpotifyURIConvertible)`: The URI of the item to start playback at.
     
     If `nil`, then either the first item or a random item in the context
     will be played, depending on whether the user has shuffle on.
     */
    public var offset: OffsetOption?
    
    /**
     Indicates from what position to start playback in milliseconds.
     
     If `nil`, then the track/episode will start from the beginning.
     Passing in a position that is greater than the length of the track
     will cause the player to start playing the next song.
     */
    public var positionMS: Int?
    
    
    /**
     Creates a request to play Spotify content for the current user.
     
     Read more at the [Spotify web API reference][1].
     
     See also `init(_:positionMS:)`—a convenience initializer that makes a
     request to play a single track/episode.
     
     - Parameters:
       - context: The context in which to play the content.
         One of the following:
         * `contextURI(SpotifyURIConvertible)`: A URI for the context in which to play
           the content. Must correspond to one of the following:
           * Album
           * Artist
           * Playlist
         * `uris([SpotifyURIConvertible])`: An array of track/episode URIs.
     
       - offset: Indicates where in the context playback should start.
         Only available when `contextURI` is an album or playlist
         (not an artist) or when `uris([SpotifyURIConvertible])`
         is used for the context. One of the following:
         
         * `position(Int)`: The index of the item in the context at which to
             start playback.
         *  `uri(SpotifyURIConvertible)`: The URI of the item to start playback at.
         
       - positionMS: Indicates from what position to start playback in
             milliseconds. If `nil`, then the track/episode will start from
             the beginning. Passing in a position that is greater than the
             length of the track/episode will cause the player to start playing
             the next item.
     
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
 
    /**
     A convenience initializer that makes a request to play a single
     track/episode.
     
     See also `init(context:offset:positionMS:)`.
     
     - Parameters:
       - item: A track or episode URI.
       - positionMS: Indicates from what position to start playback in
             milliseconds. If `nil`, then the track/episode will start from
             the beginning. Passing in a position that is greater than the
             length of the track/episode will cause the player to start playing
             the next item.
     */
    public init(
        _ item: SpotifyURIConvertible,
        positionMS: Int? = nil
    ) {
        self.init(
            context: .uris([item]),
            offset: nil,
            positionMS: positionMS
        )
    }

}

extension PlaybackRequest: Codable {
    
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
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: debugDescription
                )
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
    
    public enum CodingKeys: String, CodingKey {
        case contextURI = "context_uri"
        case uris
        case offset
        case positionMS = "position_ms"
    }
    
}
