import Foundation


/**
 A Spotify [paging object][1].
 
 The offset-based paging object is a container for a set of objects.
 It contains a key called items
 (whose value is an array of the requested objects)
 along with other keys like previous,
 next and limit that can be useful in future calls.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#paging-object
 */
public struct PagingObject<
    Object: Codable & Hashable
>: Codable, Hashable {
    
    /// A link to the Spotify web API endpoint returning
    /// the full result of the request.
    public let href: String
    
    /// An array of the requested data.
    public let items: [Object]
     
    /// The maximum number of items in the response
    /// (as set in the query or by default).
    public let limit: Int
    
    /// The url to the next page of items, or `nil` if none.
    public let next: String?
    
    /// url to the previous page of items or `nil` if none.
    public let previous: String?

    /// The offset of the items returned
    /// (as set in the query or by default).
    public let offset: Int

    /// The maximum number of items available to return.
    public let total: Int
    
    
}
