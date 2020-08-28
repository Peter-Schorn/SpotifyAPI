import Foundation

public struct PlayHistory: Hashable {
    
    /// The track that the user listened to (simplified version).
    public let track: Track
    
    /// The date and time the track was played.
    public let playedAt: Date
    
    /// The context the track was played from, such as
    /// an album or artist.
    public let context: SpotifyContext?
    
}

extension PlayHistory: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.track = try container.decode(Track.self, forKey: .track)
        self.playedAt = try container.decodeSpotifyTimestamp(
            forKey: .playedAd
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
            self.playedAt, forKey: .playedAd
        )
        try container.encodeIfPresent(
            self.context, forKey: .context
        )
        
    }
    
    
    
    public enum CodingKeys: String, CodingKey {
        case track
        case playedAd = "played_at"
        case context
    }
    
}

