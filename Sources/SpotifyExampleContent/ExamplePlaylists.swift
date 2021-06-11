import Foundation
import SpotifyWebAPI

public extension PlaylistTracks {
    
    /// Sample data for testing purposes.
    static let thisIsJimiHendrix = Bundle.module.decodeJSON(
        forResource: "This is Jimi Hendrix - PagingObject<PlaylistItemContainer<Track>>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsPinkFloyd = Bundle.module.decodeJSON(
        forResource: "This is Pink Floyd - PagingObject<PlaylistItemContainer<Track>>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsMacDeMarco = Bundle.module.decodeJSON(
        forResource: "This is Mac DeMarco - PagingObject<PlaylistItemContainer<Track>>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsSpoon = Bundle.module.decodeJSON(
        forResource: "This Is Spoon - PagingObject<PlaylistItemContainer<Track>>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let bluesClassics = Bundle.module.decodeJSON(
        forResource: "Blues Classics - PagingObject<PlaylistItemContainer<Track>>",
        type: Self.self
    )!

}


public extension PlaylistItems {
    
    
    /// Sample data for testing purposes.
    static let thisIsStevieRayVaughan = Bundle.module.decodeJSON(
        forResource: "This is Stevie Ray Vaughan - PagingObject<PlaylistItemContainer<PlaylistItem>>",
        type: Self.self
    )!

}

public extension Playlist where Items == PlaylistItems {
    
    /// Sample data for testing purposes.
    ///
    /// This playlist episodes and local tracks. Local tracks
    /// often have most of their properties set to `nil`, which can be very
    /// useful for testing purposes.
    static let episodesAndLocalTracks = Bundle.module.decodeJSON(
        forResource: "Local Songs - Playlist<PagingObject<PlaylistItemContainer<PlaylistItem>>>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let crumb = Bundle.module.decodeJSON(
        forResource: "Crumb - Playlist<PagingObject<PlaylistItemContainer<PlaylistItem>>>",
        type: Self.self
    )!
    
}

public extension Playlist where Items == PlaylistItemsReference {
    
    /// Sample data for testing purposes.
    static let lucyInTheSkyWithDiamonds = Bundle.module.decodeJSON(
        forResource: "Lucy in the sky with diamonds - Playlist<PlaylistItemsReference>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsMFDoom = Bundle.module.decodeJSON(
        forResource: "This Is MF DOOM - Playlist<PlaylistItemsReference>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let rockClassics = Bundle.module.decodeJSON(
        forResource: "Rock Classics - Playlist<PlaylistItemsReference>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsSonicYouth = Bundle.module.decodeJSON(
        forResource: "This Is Sonic Youth - Playlist<PlaylistItemsReference>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsRadiohead = Bundle.module.decodeJSON(
        forResource: "This Is Radiohead - Playlist<PlaylistItemsReference>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsSkinshape = Bundle.module.decodeJSON(
        forResource: "This is Skinshape - Playlist<PlaylistItemsReference>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let modernPsychedelia = Bundle.module.decodeJSON(
        forResource: "Modern Psychedelia - Playlist<PlaylistItemsReference>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let thisIsMildHighClub = Bundle.module.decodeJSON(
        forResource: "This Is Mild High Club - Playlist<PlaylistItemsReference>",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let menITrust = Bundle.module.decodeJSON(
        forResource: "Men I Trust - Playlist<PlaylistItemsReference>",
        type: Self.self
    )!

}
