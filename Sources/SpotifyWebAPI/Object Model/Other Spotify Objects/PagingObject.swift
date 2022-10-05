import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import Logging

/**
 A Spotify paging object.
 
 The offset-based paging object is a container for a set of objects. It contains
 a property called ``items`` (whose value is an array of the requested objects)
 along with other properties like ``previous``, ``next`` and ``limit`` that can
 be useful in future calls.
 
 See <doc:Working-with-Paginated-Results>.

 See also ``SpotifyAPI/extendPages(_:maxExtraPages:)``,
 ``SpotifyAPI/extendPagesConcurrently(_:maxExtraPages:)``, and the combine
 operators of the same names.
 */
public struct PagingObject<Item: Codable & Hashable>: PagingObjectProtocol {
    
    /**
     A link to the Spotify web API endpoint returning the full result of the
     request in this ``PagingObject``.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in the type of
     this ``PagingObject``—NOT the type of `Item`—to retrieve the results.
     */
    public let href: URL
    
    /// An array of the requested data in this ``PagingObject``.
    public let items: [Item]
     
    /**
     The maximum number of items in **this** page (as set in the query or by
     default).

     This is not necessarily the same as the actual number of items in this
     page. For example, if this is the last page of results, then the actual
     number of items in this page may be less than ``limit``.

     See also ``total`` (the maximum number of items available to return).
     */
    public let limit: Int
    
    /**
     The URL (href) to the next page of items or `nil` if none in this
     ``PagingObject``.
    
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in the type of
     this ``PagingObject``—NOT the type of `Item`—to retrieve the results.
     
     See <doc:Working-with-Paginated-Results>.
     */
    public let next: URL?
    
    /**
     The URL (href) to the previous page of items or `nil` if none in this
     ``PagingObject``.
    
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in the type of
     this ``PagingObject``—NOT the type of `Item`—to retrieve the results.
     
     See <doc:Working-with-Paginated-Results>.
     */
    public let previous: URL?

    /// The offset of the items returned (as set in the query or by default) in
    /// this ``PagingObject``.
    public let offset: Int

    /**
     The maximum number of items available to return.
     
     In other words, this is the total number of items in all available pages.
     
     See also ``limit`` (the maximum number of items in **this** page).
     */
    public let total: Int
    
    /**
     Creates a Spotify paging object.
     
     The offset-based paging object is a container for a set of objects. It
     contains a key called items (whose value is an array of the requested
     objects) along with other keys like previous, next and limit that can be
     useful in future calls.
     
     - Parameters:
       - href: A link to the Spotify web API endpoint returning the full result
             of the request.
       - items: An array of the requested data in this ``PagingObject``.
       - limit: The maximum number of items in this page (as set in the
             query or by default).
       - next: The URL (href) to the next page of items or `nil` if none.
       - previous: The URL (href) to the previous page of items or `nil` if none
             in this ``PagingObject``.
       - offset: The offset of the items returned (as set in the query or by
             default).
       - total: The maximum number of items available to return.
     */
    public init(
        href: URL,
        items: [Item],
        limit: Int,
        next: URL? = nil,
        previous: URL? = nil,
        offset: Int,
        total: Int
    ) {
        self.href = href
        self.items = items
        self.limit = limit
        self.next = next
        self.previous = previous
        self.offset = offset
        self.total = total
    }

}

// MARK: - Convenience Methods -

extension PagingObject {
    
    /**
     The estimated total number of pages available, including this page.
     
     This property is calculated by dividing ``total`` by ``limit`` and rounding
     up to the nearest integer. For example, if ``total`` is 745 and ``limit``
     is 100, then ``estimatedTotalPages`` is 8.
     
     * ``total``: The maximum number of items available to return.
     * ``limit``: The maximum number of items in **this** page (as set in the
       query or by default). This is not necessarily the same as the actual
       number of items in this page. For example, if this is the last page of
       results, then the actual number of items in this page may be less than
       ``limit``.
     
     - Warning: This calculation assumes that the limit for each page will be
           the same as *this* page. If you request additional pages and provide
           a different value for ``limit``, then ``estimatedTotalPages`` may be
           incorrect.
     */
    public var estimatedTotalPages: Int {
        
        // avoid division by zero error
        if self.limit == 0 { return 1 }
        
        // Performs integer division and rounds up the result.
        // Equivalent to `Int(ceil(Double(total) / Double(limit)))`,
        // but avoids unnecessary type conversion.
        // See https://stackoverflow.com/a/17974/12394554
        return (self.total + self.limit - 1) / self.limit
    }
    
