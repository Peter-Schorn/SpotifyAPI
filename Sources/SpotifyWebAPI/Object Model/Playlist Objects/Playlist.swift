import Foundation

/// A Spotify [playlist][1].
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#playlist-object-full
public struct Playlist<Items>: SpotifyURIConvertible, Hashable where
    Items: Codable & Hashable
{
    
    /// The name of the playlist.
    public let name: String
    
    /// The items in this `Playlist`. Consult the documentation
    /// for the specific endpoint that this playlist was retrieved
    /// from for more information.
    public internal(set) var items: Items
    
    /// The user who owns the playlist.
    public let owner: SpotifyUser?
    
    /**
     The playlist’s public/private status.
     
     If `true` the playlist is public; if `false`, the playlist is private.
     If `nil`, the playlist status is not relevant.
     
     For more about public/private status, see [Working with Playlists][1].
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#public-private-and-collaborative-status
     */
    public let isPublic: Bool?
    
    /// `true` if context is not search (you retrieved this playlist
    /// using the search endpoint) and the owner allows
    /// other users to modify the playlist. Else, `false`.
    public let collaborative: Bool
    
    /// The playlist description. Only returned for modified,
    /// verified playlists, else `nil`.
    public let description: String?
    
    /**
     The version identifier for the current playlist.

     Every time the playlist changes, a new [snapshot id][1] is generated.
     You can use this value to efficiently determine whether a playlist
     has changed since the last time you retrieved it.
     
     Can be supplied in other requests to target a specific
     playlist version: see [Remove tracks from a playlist][2].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/remove-tracks-playlist/
     [2]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    public let snapshotId: String
    
    /**
     Known [external urls][1] for this playlist.
     
     - key: The type of the URL, for example:
     "spotify" - The [Spotify URL][2] for the object.
     - value: An external, public URL to the object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#external-url-object
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: String]?
    
    /// Information about the followers of the playlist.
    ///
    /// Only available for the full playlist object.
    public let followers: Followers?
    
    /**
     A link to the Spotify web API endpoint providing
     full details of the playlist.
     
     Use `getHref(_:responseType:)` to retrieve the results.
     */
    public let href: String
    
    /// The [Spotify ID] for the playlist.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /// The URI for the playlist.
    public let uri: String
    
    /**
     Images for the playlist.
     
     The array may be empty or contain up to three images.
     The images are returned by size in descending order.
     See [Working with Playlists][1].
     
     The dimensions of the images may be `nil`, especially if
     uploaded by the user.
     
     - Warning: The urls of these images, if returned,
           are temporary and will expire in less than a day.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/
     */
    public let images: [SpotifyImage]
    
}

extension Playlist: Codable {
        
    public enum CodingKeys: String, CodingKey {
        case name
        case items = "tracks"
        case owner
        case isPublic = "public"
        case collaborative
        case description
        case snapshotId = "snapshot_id"
        case externalURLs = "external_urls"
        case followers
        case href
        case id
        case uri
        case images
    }
    
    
}
