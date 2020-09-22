import Foundation
import SpotifyWebAPI

public extension PagingObject where Item == Playlist<PlaylistsItemsReference> {
    
    /// Sample data for testing purposes.
    static let categoryPlaylists = Bundle.module.decodeJson(
        forResource: "Category Playlists - PagingObject<Playlist<PlaylistsItemsReference>>",
        type: Self.self
    )!
    
}

public extension FeaturedPlaylists {
    
    /// Sample data for testing purposes.
    static let featuredPlaylists = Bundle.module.decodeJson(
        forResource: "Featured Playlists - FeaturedPlaylists",
        type: Self.self
    )!

}

public extension SpotifyCategory {
    
    /// Sample data for testing purposes.
    static let categories = Bundle.module.decodeJson(
        forResource: "categories - SpotifyCategory",
        type: Self.self
    )!

}
