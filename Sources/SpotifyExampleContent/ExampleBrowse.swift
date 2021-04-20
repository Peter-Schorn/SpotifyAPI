import Foundation
import SpotifyWebAPI

public extension PagingObject where Item == Playlist<PlaylistItemsReference> {
    
    /// Sample data for testing purposes.
    static let sampleCategoryPlaylists = Bundle.module.decodeJSON(
        forResource: "Category Playlists - PagingObject<Playlist<PlaylistItemsReference>>",
        type: Self.self
    )!
    
}

public extension FeaturedPlaylists {
    
    /// Sample data for testing purposes.
    static let sampleFeaturedPlaylists = Bundle.module.decodeJSON(
        forResource: "Featured Playlists - FeaturedPlaylists",
        type: Self.self
    )!

}

public extension SpotifyCategory {
    
    /// Sample data for testing purposes.
    static let sampleCategories = Bundle.module.decodeJSON(
        forResource: "categories - SpotifyCategory",
        type: Self.self
    )!

}
