import Foundation

/**
 A Spotify play history object.
 
 Contains information about a recently played track, including the time it was
 played, and the context it was played in.
 */
public struct PlayHistory: Hashable {
    
    /// The track that the user listened to (simplified version).
    public let track: Track
    
    /// The date and time the track was played.
    public let playedAt: Date
    
    /// The context the track was played from, such as an album, artist, or
    /// playlist.
    public let context: SpotifyContext?
    
    /**
     A Spotify play history object.
     
     - Parameters:
       - track: The track that the user listened to (simplified version).
       - playedAt: The date and time the track was played.
       - context: The context the track was played from, such as an album,
             artist, or playlist.
     */
    public init(
        track: Track,
        playedAt: Date,
        context: SpotifyContext?
    ) {
        self.track = track
        self.playedAt = playedAt
        self.context = context
    }
    
}

extension PlayHistory: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.track = try container.decode(Track.self, forKey: .track)
        self.playedAt = try container.decodeSpotifyTimestamp(
            forKey: .playedAt
        )
        self.context = try container.decodeIfPresent(
            SpotifyContext.self, forKey: .context
        )

    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(
            self.track, forKey: .track
        )
        try container.encodeSpotifyTimestamp(
            self.playedAt, forKey: .playedAt
        )
        try container.encodeIfPresent(
            self.context, forKey: .context
        )
        
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case track
        case playedAt = "played_at"
        case context
    }
    
}

extension PlayHistory: ApproximatelyEquatable {
 
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.

     ``PlayHistory/playedAt`` is compared using `timeIntervalSince1970`, so it
     is considered a floating point property for the purposes of this method.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
        
        return self.context == other.context &&
                self.playedAt.isApproximatelyEqual(to: other.playedAt) &&
                self.track.isApproximatelyEqual(to: other.track)
                
    }

}
