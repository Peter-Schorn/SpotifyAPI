import Foundation

/**
 A cursor-based paging object.
 
 See [get current user's recently played tracks][2] and
 ``SpotifyAPI/recentlyPlayed(_:limit:)``.
 
 See also <doc:Working-with-Paginated-Results>.
 
 Read more at the [Spotify web API reference][1].

 [1]: https://developer.spotify.com/documentation/web-api/reference/#object-cursorobject
 [2]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-recently-played
 */
public struct CursorPagingObject<Item: Codable & Hashable>:
    Paginated, Hashable
{
    
    /**
     A link to the Web API endpoint returning the full result of the request.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)`` to retrieve the results.
     */
    public let href: URL
    
    /// An array of the requested data in this ``CursorPagingObject``.
    public let items: [Item]
     
    /// The maximum number of items in the response (as set in the query or by
    /// default).
    public let limit: Int
    
    /**
     The URL to the next page of items, or `nil` if none.
    
     Use ``SpotifyAPI/getFromHref(_:responseType:)`` to retrieve the results.
     
     See also <doc:Working-with-Paginated-Results>.
     */
    public let next: URL?
    
    /// Used to find the next and previous items.
    public let cursors: SpotifyCursor?
    
    /// The maximum number of items available to return.
    public let total: Int?
    
    /**
     Creates a cursor-based paging object.
     
     See [get current user's recently played tracks][2]
     and ``SpotifyAPI/recentlyPlayed(_:limit:)``.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - href: A link to the Web API endpoint returning the full result of the
             request.
       - items: An array of the requested data in this ``CursorPagingObject``.
       - limit: The maximum number of items in the response.
       - next: The URL to the next page of items, or `nil` if none.
       - cursors: Used to find the next and previous items.
       - total: The maximum number of items available to return.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#object-cursorobject
     [2]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-recently-played
     */
    public init(
        href: URL,
        items: [Item],
        limit: Int,
        next: URL? = nil,
        cursors: SpotifyCursor? = nil,
        total: Int? = nil
    ) {
        self.href = href
        self.items = items
        self.limit = limit
        self.next = next
        self.cursors = cursors
        self.total = total
    }

}

extension CursorPagingObject: ApproximatelyEquatable where Item: ApproximatelyEquatable {
    
    public func isApproximatelyEqual(to other: CursorPagingObject<Item>) -> Bool {
        return self.href == other.href &&
                self.limit == other.limit &&
                self.next == other.next &&
                self.cursors == other.cursors &&
                self.total == other.total &&
                self.items.isApproximatelyEqual(to: other.items)
    }

}

extension CursorPagingObject: Codable {

    enum CodingKeys: String, CodingKey {
        case href
        case items
        case limit
        case next
        case cursors
        case total
    }

    private static func makeContainer(
        from decoder: Decoder
    ) throws -> KeyedDecodingContainer<CodingKeys> {
        
        let container: KeyedDecodingContainer<CursorPagingObject<Item>.CodingKeys>

        switch Item.self {
            case is Artist.Type:
                let topContainer = try decoder.container(keyedBy: AnyCodingKey.self)
                if let artistContainer = try? topContainer.nestedContainer(
                    keyedBy: CodingKeys.self,
                    forKey: .init("artists")
                ) {
                    container = artistContainer
                }
                else {
                    container = try decoder.container(keyedBy: CodingKeys.self)
                }
            default:
                container = try decoder.container(keyedBy: CodingKeys.self)
        }
        
        return container
    }

    public init(from decoder: Decoder) throws {
        
        let container = try Self.makeContainer(from: decoder)
        
        self.href = try container.decode(
            URL.self, forKey: .href
        )
        self.items = try container.decode(
            [Item].self, forKey: .items
        )
        self.limit = try container.decode(
            Int.self, forKey: .limit
        )
        self.next = try container.decodeIfPresent(
            URL.self, forKey: .next
        )
        self.cursors = try container.decodeIfPresent(
            SpotifyCursor.self, forKey: .cursors
        )
        self.total = try container.decodeIfPresent(
            Int.self, forKey: .total
        )


    }

    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(
            self.href, forKey: .href
        )
        try container.encode(
            self.items, forKey: .items
        )
        try container.encode(
            self.limit, forKey: .limit
        )
        try container.encodeIfPresent(
            self.next, forKey: .next
        )
        try container.encodeIfPresent(
            self.cursors, forKey: .cursors
        )
        try container.encodeIfPresent(
            self.total, forKey: .total
        )
        
    }

}
