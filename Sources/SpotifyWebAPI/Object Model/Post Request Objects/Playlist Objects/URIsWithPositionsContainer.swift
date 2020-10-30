import Foundation

/**
 A container that holds `URIWithPositions` and, optionally,
 the [snapshot id][1] of the playlist that the items associated with the URIs
 (usually tracks/episodes) are contained in.
 
 Used in the body of `SpotifyAPI.removeSpecificOccurencesFromPlaylist(_:of:)`.
 
 This is used for removing specific occurences of items from a playlist.
 The positions of the URIs are necessary in case the playlist has duplicate
 items.
 
 Compare with `URIsContainer`.
 
 Read more at the [Spotify web API reference][2].
 
 [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
 [2]: https://developer.spotify.com/documentation/web-api/reference/playlists/remove-tracks-playlist/

 */
public struct URIsWithPositionsContainer: Codable, Hashable {
    
    /// The [snapshot id][1] of the playlist to target.
    ///
    /// [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
    public var snapshotId: String?
    
    /// An array of URIs, along with their positions in a playlist.
    public var urisWithPositions: [URIWithPositions]
    
    /**
     Creates a container that holds an array of URIs and their positions in a
     playlist.
     
     Consider using the convienence initializer
     `init(snapshotId:urisWithPositions:)`, which accepts an array of tuples.
    
     - Parameters:
       - snapshotId: The [snapshot id][1] of a playlist. If `nil`,
             the most recent version of the playist is targeted.
             This is an identifer for the current version of the playlist.
             Every time the playlist changes, a new snapshot id is generated.
             You can use this value to efficiently determine whether a playlist
             has changed since the last time you retrieved it.
       - urisWithPositions: A collection of URIs along with their positions
             in a playlist. The
             `SpotifyAPI.removeSpecificOccurencesFromPlaylist(_:of:)`
             endpoint accepts a maximum of 100 items.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    public init(
        snapshotId: String?,
        urisWithPositions: [URIWithPositions]
    ) {
        self.snapshotId = snapshotId
        self.urisWithPositions = urisWithPositions
    }
    
    /**
     Creates a container that holds an array of URIs and their positions in a
     playlist.
    
     - Parameters:
       - snapshotId: The [snapshot id][1] of a playlist. If `nil`,
             the most recent version of the playist is targeted.
             This is an identifer for the current version of the playlist.
             Every time the playlist changes, a new snapshot id is generated.
             You can use this value to efficiently determine whether a playlist
             has changed since the last time you retrieved it.
       - urisWithPositions: An collection of URIs along with their positions
             in a playlist. The
             `SpotifyAPI.removeAllOccurencesFromPlaylist(_:of:snapshotId:)`
             endpoint accepts a maximum of 100 items.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    public init(
        snapshotId: String?,
        urisWithPositions: [(uri: SpotifyURIConvertible, positions: [Int])]
    ) {
        self.snapshotId = snapshotId
        self.urisWithPositions = urisWithPositions.map { item in
            URIWithPositions(uri: item.uri, positions: item.positions)
        }
    }
    
    /// :nodoc:
    public enum CodingKeys: String, CodingKey {
        case snapshotId = "snapshot_id"
        case urisWithPositions = "tracks"
    }
}
