import Foundation

/**
 A track or podcast episode that is contained in a playlist.
 Spotify confusingly refers to this as a [playlist track object][1].
 
 Holds data not associated with the track/episode itself,
 including the date it was addded to the playlist, and who it was
 added by.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#playlist-track-object
 [2]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#local-files
 */
public struct PlaylistItem<Item>: Hashable where
    Item: Codable & Hashable

{
    /// The date and time the track or episode was added.
    ///
    /// Note that some very old playlists may
    /// return `nil` for this property.
    public let addedAt: Date?
    
    /// The Spotify user who added the track or episode.
    ///
    /// Note that some very old playlists may
    /// return `nil` for this property.
    public let addedBy: SpotifyUser?
    
    /// Whether or not the item is from a [local file][1].
    /// Expect many of the other properties to be nil when
    /// this is `true`.
    ///
    /// [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#local-files
    public let isLocal: Bool?
    
    /// Either a track or an episode object (simplified version).
    public let item: Item

}


extension PlaylistItem: Codable {

    public enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case addedBy = "added_by"
        case isLocal = "is_local"
        case item = "track"
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        
        self.addedAt = try container.decodeSpotifyTimestampIfPresent(
            forKey: .addedAt
        )
        self.addedBy = try container.decodeIfPresent(
            SpotifyUser.self, forKey: .addedBy
        )
        self.isLocal = try container.decodeIfPresent(
            Bool.self, forKey: .isLocal
        )
        self.item = try container.decode(Item.self, forKey: .item)
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        try container.encodeSpotifyTimestampIfPresent(
            self.addedAt, forKey: .addedAt
        )
        try container.encode(
            self.addedBy, forKey: .addedBy
        )
        try container.encodeIfPresent(
            self.isLocal, forKey: .isLocal
        )
        try container.encode(
            self.item, forKey: .item
        )
        
    }
    
    
}
