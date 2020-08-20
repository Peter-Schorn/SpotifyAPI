import Foundation


/**
 A Spotify URI and its positions in a collection.
 
 For example, this may represent all of the positions
 in a playlist of a specific track. The positions of the uris
 are necessary in case the collection has duplicate items.
 
 See also `URIWithPositionsContainer`.
 */
public struct URIWithPositions: Codable, Hashable {
    
    public let uri: String
    public let positions: [Int]
    
    /**
     A URI along with its positions in a collection.
    
     For example, this may represent all of the positions
     in a playlist of a specific track. The positions of the uris
     are necessary in case the collection has duplicate items.
     
     - Parameters:
       - uri: A Spotify URI.
       - positions: The positions of the item associated with the uri
             in a collection (usually a playlist).
     */
    public init(uri: SpotifyURIConvertible, positions: [Int]) {
        self.uri = uri.uri
        self.positions = positions
    }
    
}

/**
 A container that holds `URIWithPositions` and, optionally,
 the snapshot id of the playlist that the items associated with the uris
 (usually tracks/episodes) are contained in.
 
 This is used for removing specific occurences of items from a playlist.
 The positions of the uris are necessary in case the playlist has duplicate
 items.
 */
public struct URIWithPositionsContainer: Codable, Hashable {
    
    public let snapshotId: String?
    public let uriWithPositions: [URIWithPositions]
    
    public init(snapshotId: String?, uriWithPositions: [URIWithPositions]) {
        self.snapshotId = snapshotId
        self.uriWithPositions = uriWithPositions
    }
    
    public init(
        snapshotId: String?,
        uriWithPositions: (uri: SpotifyURIConvertible, positions: [Int])...
    ) {
        self.snapshotId = snapshotId
        self.uriWithPositions = uriWithPositions.map { item in
            URIWithPositions(uri: item.uri.uri, positions: item.positions)
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case snapshotId = "snapshot_id"
        case uriWithPositions = "tracks"
    }
}
