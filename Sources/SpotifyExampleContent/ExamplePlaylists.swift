import Foundation
import SpotifyWebAPI

public extension PagingObject where Item == PlaylistItemContainer<Track> {
    
    /// Sample data for testing purposes.
    static let thisIsJimiHendrix = Bundle.module.decodeJson(
        forResource: "This is Jimi Hendrix - PagingObject<PlaylistItemContainer<Track>>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsPinkFloyd = Bundle.module.decodeJson(
        forResource: "This is Pink Floyd - PagingObject<PlaylistItemContainer<Track>>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsMacDeMarco = Bundle.module.decodeJson(
        forResource: "This is Mac DeMarco - PagingObject<PlaylistItemContainer<Track>>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsSpoon = Bundle.module.decodeJson(
        forResource: "This Is Spoon - PagingObject<PlaylistItemContainer<Track>>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let bluesClassics = Bundle.module.decodeJson(
        forResource: "Blues Classics - PagingObject<PlaylistItemContainer<Track>>",
        type: Self.self
    )!

}

public extension Playlist where Items == PlaylistItems {
    
    /// Sample data for testing purposes.
    ///
    /// This playlist contains local tracks and episodes. Local tracks
    /// often have most of their properties set to `nil`, which can be very
    /// useful for testing purposes.
    static let localSongs = Bundle.module.decodeJson(
        // Playlist<PagingObject<PlaylistItemContainer<PlaylistItem>>>
        forResource: "Local Songs - Playlist<PagingObject<PlaylistItemContainer<PlaylistItem>>>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let crumb = Bundle.module.decodeJson(
        forResource: "Crumb - Playlist<PagingObject<PlaylistItemContainer<PlaylistItem>>>",
        type: Self.self
    )!
    
}

public extension PagingObject where Item == PlaylistItemContainer<PlaylistItem> {
    
    
    /// Sample data for testing purposes.
    static let thisIsStevieRayVaughan = Bundle.module.decodeJson(
        forResource: "This is Stevie Ray Vaughan - PagingObject<PlaylistItemContainer<PlaylistItem>>",
        type: Self.self
    )!

}

