import Foundation

/**
 The user's queue and currently playing track/episode.

 Used in the ``SpotifyAPI/queue()`` endpoint.
 
 Read more at the [Spotify web API reference][1]
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-queue
 */
public struct SpotifyQueue: Hashable {
    
    /**
     The full version of the currently playing track or episode.
     
     Although the type is ``PlaylistItem``, this does not necessarily mean that
     the item is playing in the context of a playlist. Can be `nil`. For
     example, if the user has a private session enabled or an ad is playing,
     then this will be `nil`.
    */
    public let currentlyPlaying: PlaylistItem?
    
    /// An array of the full versions of the tracks/episodes in the user's
    /// queue.
    public let queue: [PlaylistItem]

    
    /**
     The user's queue and currently playing track/episode.
     
     Used in the ``SpotifyAPI/queue()`` endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - currentlyPlaying: The full version of the currently playing track or
             episode.
       - queue: An array of the full versions of the tracks/episodes in the
             user's queue.

     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-queue
     */
    public init(
        currentlyPlaying: PlaylistItem?,
        queue: [PlaylistItem]
    ) {
        self.currentlyPlaying = currentlyPlaying
        self.queue = queue
    }
    
}

extension SpotifyQueue: Codable {

    private enum CodingKeys: String, CodingKey {
        case currentlyPlaying = "currently_playing"
        case queue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currentlyPlaying = try container.decodeIfPresent(
            PlaylistItem.self, forKey: .currentlyPlaying
        )
        self.queue = try container.decodeIfPresent(
            [PlaylistItem].self, forKey: .queue
        ) ?? []
    }

}

extension SpotifyQueue: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
     Dates are compared using `timeIntervalSince1970`, so they are considered
     floating point properties for the purposes of this method.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: SpotifyQueue) -> Bool {
        return self.currentlyPlaying.isApproximatelyEqual(
            to: other.currentlyPlaying
        ) && self.queue.isApproximatelyEqual(to: other.queue)
    }

}
