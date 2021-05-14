import Foundation

/**
 Holds a track or podcast episode that is contained in a playlist, as well as
 additional information about its relationship to the playlist. Spotify
 confusingly refers to this as a [playlist track object][1].
 
 Contains the following properties:
 
 * `addedAt`: The date and time the track or episode was added.
 * `addedBy`: The Spotify user who added the track or episode.
 * `isLocal`: Whether or not the track or episode is from a [local file][3].
 * `item`: Either a `Track`, `Episode`, or `PlaylistItem`  (simplified version).
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/#object-playlisttrackobject
 [2]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#local-files
 [3]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#local-files
 */
public struct PlaylistItemContainer<Item>: Hashable where
    Item: Codable & Hashable

{
    
    /// The date and time the track or episode was added.
    ///
    /// Note that some very old playlists may return `nil` for this property.
    public let addedAt: Date?
    
    /// The Spotify user who added the track or episode.
    ///
    /// Note that some very old playlists may return `nil` for this property.
    public let addedBy: SpotifyUser?
    
    /**
     Whether or not the item is from a [local file][1].
     
     When this is `true`, expect many of the other properties to be `nil`.
    
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#local-files
     */
    public let isLocal: Bool?

    /// Either a `Track`, `Episode`, or `PlaylistItem` (simplified version) in
    /// this `PlaylistItemContainer`.
    public let item: Item?
    
    /**
     Holds a track or podcast episode that is contained in a playlist, as well
     as additional information about its relationship to the playlist. Spotify
     confusingly refers to this as a [playlist track object][1].
     
     - Parameters:
       - addedAt: The date and time the track or episode was added.
       - addedBy: The Spotify user who added the track or episode.
       - isLocal: Whether or not the item is from a [local file][1].
       - item: Either a `Track`, `Episode`, or `PlaylistItem` (simplified
             version).
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#object-playlisttrackobject
     [2]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#local-files
     */
    public init(
        addedAt: Date? = nil,
        addedBy: SpotifyUser? = nil,
        isLocal: Bool? = nil,
        item: Item?
    ) {
        self.addedAt = addedAt
        self.addedBy = addedBy
        self.isLocal = isLocal
        self.item = item
    }

}

extension PlaylistItemContainer: Codable {

    private enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case addedBy = "added_by"
        case isLocal = "is_local"
        case item = "track"
    }
    
    /// :nodoc:
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
        
        self.item = try container.decodeIfPresent(
            Item.self, forKey: .item
        )
        
    }
    
    /// :nodoc:
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
        try container.encodeIfPresent(
            self.item, forKey: .item
        )
        
    }
    
    
}

extension PlaylistItemContainer: ApproximatelyEquatable {
 
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
     `PlaylistItemContainer.addedAt` is compared using `timeIntervalSince1970`,
     so it is considered a floating point property for the purposes of this
     method.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
        
        return self.addedAt.isApproximatelyEqual(to: other.addedAt) &&
                self.isLocal == other.isLocal &&
                self.addedBy == other.addedBy &&
                self.addedAt.isApproximatelyEqual(to: other.addedAt)

    }

}
