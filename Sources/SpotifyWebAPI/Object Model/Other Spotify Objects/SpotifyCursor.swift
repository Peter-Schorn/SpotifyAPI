import Foundation

/**
 A Spotify Cursor object.
 
 Used to find the next or previous set of items in a ``CursorPagingObject``.
 
 See [get current user's recently played tracks][1] and
 ``SpotifyAPI/recentlyPlayed(_:limit:)``.

 [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-recently-played
 */
public struct SpotifyCursor: Codable, Hashable {
    
    /**
     The key to the item before the current item—a unix millisecond timestamp.
    
     Use this parameter to move back in time.
     
     Pass this value into
     ``TimeReference``.``TimeReference/before(_:)-swift.enum.case`` in order to
     reference the page of results that chronologically precede the current
     page.
     */
    public let before: String?
    
    /**
     The key to the item after the current item—a unix millisecond timestamp.
    
     Use this parameter to move forward in time.
     
     Pass this value into
     ``TimeReference``.``TimeReference/after(_:)-swift.enum.case`` in order to
     reference the page of results that chronologically succeed the current
     page.
     */
    public let after: String?
    
    /**
     Creates a Spotify Cursor object.
     
     Used to find the next or previous set of items in a ``CursorPagingObject``.
     
     - Parameters:
       - before: The key to the item before the current item.
       - after: The key to the item after the current item.
     */
    public init(
        before: String? = nil,
        after: String? = nil
    ) {
        self.before = before
        self.after = after
    }

}
