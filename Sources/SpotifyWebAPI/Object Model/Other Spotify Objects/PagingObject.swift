//import Foundation
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
import Logging

/**
 A Spotify [paging object][1].
 
 The offset-based paging object is a container for a set of objects.
 It contains a key called items (whose value is an array of the requested
 objects) along with other keys like `previous`, `next` and `limit` that can be
 useful in future calls.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#paging-object
 */
public struct PagingObject<Item: Codable & Hashable>: Paginated {
    
    /**
     A link to the Spotify web API endpoint returning
     the full result of the request in this `PagingObject`.
     
     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in the type of this
     `PagingObject`—NOT the type of `Item`—to retrieve the results.
     */
    public let href: String
    
    /// An array of the requested data in this `PagingObject`.
    public let items: [Item]
     
    /**
     The maximum number of items in **this** page (as set in the
     query or by default).
     
     This is not necessarily the same as the actual number of items in
     this page. For example, if this is the last page of results, then
     the actual number of items in this page may be less than `limit`.

     See also `total` (the maximum number of items available to return).
     */
    public let limit: Int
    
    /**
     The URL (href) to the next page of items or `nil` if none.
    
     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in the type of this
     `PagingObject`—NOT the type of `Item`—to retrieve the results.
     */
    public let next: String?
    
    /**
     The URL (href) to the previous page of items or `nil` if none
     in this `PagingObject`.
    
     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in the type of this
     `PagingObject`—NOT the type of `Item`—to retrieve the results.
     */
    public let previous: String?

    /// The offset of the items returned (as set in the query or
    /// by default) in this `PagingObject`.
    public let offset: Int

    /**
     The maximum number of items available to return.
     
     See also `limit` (the maximum number of items in **this** page).
     */
    public let total: Int
    
    /**
     Creates a Spotify [paging object][1].
     
     The offset-based paging object is a container for a set of objects.
     It contains a key called items (whose value is an array of the requested
     objects) along with other keys like previous, next and limit that can be
     useful in future calls.
     
     - Parameters:
       - href: A link to the Spotify web API endpoint returning
             the full result of the request.
       - items: An array of the requested data in this `PagingObject`.
       - limit: The maximum number of items in this page (as set in the
             query or by default).
       - next: The URL (href) to the next page of items or `nil` if none.
       - previous: The URL (href) to the previous page of items or `nil`
             if none in this `PagingObject`.
       - offset: The offset of the items returned (as set in the query or
             by default).
       - total: The maximum number of items available to return.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#paging-object
     */
    public init(
        href: String,
        items: [Item],
        limit: Int,
        next: String? = nil,
        previous: String? = nil,
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

// MARK: - Convienence Methods -

extension PagingObject {
    
    /**
     The estimated total number of pages available, including this page.
     
     This property is calculated by dividing `total` by `limit`
     and rounding up to the nearest integer. For example, if `total` is
     745 and `limit` is 100, then `estimatedTotalPages` is 8.
     
     * `total` The maximum number of items available to return.
     * `limit` The maximum number of items in **this** page (as set
       in the query or by default). This is not necessarily the same as the
       actual number of items in this page. For example, if this is the last
       page of results, then the actual number of items in this page may be
       less than `limit`.
     
     - Warning: This calculation assumes that the limit for each page
           will be the same as *this* page. If you request additional pages
           and provide a different value for `limit`, then
          `estimatedTotalPages` may be incorrect.
     */
    public var estimatedTotalPages: Int {
        
        // avoid division by zero error
        if limit == 0 { return 1 }
        
        // Performs integer division and rounds up the result.
        // Equivalent to `Int(ceil(Double(total) / Double(itemsCount)))`,
        // but avoids unnecessary type conversion.
        // See https://stackoverflow.com/a/17974/12394554
        return (total + limit - 1) / limit
    }
    
    
}

// MARK: - Codable -

extension PagingObject: Codable {
    
    /// :nodoc:
    public enum CodingKeys: String, CodingKey {
        case href
        case items
        case limit
        case next
        case previous
        case offset
        case total
    }
    
}

// MARK: - Hashable -

extension PagingObject: Hashable {
    
    /// :nodoc:
    public func hash(into hasher: inout Hasher) {
        hasher.combine(href)
        hasher.combine(items)
        hasher.combine(limit)
        hasher.combine(next)
        hasher.combine(previous)
        hasher.combine(offset)
        hasher.combine(total)
    }
    
    /// :nodoc:
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
