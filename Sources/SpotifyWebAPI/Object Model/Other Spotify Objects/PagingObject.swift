import Foundation
import Combine
import Logger

/**
 A Spotify [paging object][1].
 
 The offset-based paging object is a container for a set of objects.
 It contains a key called items
 (whose value is an array of the requested objects)
 along with other keys like previous,
 next and limit that can be useful in future calls.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#paging-object
 */
public struct PagingObject<Item: Codable & Hashable>: Paginated {
    
    static var logger: Logger {
        Logger(label: "PagingObject", level: .critical)
    }
    
    /**
     A link to the Spotify web API endpoint returning
     the full result of the request in this `PagingObject`.
     
     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in the type of this
     `PagingObject` to retrieve the results.
     */
    public let href: String
    
    /// An array of the requested data in this `PagingObject`.
    public let items: [Item]
     
    /// The maximum number of items in this page (as set in the
    /// query or by default) in this `PagingObject`.
    public let limit: Int
    
    /**
     The URL (href) to the next page of items or `nil` if none.
    
     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in the type of this
     `PagingObject` to retrieve the results.
     */
    public let next: String?
    
    /**
     The URL (href) to the previous page of items or `nil` if none
     in this `PagingObject`.
    
     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in the type of this
     `PagingObject` to retrieve the results.
     */
    public let previous: String?

    /// The offset of the items returned (as set in the query or
    /// by default) in this `PagingObject`.
    public let offset: Int

    /// The maximum number of items available to return in this
    /// `PagingObject`.
    public let total: Int
    
}

// MARK: - Convienence Methods -

extension PagingObject {
    
    /**
     The total number of pages available, including this page.
     
     This property is calculated by dividing `total` by `limit`
     and rounding up to the nearest integer. For example, if `total` is
     745 and `limit` is 100, then `totalPages` is 8.
     
     `total` represents the maximum number of items available to return.
     `limit` represents the number of items in this page. (as set in the
     query or by default
     
     - Warning: This calculation assumes that the limit for each page
           will be the same as *this* page.
     */
    public var totalPages: Int {
        
        let itemsCount = items.count
        // avoid division by zero error
        if itemsCount == 0 { return 1 }
        
        // performs integer division and rounds up the result.
        // equivalent to `Int(ceil(Double(total) / Double(itemsCount)))`,
        // but avoids unnecessary type conversion
        // see https://stackoverflow.com/a/17974/12394554
        let totalPages = (total + itemsCount - 1) / itemsCount
        Self.logger.trace("total pages: \(totalPages)")
        return totalPages
    }
    
    
}

extension PagingObject: Codable {
    
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
