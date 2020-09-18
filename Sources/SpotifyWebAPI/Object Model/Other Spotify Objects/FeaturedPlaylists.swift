import Foundation

/**
 An array of simplified playlist objects wrapped in a paging object
 and a message that can be displayed to the user, such as
 "Good Morning", or "Editors's picks".
 
 Returned by the endpoint for a [list of featured playlists][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/browse/get-list-featured-playlists/
 */
public struct FeaturedPlaylists: Codable, Hashable {
    
    /// A message that can be displayed to the user, such as
    /// "Good Morning", or "Editors's picks".
    public let message: String?
    
    /// The featured playlists.
    public let playlists: PagingObject<Playlist<PlaylistsItemsReference>>
    
}
