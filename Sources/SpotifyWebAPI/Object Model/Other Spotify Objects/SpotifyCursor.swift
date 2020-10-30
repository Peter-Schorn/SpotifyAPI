import Foundation

/**
 A [Spotify Cursor][1] object.
 
 Used to find the next or previous set of items in a `CursorPagingObject`.
 
 See also [Get Current User's Recently Played Tracks][2].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#cursor-object
 [2]: https://developer.spotify.com/documentation/web-api/reference/player/get-recently-played/#secondary-navbar:~:text=The%20endpoint%20uses%20a%20bidirectional%20cursor,link%20will%20page%20back%20in%20time.
 */
public struct SpotifyCursor: Codable, Hashable {
    
    /// The key to the item before the current item.
    ///
    /// Use this parameter to move back in time.
    public let before: String?
    
    /// The key to the item after the current item.
    ///
    /// Use this parameter to move forward in time.
    public let after: String?
    
    /**
     Creates a [Spotify Cursor][1] object.
     
     Used to find the next or previous set of items in a `CursorPagingObject`.
     
     - Parameters:
       - before: The key to the item before the current item.
       - after: The key to the item after the current item.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#cursor-object
     */
    public init(
        before: String? = nil,
        after: String? = nil
    ) {
        self.before = before
        self.after = after
    }

}
