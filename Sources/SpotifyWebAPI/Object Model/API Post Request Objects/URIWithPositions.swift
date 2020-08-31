import Foundation

/**
 A Spotify URI and its positions in a collection.
 Used in the body of `removeSpecificOccurencesFromPlaylist`.
 
 For example, this may represent all of the positions
 in a playlist of a specific track. The positions of the URIs
 are necessary in case the collection has duplicate items.
 
 See also `URIWithPositionsContainer`.
 */
public struct URIWithPositions: Codable, Hashable {
    
    /// The URI for the Spotify content
    public let uri: String
    
    /// The positions of the item associated with the URI in
    /// a collection (usually a playlist).
    public let positions: [Int]
    
    /**
     A URI along with its positions in a collection.
    
     For example, this may represent all of the positions
     in a playlist of a specific track. The positions of the URIs
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
