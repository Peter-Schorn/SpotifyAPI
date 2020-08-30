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
        Logger(label: "PagingObject", level: .trace)
    }
    
    /**
     A link to the Spotify web API endpoint returning
     the full result of the request.
     
     Use `getFromHref(_:responseType:)`, passing in the type of this
     `PagingObject` to retrieve the results.
     */
    public let href: String
    
    /// An array of the requested data in this `PagingObject`.
    public let items: [Item]
     
    /// The maximum number of items in the response
    /// (as set in the query or by default).
    public let limit: Int
    
    /**
     The URL (href) to the next page of items or `nil` if none.
    
     Use `getFromHref(_:responseType:)`, passing in the type of this
     `PagingObject` to retrieve the results.
    
     See also `getPage(atOffset:limit:)`.
     */
    public let next: String?
    
    /**
     The URL (href) to the previous page of items or `nil` if none.
    
     Use `getFromHref(_:responseType:)`, passing in the type of this
     `PagingObject` to retrieve the results.
    
     See also `getPage(atOffset:limit:)`.
     */
    public let previous: String?

    /// The offset of the items returned
    /// (as set in the query or by default).
    public let offset: Int

    /// The maximum number of items available to return.
    public let total: Int
    
    /// Do **NOT** use this method. Use `getPage(atOffset:limit:)` instead.
    var _getPage: (
        (_ atOffset: Int, _ limit: Int?) -> AnyPublisher<Self, Error>
    )? = nil
    
}

// MARK: - Convienence Methods -

extension PagingObject {
    
    /**
     The total number of pages available, including this page.
     
     This property is calculated by dividing `total` by `items.count`
     and rounding up to the nearest integer. For example, if `total` is
     745 and `items.count` is 100, then `totalPages` is 8.
     
     `total` represents the maximum number of items available to return.
     `items.count` represents the number of items in this page.
     
     - Warning: This calculation assumes that the limit for each page
           will be the same as *this* page.
     */
    public var totalPages: Int {
        
        let itemsCount = items.count
        // avoid division by zero error
        if itemsCount == 0 { return 1 }
        
        // performs integer division and rounds up the result.
        // equivalent to `Int(ceil(Double(total) / Double(itemsCount)))`,
        // but avoids unecessary type conversion
        // see https://stackoverflow.com/a/17974/12394554
        let totalPages = (total + itemsCount - 1) / itemsCount
        Self.logger.trace("total pages: \(totalPages)")
        return totalPages
    }
    
    /**
     Gets a page of results at the specified offset.
     
     Unless you need to request multiple pages asyncronously,
     consider using `SpotifyAPI.extendPages(_:maxExtraPages:)`
     or the combine operator of the same name instead of this method.
     
     This method calls through to a partially applied version of
     the `SpotifyAPI` method that this `PagingObject` was originally
     retrieved from, with all parameters except the offset and limit fixed
     to the values that were used to retrieve this `PagingObject`.
     
     If this `PagingObject` was retrieved from a method that does not have
     `offset` and `limit` parameters, such as `playlist(_:market:)` and
     `createPlaylist(for:_:)`, then this method returns `nil` and you should
     never call it in the first place.
     
     See also:
     
     * `totalPages`: The total number of pages available.
     * `total`: The maximum number of items available to return.
     * `offset`: The offset of the items returned.
     * `next`: The URL to the next page of items, or `nil` if none.
     * `previous`: The URL to the previous page of items or `nil` if none.
     
     `atOffset` should either be greater than or equal to
     ```
     self.offset + self.items.count
     ```
     or less than or equal to
     ```
     self.offset - self.items.count + limit
     ```
     where `limit` is the argument to this function (not the instance property of
     the same name). Otherwise, you will retrieve results that are already
     contained in this page.
     
     It should also be less than `self.total`, which is the maximum number of
     items available to return, otherwise you will get an empty array of items.
     
     - Parameters:
       - atOffset: The offset of the results to return.
             **This does not represent a page number**.
       - limit: The maximum number of results to return. Leave as `nil` to
             use the default limit for the endpoint that this `PagingObject`
             was retrieved from.
     - Returns: Another Paging object with the requested results.
     */
    public func getPage(
        atOffset: Int, limit: Int? = nil
    ) -> AnyPublisher<Self, Error>? {
        
        #if DEBUG
        if atOffset >= total {
            print(
                """
                ---------------------------------------------------------------
                \(Self.self).getPage(atOffset:limit:) WARNING: The offset of the
                items you are retrieving (\(atOffset)) is greater than or equal to
                the total number of items available (\(total)). You will almost
                certainly receive an empty array of results.
                ---------------------------------------------------------------
                """
            )
        }
        else {
            let limitString = limit.map(String.init) ?? "nil"
            let warning = """
            ---------------------------------------------------------------
            \(Self.self).getPage(atOffset:limit:) WARNING: the \
            range of items that you are retrieving (offset: \(atOffset); \
            limit: \(limitString)) overlaps with the range of items in this
            page (\(self.offset)-\(self.offset + self.limit)). You will \
            retrieve duplicate items.
            ---------------------------------------------------------------
            """
            let currentPageRange = self.offset..<self.items.count
            if currentPageRange.contains(atOffset) {
                print(warning)
            }
            else if let limit = limit, currentPageRange.contains(
                atOffset + limit
            ) {
                print(warning)
            }
        }
        #endif
        
        return self._getPage?(atOffset, limit)
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
