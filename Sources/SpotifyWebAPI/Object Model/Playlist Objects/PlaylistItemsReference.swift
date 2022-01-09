import Foundation

/**
 Provides a link to the endpoint that retrieves the full list of tracks/episodes
 in a playlist.

 For example, the endpoint that retrieves a list of all the user's playlists
 returns this object inside of every playlist, instead of an array of
 tracks/episodes, which prevents the response from becoming too long.
 */
public struct PlaylistItemsReference: Codable, Hashable {
    
    /**
     A link to the Spotify web API endpoint providing the full list of
     tracks/episodes.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)`` to retrieve the results,
     passing in ``PlaylistItems`` as the response type. Alternatively, use
     ``SpotifyAPI/playlistItems(_:limit:offset:market:)``, passing in the URI of
     this playlist.
     */
    public let href: URL?

    /// The total number of tracks/episodes.
    public let total: Int
    
    /**
     Creates a Playlist Items Reference object.
     
     Provides a link to the endpoint that retrieves the full list of
     tracks/episodes in a playlist.

     For example, the endpoint that retrieves a list of all the user's playlists
     returns this object inside of every playlist, instead of an array of
     tracks, which prevents the response from becoming too long.
     
     - Parameters:
       - href: A link to the Spotify web API endpoint providing the full list of
             tracks/episodes.
       - total: The total number of tracks/episodes.
     */
    public init(
        href: URL?,
        total: Int
    ) {
        self.href = href
        self.total = total
    }
    

}
