import Foundation

/**
 A container that holds ``URIWithPositions`` and, optionally, the snapshot
 id of the playlist that the items associated with the URIs (usually
 tracks/episodes) are contained in.

 Used in the body of
 ``SpotifyAPI/removeSpecificOccurrencesFromPlaylist(_:of:)``.

 This is used for removing specific occurrences of items from a playlist. The
 positions of the URIs are necessary in case the playlist has duplicate items.

 Compare with ``URIsContainer``.
 
 Read more about [snapshot Ids][1]. Read more at the [Spotify web API
 reference][2].
 
 [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
 [2]: https://developer.spotify.com/documentation/web-api/reference/#/operations/remove-tracks-playlist
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
     
     See also:
     
     * ``init(snapshotId:urisWithSinglePosition:)``
     * ``chunked(urisWithSinglePosition:)``
     
     - Parameters:
       - snapshotId: The [snapshot id][1] of a playlist. If `nil`, the most
             recent version of the playlist is targeted. This is an identifier
             for the current version of the playlist. Every time the playlist
             changes, a new snapshot id is generated. You can use this value to
             efficiently determine whether a playlist has changed since the last
             time you retrieved it.
       - urisWithPositions: A collection of URIs along with their positions in
             a playlist. The
             ``SpotifyAPI/removeSpecificOccurrencesFromPlaylist(_:of:)``
              endpoint accepts a maximum of 100 items.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    public init(
        snapshotId: String? = nil,
        urisWithPositions: [URIWithPositions]
    ) {
        self.snapshotId = snapshotId
        self.urisWithPositions = urisWithPositions
    }

    private enum CodingKeys: String, CodingKey {
        case snapshotId = "snapshot_id"
        case urisWithPositions = "tracks"
    }
}

public extension URIsWithPositionsContainer {

    /**
     Creates a container that holds an array of URIs and their positions in a
     playlist.

     See also:
     
     * ``init(snapshotId:urisWithPositions:)``
     * ``chunked(urisWithSinglePosition:)``
     
     - Parameters:
       - snapshotId: The [snapshot id][1] of a playlist. If `nil`, the most
             recent version of the playlist is targeted. This is an identifier
             for the current version of the playlist. Every time the playlist
             changes, a new snapshot id is generated. You can use this value to
             efficiently determine whether a playlist has changed since the last
             time you retrieved it.
       - urisWithSinglePosition: An array of tuples, each of which contain a URI
             and a *single* position in a playlist. Unlike
             ``init(snapshotId:urisWithPositions:)``, `urisWithSinglePosition`
             is expected to contain duplicate URIs, but each with a different
             position.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    init(
        snapshotId: String? = nil,
        urisWithSinglePosition: [(uri: SpotifyURIConvertible, position: Int)]
    ) {
        
        let dictionary: [String: [Int]] = urisWithSinglePosition.reduce(
            into: [:]
        ) { dictionary, nextItem in
            dictionary[nextItem.uri.uri, default: []].append(nextItem.position)
        }
        
        let urisWithPositions = dictionary.map { item in
            URIWithPositions(uri: item.key, positions: item.value)
        }
        
        self.init(
            snapshotId: snapshotId,
            urisWithPositions: urisWithPositions
        )
        
    }
    
    /**
     Creates an array of `Self`, each element of which can be used in a request
     to ``SpotifyAPI/removeSpecificOccurrencesFromPlaylist(_:of:)``.
     
     ``SpotifyAPI/removeSpecificOccurrencesFromPlaylist(_:of:)`` accepts a
     maximum of 100 unique items. Use this method when you need to remove more
     than 100 unique items from a playlist by making a separate request for each
     element.
     
     - Parameter urisWithSinglePosition: An array of tuples, each of which
           contain a URI and a *single* position in a playlist. Unlike
           ``init(snapshotId:urisWithPositions:)``, `urisWithSinglePosition`
           is expected to contain duplicate URIs, but each with a different
           position.
     */
    static func chunked(
        urisWithSinglePosition: [(uri: SpotifyURIConvertible, position: Int)]
    ) -> [Self] {
     
        if urisWithSinglePosition.isEmpty { return [] }
        
        let sortedURIs = urisWithSinglePosition.sorted { lhs, rhs in
            lhs.position > rhs.position
        }

        var uniqueURIs: Set<String> = []
        var chunks: [[(uri: SpotifyURIConvertible, position: Int)]] = [[]]
        var currentChunkIndex = 0
        
        for item in sortedURIs {
            if uniqueURIs.count >= 100 {
                // print(
                //     """
                //     chunk index: \(currentChunkIndex); \
                //     count: \(chunks[currentChunkIndex].count)
                //     """
                // )
                uniqueURIs = []
                chunks.append([])
                currentChunkIndex += 1
                // print("\(currentTime()) chunk index: \(currentChunkIndex)")
            }
            chunks[currentChunkIndex].append(item)
            uniqueURIs.insert(item.uri.uri)
            
        }
        // print(
        //     """
        //     chunk index: \(currentChunkIndex); \
        //     count: \(chunks[currentChunkIndex].count)
        //     """
        // )
        
        let containers = chunks.map { chunk in
            Self(urisWithSinglePosition: chunk)
        }
        
        // print("\(currentTime()) created \(containers.count) chunks")
        
        return containers
        
    }
    
}

// func currentTime() -> String {
//     let formatter = DateFormatter()
//     formatter.dateFormat = "h:m:ss.SS"
//
//     return formatter.string(from: Date())
// }
