import Foundation

/**
 Contains details about a playlist. Used in the body of
 ``SpotifyAPI/changePlaylistDetails(_:to:)`` and
 ``SpotifyAPI/createPlaylist(for:_:)``.
 
 If you are changing the details of an existing playlist, then the
 value of each non-`nil` property will be used to update the details
 of the playlist.
 
 Contains the following properties:
 
 * name: The new name for the playlist. Required if you are creating a new
   playlist; optional if you are changing the details of an existing playlist.
 * isPublic: If `true` the playlist will be public; if `false` it will be
   private. Default: `true`.
 * collaborative: If `true`, the playlist will become collaborative and other
   users will be able to modify the playlist in their Spotify client. Default:
   `false`. **Note**: You can only set collaborative to `true` on non-public
   playlists.
 * description: A playlist description as displayed in Spotify Clients and in
   the Web API.
 */
public struct PlaylistDetails: Hashable {
    
    /// The new name for the playlist. Required if you are creating a new
    /// playlist; optional if you are changing the details of an existing
    /// playlist.
    public var name: String?
    
    /// If `true` the playlist will be public; if `false` it will be private.
    /// Default: `true`.
    public var isPublic: Bool?

    /**
     If `true`, the playlist will become collaborative and other users will be
     able to modify the playlist in their Spotify client. Default: `false`.
    
     - Warning: You can only set collaborative to `true` on non-public
           playlists.
     */
    public var isCollaborative: Bool?

    /// A new playlist description as displayed in Spotify Clients and in the
    /// Web API.
    public var description: String?
    
    /**
     Creates an instance that holds details about a playlist.
     
     If you are changing the details of an existing playlist, then the value of
     each non-`nil` property will be used to update the details of the playlist.
     
     - Parameters:
       - name: The new name for the playlist. Required if you are creating a new
             playlist; optional if you are changing the details of an existing
             playlist.
       - isPublic: If `true` the playlist will be public; if `false`, it will be
             private. Default: `true`.
       - isCollaborative: If `true`, the playlist will become collaborative and
             other users will be able to modify the playlist in their Spotify
             client. Default: `false`. **Note**: You can only set collaborative
             to `true` on non-public playlists.
       - description: A playlist description as displayed in Spotify Clients and
             in the Web API.
     */
    public init(
        name: String? = nil,
        isPublic: Bool? = nil,
        isCollaborative: Bool? = nil,
        description: String? = nil
    ) {
        self.name = name
        self.isPublic = isPublic
        self.isCollaborative = isCollaborative
        self.description = description
    }
    
}

extension PlaylistDetails: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case isPublic = "public"
        case isCollaborative = "collaborative"
        case description
    }
    
}
