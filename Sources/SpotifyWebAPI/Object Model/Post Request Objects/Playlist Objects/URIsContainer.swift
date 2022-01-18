import Foundation


/**
 Contains an array of URIs and, optionally, the snapshot id of a playlist.
 Used in the body of
 ``SpotifyAPI/removeAllOccurrencesFromPlaylist(_:of:snapshotId:)``.

 Compare with ``URIsWithPositionsContainer``.

 Read more about [snapshot Ids][1]. Read more at the [Spotify web API
 reference][2].
 
 [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
 [2]: https://developer.spotify.com/documentation/web-api/reference/#/operations/remove-tracks-playlist
 */
public struct URIsContainer {
    
    /// The [snapshot id][1] of the playlist to target.
    ///
    /// [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
    public var snapshotId: String?
    
    /// An array of track/episode URIs in a playlist.
    public var items: [SpotifyURIConvertible]
    
    /**
     Creates a container that holds an array of URIs and, optionally, the
     snapshot id of a playlist that they are contained in.
    
     - Parameters:
       - items: An array of track/episode URIs.
             The
             ``SpotifyAPI/removeAllOccurrencesFromPlaylist(_:of:snapshotId:)``
             endpoint accepts a maximum of 100 items.
       - snapshotId: The [snapshot id][1] of a playlist. If `nil`, the most
             recent version of the playlist is targeted. This is an identifier
             for the current version of the playlist. Every time the playlist
             changes, a new snapshot id is generated. You can use this value to
             efficiently determine whether a playlist has changed since the last
             time you retrieved it.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    public init(
        _ items: [SpotifyURIConvertible],
        snapshotId: String? = nil
    ) {
        self.items = items
        self.snapshotId = snapshotId
    }
    
}

extension URIsContainer: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.snapshotId = try container.decodeIfPresent(
            String.self, forKey: .snapshotId
        )

        let urisDictionaries = try container.decode(
            [[String: String]].self, forKey: .items
        )
        
        self.items = urisDictionaries.compactMap { dict in
            dict["uri"]
        }

    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.snapshotId, forKey: .snapshotId)
        
        let urisDictionaries = self.items.map { uri in
            ["uri": uri.uri]
        }
        
        try container.encode(urisDictionaries, forKey: .items)
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case snapshotId = "snapshot_id"
        case items = "tracks"
    }

}

extension URIsContainer: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(snapshotId)
        hasher.combine(items.map(\.uri))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.snapshotId == rhs.snapshotId &&
                lhs.items.lazy.map(\.uri) == rhs.items.lazy.map(\.uri)
    }

}
