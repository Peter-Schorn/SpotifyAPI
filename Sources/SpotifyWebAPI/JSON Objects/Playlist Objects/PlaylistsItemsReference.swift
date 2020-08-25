import Foundation

/**
 Provides a link to the endpoint that retrieves the full list
 of tracks/episodes in a playlist.
 
 For example, the endpoint that retrieves a list
 of all the user's playlists returns this object inside
 of every playlist, instead of an array of tracks,
 which prevents the response from becoming too long.
 */
public struct PlaylistsItemsReference: Codable, Hashable {
    
    /// A link to the Spotify web API endpoint
    /// providing the full list of tracks/episodes.
    public let href: String?

    /// The total number of tracks/episodes.
    public let total: Int
    
}
