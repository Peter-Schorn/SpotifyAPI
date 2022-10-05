import Foundation

/**
 A saved track object, saved album object, saved episode object,
 or saved show object.
 
 This is used when retrieving content from a user's library. It contains just
 three properties:
 
 * ``addedAt``: The date the item was added.
 * ``item``: The item that was saved.
 * ``type``: ``IDCategory/track`` if this is a saved track object,
   ``IDCategory/album`` if this is a saved album object, or ``IDCategory/show``
   if this is a saved show object.
 */
public struct SavedItem<Item: Codable & Hashable>: Hashable {
    
    /// The date the item was added.
    public let addedAt: Date
    
    /// The item that was saved in this ``SavedItem``. Either a track, album,
    /// episode, or show.
    ///
    /// See also ``type``.
    public let item: Item
    
    /**
     ``IDCategory/track`` if this is a saved track object,
     ``IDCategory/album`` if this is a saved album object,
     ``IDCategory/episode`` if this is a saved episode object, or
     ``IDCategory/show`` if this is a saved show object.
     */
    public let type: IDCategory
    
    /**
     Creates a Saved Item object.
     
     The type of `Item` should only be ``Track``, ``Album``, or ``Show``, and
     this should match ``type``.
     
     - Parameters:
       - addedAt: The date the item was added.
       - item: The item that was saved in this ``SavedItem``.
       - type: ``IDCategory/track`` if this is a saved track object,
             ``IDCategory/album`` if this is a saved album object,
             ``IDCategory/episode`` if this is a saved episode object, or
             ``IDCategory/show`` if this is a saved show object.
     */
    public init(
        addedAt: Date,
        item: Item,
        type: IDCategory
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
            case is Episode.Type:
                self.item = try container.decode(
                    Item.self, forKey: .episode
                )
                self.type = .episode
            case is Show.Type:
                self.item = try container.decode(
                    Item.self, forKey: .show
                )
                self.type = .show
            default:
                let debugDescription = """
                    Expected type of Item to be either Track, Album, \
                    Episode, or Show, but got '\(Item.self)'
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
        
        try container.encode(
            self.type, forKey: .type
        )
        
        switch Item.self {
            case is Track.Type:
                try container.encode(
                    self.item, forKey: .track
                )
            case is Album.Type:
                try container.encode(
                    self.item, forKey: .album
                )
            case is Episode.Type:
                try container.encode(
                    self.item, forKey: .episode
                )
            case is Show.Type:
                try container.encode(
                    self.item, forKey: .show
                )
            default:
                let debugDescription = """
                    Expected type of Item to be either Track, Album, \
                    Episode, or Show, but got '\(Item.self)'
                    """
                let context = EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: debugDescription
                )
                throw EncodingError.invalidValue(
                    self.item,
                    context
                )
        }
        
    }
    
    private enum CodingKeys: String, CodingKey, Codable {
        case addedAt = "added_at"
        case track
        case album
        case show
        case episode
        case type
    }
    
}

extension SavedItem: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.

     ``SavedItem/addedAt`` is compared using `timeIntervalSince1970`, so it is
     considered a floating point property for the purposes of this method.

     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
        
        return self.type == other.type &&
                self.addedAt.isApproximatelyEqual(to: other.addedAt) &&
                self.item == other.item

    }

}

extension SavedItem where Item: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.

     Dates are compared using `timeIntervalSince1970`, so they are considered
     floating point properties for the purposes of this method.


     - Parameter other: Another instance of `Self`.
     */
    func isApproximatelyEqual(to other: Self) -> Bool {
        
        return self.type == other.type &&
                self.addedAt.isApproximatelyEqual(to: other.addedAt) &&
                self.item.isApproximatelyEqual(to: other.item)

    }

}
