import Foundation

/// A Spotify playlist.
public struct Playlist<Items: Codable & Hashable>: SpotifyURIConvertible, Hashable {
    
    /// The name of the playlist.
    public let name: String
    
    /// The items in this ``Playlist``. Consult the documentation for the
    /// specific endpoint that this playlist was retrieved from for more
    /// information.
    public let items: Items
    
    /// The user who owns the playlist.
    public let owner: SpotifyUser?
    
    /**
     The playlist’s public/private status.
     
     If `true` the playlist is public; if `false`, the playlist is private. If
     `nil`, the playlist status is not relevant.
     
     For more about public/private status, see [Working with Playlists][1].
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#public-private-and-collaborative-status
     */
    public let isPublic: Bool?
    
    /// `true` if the owner allows others to modify the playlist; else, `false`
    ///
    /// Will always be `false` if retrieved from the search endpoint.
    public let isCollaborative: Bool
    
    /// The playlist description. Only returned for modified, verified
    /// playlists, else `nil`.
    public let description: String?
    
    /**
     The version identifier for the current playlist.

     Every time the playlist changes, a new [snapshot id][1] is generated. You
     can use this value to efficiently determine whether a playlist has changed
     since the last time you retrieved it.
     
     Can be supplied in other requests to target a specific playlist version:
     see [Remove Tracks from a Playlist][2].
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     [2]: https://developer.spotify.com/documentation/web-api/reference/#/operations/remove-tracks-playlist
     */
    public let snapshotId: String
    
    /**
     Known external urls for this playlist.
     
     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
           for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: URL]?
    
    /// Information about the followers of the playlist.
    ///
    /// Only available for the full playlist object.
    public let followers: Followers?
    
    /**
     A link to the Spotify web API endpoint providing full details of the
     playlist.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)`` to retrieve the results.
     */
    public let href: URL
    
    /// The [Spotify ID][1] for the playlist.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /// The [URI][1] for the playlist.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String
    
    /**
     The Images for the playlist.
     
     The array may be empty or contain up to three images. The images are
     returned by size in descending order. See [Working with Playlists][1].
     
     The dimensions of the images may be `nil`, especially if uploaded by the
     user.
     
     - Warning: The urls of these images, if returned, are temporary and will
           expire in less than a day. Use ``SpotifyAPI/playlistImage(_:)`` to
           retrieve the image for a playlist.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/
     */
    public let images: [SpotifyImage]
    
    /// The object type. Always ``IDCategory/playlist``.
    public let type: IDCategory

    /**
     Creates a Spotify playlist.
     
     - Parameters:
       - name: The name of the playlist.
       - items: The items in the playlist.
       - owner: The user who owns the playlist.
       - isPublic: The playlist’s public/private status. If `true` the playlist
             is public; if `false`, the playlist is private. If `nil`, the
             playlist status is not relevant. For more about public/private
             status, see [Working with Playlists][1].
       - collaborative: `true` if context is not search (you retrieved this
             playlist using the search endpoint) and the owner allows other
             users to modify the playlist. Else, `false`.
       - description: The playlist description. Only returned for modified,
             verified playlists; else `nil`.
       - snapshotId: The version identifier for the current playlist. Every time
             the playlist changes, a new [snapshot id][2] is generated. You can
             use this value to efficiently determine whether a playlist has
             changed since the last time you retrieved it. Can be supplied in
             other requests to target a specific playlist version: see [Remove
             Tracks from a Playlist][3].
       - externalURLs: Known external urls for this artist.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][4] for the object.
             - value: An external, public URL to the object.
       - followers: Information about the followers of the playlist.
       - href: A link to the Spotify web API endpoint providing full details of
             the playlist.
       - id: The [Spotify ID][4] for the playlist.
       - uri: The [URI][4] for the playlist.
       - images: The Images for the playlist.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#public-private-and-collaborative-status
     [2]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     [3]: https://developer.spotify.com/documentation/web-api/reference/#/operations/remove-tracks-playlist
     [4]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public init(
        name: String,
        items: Items,
        owner: SpotifyUser? = nil,
        isPublic: Bool? = nil,
        isCollaborative: Bool,
        description: String? = nil,
        snapshotId: String,
        externalURLs: [String: URL]? = nil,
        followers: Followers? = nil,
        href: URL,
        id: String,
        uri: String,
        images: [SpotifyImage]
    ) {
        self.name = name
        self.items = items
        self.owner = owner
        self.isPublic = isPublic
        self.isCollaborative = isCollaborative
        self.description = description
        self.snapshotId = snapshotId
        self.externalURLs = externalURLs
        self.followers = followers
        self.href = href
        self.id = id
        self.uri = uri
        self.images = images
        self.type = .playlist
    }
    
}

extension Playlist: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case items = "tracks"
        case owner
        case isPublic = "public"
        case isCollaborative = "collaborative"
        case description
        case snapshotId = "snapshot_id"
        case externalURLs = "external_urls"
        case followers
        case href
        case id
        case uri
        case images
        case type
    }
    
    
}
