import Foundation

/**
 A Spotify Cursor object.
 
 Used to find the next or previous set of items in a ``CursorPagingObject``.
 
 See [get current user's recently played tracks][2] and
 ``SpotifyAPI/recentlyPlayed(_:limit:)``.

 Read more at the [Spotify web API reference][1].

 [1]: https://developer.spotify.com/documentation/web-api/reference/#object-cursorobject
 [2]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-recently-played
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
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - before: The key to the item before the current item.
       - after: The key to the item after the current item.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#object-cursorobject
     */
    public init(
        before: String? = nil,
        after: String? = nil
    ) {
        self.before = before
        self.after = after
    }

}
