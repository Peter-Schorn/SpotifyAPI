import Foundation

/**
 A [cursor-based paging object][1].
 
 See [get current user's recently played tracks][2] and
 `SpotifyAPI.recentlyPlayed(_:limit:)`.
 
 See also [Working with Paginated Results][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/#object-cursorobject
 [2]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-recently-played
 [3]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Working-with-Paginated-Results
 */
public struct CursorPagingObject<Item: Codable & Hashable>:
    Paginated, Codable, Hashable
{
    
    /**
     A link to the Web API endpoint returning the full result of the request.
     
     Use `SpotifyAPI.getFromHref(_:responseType:)` to retrieve the results.
     */
    public let href: URL
    
    /// An array of the requested data in this `CursorPagingObject`.
    public let items: [Item]
     
    /// The maximum number of items in the response (as set in the query or by
    /// default).
    public let limit: Int
    
    /**
     The URL to the next page of items, or `nil` if none.
    
     Use `SpotifyAPI.getFromHref(_:responseType:)` to retrieve the results.
     
     See also [Working with Paginated Results][1].
     
     [1]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Working-with-Paginated-Results
     */
    public let next: URL?
    
    /// Used to find the next and previous items.
    public let cursors: SpotifyCursor?
    
    /// The maximum number of items available to return.
    public let total: Int?
    
    /**
     Creates a [cursor-based paging object][1].
     
     See [get current user's recently played tracks][2]
     and `recentlyPlayed(_:limit:)`.
     
     - Parameters:
       - href: A link to the Web API endpoint returning the full result of the
             request.
       - items: An array of the requested data in this `CursorPagingObject`.
       - limit: The maximum number of items in the response.
       - next: The URL to the next page of items, or `nil` if none.
       - cursors: Used to find the next and previous items.
       - total: The maximum number of items available to return.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#object-cursorobject
     [2]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-recently-played
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
