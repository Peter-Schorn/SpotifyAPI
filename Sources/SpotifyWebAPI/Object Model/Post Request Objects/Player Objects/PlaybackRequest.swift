import Foundation

/**
 A request to play Spotify content for a user.
 
 Used in the body of ``SpotifyAPI/play(_:deviceId:)``.
 
 See also <doc:Using-the-Player-Endpoints#Playback-Request-Examples>.

 Read more at the [Spotify web API reference][1].
 
 * context: The context in which to play the content. One of the following:
   * `contextURI(SpotifyURIConvertible)`: A URI for the context in which to play
     the content. Must be in one of the following categories:
     * Album
     * Artist
     * Show
     * Playlist
 
   * `uris([SpotifyURIConvertible])`: An array of track/episode URIs.
 
 * offset: Indicates where in the context playback should start. One of the
   following:
 
   * `position(Int)`: The index of the item in the context at which to start
     playback. Cannot be used if the context is an artist.
   *  `uri(SpotifyURIConvertible)`: The URI of the item to start playback at.
 
 * positionMS: Indicates from what position to start playback in milliseconds.
   If `nil`, then the track/episode will start from the beginning. Passing in a
   position that is greater than the length of the track/episode will cause the
   player to start playing the next item.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/start-a-users-playback
 */
public struct PlaybackRequest: Hashable {
    
    /**
     The context in which to play the content.
     
     One of the following:
     
     * `contextURI(SpotifyURIConvertible)`: A URI for the context in which to
       play the content. Must be in one of the following categories:
       * Album
       * Artist
       * Show
       * Playlist
     
     * `uris([SpotifyURIConvertible])`: An array of track/episode URIs.
     */
    public var context: Context
    
    /**
     Indicates where in the context playback should start.
     
     One of the following:
     
     * `position(Int)`: The index of the item in the context at which to start
        playback. Cannot be used if the context is an artist.
     *  `uri(SpotifyURIConvertible)`: The URI of the item to start playback at.
     
     If `nil`, then either the first item or a random item in the context will
     be played, depending on whether the user has shuffle on.
     */
    public var offset: Offset?
    
    /**
     Indicates from what position to start playback in milliseconds.
     
     If `nil`, then the track/episode will start from the beginning. Passing in
     a position that is greater than the length of the track will cause the
     player to start playing the next song.
     */
    public var positionMS: Int?
    
    
    /**
     Creates a request to play Spotify content for a user.
     
     See also ``init(_:positionMS:)``—a convenience initializer that makes a
     request to play a single track/episode.
     
     See also <doc:Using-the-Player-Endpoints#Playback-Request-Examples>.

     Read more at the [Spotify web API reference][1].

     - Parameters:
       - context: The context in which to play the content. One of the
         following:
         * `contextURI(SpotifyURIConvertible)`: A URI for the context in which
           to play the content. Must be in one of the following categories:
           * Album
           * Artist
           * Show
           * Playlist
     
         * `uris([SpotifyURIConvertible])`: An array of track/episode URIs.
     
       - offset: Indicates where in the context playback should start.
         One of the following:
         * `position(Int)`: The index of the item in the context at which to
           start playback. Cannot be used if the context is an artist.
         * `uri(SpotifyURIConvertible)`: The URI of the item to start playback
           at.
         
       - positionMS: Indicates from what position to start playback in
             milliseconds. If `nil`, then the track/episode will start from the
             beginning. Passing in a position that is greater than the length of
             the track/episode will cause the player to start playing the next
             item.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/start-a-users-playback
     */
    public init(
        context: Context,
        offset: Offset?,
        positionMS: Int? = nil
    ) {
        self.context = context
        self.offset = offset
        self.positionMS = positionMS
    }
 
    /**
     A convenience initializer that makes a request to play a single
     track/episode.
     
     See also ``init(context:offset:positionMS:)``.
     
     Equivalent to
     ```
     init(
         context: .uris([uri]),
         offset: nil,
         positionMS: positionMS
     )
     ```
     
     See also <doc:Using-the-Player-Endpoints#Playback-Request-Examples>.

     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uri: A track or episode URI.
       - positionMS: Indicates from what position to start playback in
             milliseconds. If `nil`, then the track/episode will start from the
             beginning. Passing in a position that is greater than the length of
             the track/episode will cause the player to start playing the next
             item.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/start-a-users-playback
     */
    public init(
        _ uri: SpotifyURIConvertible,
        positionMS: Int? = nil
    ) {
        self.init(
            context: .uris([uri]),
            offset: nil,
            positionMS: positionMS
        )
    }

}

extension PlaybackRequest: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.context = try Context(from: decoder)
        self.offset = try container.decodeIfPresent(
            Offset.self, forKey: .offset
        )
        self.positionMS = try container.decodeIfPresent(
            Int.self, forKey: .positionMS
        )
        
    }
 
    public func encode(to encoder: Encoder) throws {
        
        try self.context.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(self.offset, forKey: .offset)
        try container.encodeIfPresent(
            self.positionMS, forKey: .positionMS
        )
        

    }
    
    private enum CodingKeys: String, CodingKey {
        case offset
        case positionMS = "position_ms"
    }
    
}
