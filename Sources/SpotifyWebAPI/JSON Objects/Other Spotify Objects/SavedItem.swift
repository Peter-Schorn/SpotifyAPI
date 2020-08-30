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
    ///
    /// See also `itemName`.
    public let item: Item
    
    /**
     `track` if this is a [saved track object][1],
     `album` if this is a [saved album object][2], or
     `show` if this is a [saved show object][3].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-track-object
     [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-album-object
     [3]: https://developer.spotify.com/documentation/web-api/reference/object-model/#saved-show-object
     */
    public var itemName: CodingKeys
    
}


extension SavedItem: Codable {

    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.addedAt = try container.decodeSpotifyTimestamp(
            forKey: .addedAt
        )
        
        for key in CodingKeys.itemKeys {
            
            if let item = try? container.decode(
                Item.self, forKey: key
            ) {
                self.item = item
                self.itemName = key
                return
            }
        }
        
        let debugDescription = """
            expected to find one of the following keys:
            \(CodingKeys.itemKeys.map(\.rawValue))
            """
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: debugDescription
            )
        )
        
    }
    
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeSpotifyTimestamp(
            self.addedAt, forKey: .addedAt
        )
        
        guard CodingKeys.itemKeys.contains(self.itemName) else {
            let debugDescription = """
                expected self.itemName to be one of the following:
                \(CodingKeys.itemKeys.map(\.rawValue))
                but got '\(self.itemName)'
                """
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: debugDescription
                )
            )
        }
        
        try container.encode(
            self.item, forKey: self.itemName
        )
        
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case track
        case album
        case show
        
        public static let itemKeys: [Self] = [.track, .album, .show]
    }
    
}