    /**
     The estimated zero-based index of this page based on the number of items in
     this page and the offset of this page.
     
     This property is calculated by dividing ``offset`` by ``limit``. For
     example, if ``limit`` is 100, then for an offset in 0...99
     ``estimatedIndex`` is 0, and for an offset in 100...199 ``estimatedIndex``
     is 1, and so on.
     
     * ``offset``: The offset of the items returned.
     * ``limit``: The maximum number of items in **this** page (as set in the
       query or by default). This is not necessarily the same as the actual
       number of items in this page. For example, if this is the last page of
       results, then the actual number of items in this page may be less than
       ``limit``.
     
     - Warning: This calculation assumes that the limit for each page will be
           the same as *this* page. If you request additional pages and provide
           a different value for ``limit``, then ``estimatedIndex`` may be
           incorrect.
     */
    public var estimatedIndex: Int {
        
        if self.limit == 0 { return 0 }
        return (self.offset / self.limit)

    }
    
}

// MARK: - Codable -

extension PagingObject: Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case href
        case items
        case limit
        case next
        case previous
        case offset
        case total
        
        case categories
        case playlists
        // SearchResult
        case artists
        case albums
        case tracks
        case episodes
        case shows
        case audiobooks
        
        static var topLevelKeys: [Self] {
            [
                .categories,
                .playlists,
                .artists,
                .albums,
                .tracks,
                .episodes,
                .shows,
                .audiobooks
            ]
        }

    }

    private static func makeContainer(
        from decoder: Decoder
    ) throws -> KeyedDecodingContainer<CodingKeys> {

        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        
        for key in CodingKeys.topLevelKeys {
            if container.contains(key) {
                return try container.nestedContainer(
                    keyedBy: CodingKeys.self,
                    forKey: key
                )
            }
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
        self.previous = try container.decodeIfPresent(
            URL.self, forKey: .previous
        )
        self.offset = try container.decode(
            Int.self, forKey: .offset
        )
        self.total = try container.decode(
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
            self.previous, forKey: .previous
        )
        try container.encode(
            self.offset, forKey: .offset
        )
        try container.encode(
            self.total, forKey: .total
        )
        
    }

}

// MARK: - Hashable -

extension PagingObject: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(href)
        hasher.combine(items)
        hasher.combine(limit)
        hasher.combine(next)
        hasher.combine(previous)
        hasher.combine(offset)
        hasher.combine(total)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.href == rhs.href &&
                lhs.items == rhs.items &&
                lhs.limit == rhs.limit &&
                lhs.next == rhs.next &&
                lhs.previous == rhs.previous &&
                lhs.offset == rhs.offset &&
                lhs.total == rhs.total
    }
    
}

extension PagingObject: ApproximatelyEquatable where Item: ApproximatelyEquatable {
    
    public func isApproximatelyEqual(to other: Self) -> Bool {
        
        return self.href == other.href &&
                self.limit == other.limit &&
                self.next == other.next &&
                self.previous == other.previous &&
                self.offset == other.offset &&
                self.total == other.total &&
                self.items.isApproximatelyEqual(to: other.items)

    }

}

/**
 An internal implementation detail required for creating publisher extensions
 where the output is a paging object.

 See ``PagingObject``, which conforms to this protocol.

 Do not conform additional types to this protocol.
 */
public protocol PagingObjectProtocol: Paginated {
    
    /// The type of the items that this paging object wraps.
    associatedtype Item: Codable & Hashable

    /**
     A link to the Spotify web API endpoint returning the full result of the
     request in this paging object.
     */
    var href: URL { get }
    
    /// An array of the requested data in this paging object.
    var items: [Item] { get }
    
    /// The maximum number of items in **this** page.
    var limit: Int { get }
    
    /// The URL (href) to the next page of items or `nil` if none.
    var next: URL? { get }
    
    /// The URL (href) to the previous page of items or `nil` if none
    var previous: URL? { get }
    
    /// The offset of the items returned.
    var offset: Int { get }
    
    /// The maximum number of items available to return.
    var total: Int { get }

}
