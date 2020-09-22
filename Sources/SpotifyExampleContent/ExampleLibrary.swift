import Foundation
import SpotifyWebAPI


public extension PagingObject where Item == SavedItem<Album> {
    
    /// Sample data for testing purposes.
    static let currentUserSavedAlbums = Bundle.module.decodeJson(
        forResource: "Current User Saved Albums - PagingObject<SavedItem<Album>>",
        type: Self.self
    )!

}
