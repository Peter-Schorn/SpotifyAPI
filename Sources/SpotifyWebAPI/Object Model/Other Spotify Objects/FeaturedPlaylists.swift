import Foundation

/**
 An array of simplified playlist objects wrapped in a paging object and a
 message that can be displayed to the user, such as "Good Morning", or "Editor's
 picks".
 
 Returned by the endpoint for a [list of featured playlists][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-featured-playlists
 */
public struct FeaturedPlaylists: Codable, Hashable {
    
    /// A message that can be displayed to the user, such as
    /// "Good Morning", or "Editor's picks".
    public let message: String?
    
    /// The featured playlists.
    public let playlists: PagingObject<Playlist<PlaylistItemsReference>>
    
    /**
     Creates a Featured Playlists object.
     
     Returned by the endpoint for a [list of featured playlists][1].
     
     - Parameters:
       - message: A message that can be displayed to the user, such as "Good
             Morning", or "Editor's picks".
       - playlists: The featured playlists.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-featured-playlists
     */
    public init(
        message: String? = nil,
        playlists: PagingObject<Playlist<PlaylistItemsReference>>
    ) {
        self.message = message
        self.playlists = playlists
    }

}
