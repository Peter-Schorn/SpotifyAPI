import Foundation

/**
 A [saved track object][1], [saved album object][2], or
 [saved show object][3].
 
 This is used when retrieving content from a user's library.
 It contains just three properties:
 
 * `addedAt`: The date the item was added.
 * `item`: The item that was saved.
 * `itemName`: `track` if this is a saved track object,
   `album` if this is a saved album object, or
   `show` if this is a saved show object.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-track-object
 [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-album-object
 [3]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-show-object
 */
public struct SavedItem<Item: Codable & Hashable>: Hashable {
    
    /// The date the item was added.
    public let addedAt: Date
    
    /// The item that was saved in this `SavedItem`.
    /// Either a track, album, or show.
    ///
    /// See also `type`.
    public let item: Item
    
    /**
     `track` if this is a [saved track object][1],
     `album` if this is a [saved album object][2], or
     `show` if this is a [saved show object][3].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-track-object
     [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-album-object
     [3]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-show-object
     */
    public let type: CodingKeys
    
    /**
     Creates a Saved Item object.
     
     The type of `Item` should only be `Track`, `Album`, or `Show`,
     and this should match `type`.
     
     - Parameters:
       - addedAt: The date the item was added.
       - item: The item that was saved in this `SavedItem`.
       - type: `track` if this is a [saved track object][1],
             `album` if this is a [saved album object][2], or
             `show` if this is a [saved show object][3].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-track-object
     [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-album-object
     [3]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-show-object
     */
    public init(
        addedAt: Date,
        item: Item,
        type: SavedItem<Item>.CodingKeys
    ) {
        self.addedAt = addedAt
        self.item = item
        self.type = type
    }

}


extension SavedItem: Codable {

    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.addedAt = try container.decodeSpotifyTimestamp(
            forKey: .addedAt
        )
        
        
        switch Item.self {
            case is Track.Type:
                self.item = try container.decode(
                    Item.self, forKey: .track
                )
                self.type = .track
            case is Album.Type:
                self.item = try container.decode(
                    Item.self, forKey: .album
                )
                self.type = .album
            case is Show.Type:
                self.item = try container.decode(
                    Item.self, forKey: .show
                )
                self.type = .show
            default:
                let debugDescription = """
                    Expected generic type Item be either Track, Album, or \
                    Show, but got '\(Item.self)'
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
        
        try container.encodeSpotifyTimestamp(
            self.addedAt, forKey: .addedAt
        )
        
        guard Self.itemTypes.contains(self.type) else {
            let debugDescription = """
                expected self.type to be one of the following:
                \(Self.itemTypes.map(\.rawValue))
                but got '\(self.type.rawValue)'
                """
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: debugDescription
                )
            )
        }
        
        try container.encode(
            self.item, forKey: self.type
        )
        try container.encode(
            self.type, forKey: .type
        )
        
    }
    
    /// The possible types for `self.item`. See also `self.type`.
    public static var itemTypes: [CodingKeys] { [.track, .album, .show] }
    
    public enum CodingKeys: String, CodingKey, Codable {
        case addedAt = "added_at"
        case track
        case album
        case show
        case type
    }
    
}
