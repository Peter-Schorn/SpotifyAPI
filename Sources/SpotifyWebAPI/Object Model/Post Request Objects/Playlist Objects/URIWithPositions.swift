import Foundation

/**
 A Spotify URI and its positions in a collection (usually a playlist). Used in
 the body of ``SpotifyAPI/removeSpecificOccurrencesFromPlaylist(_:of:)``.
 
 For example, this may represent all of the positions in a playlist of a
 specific track. The positions of the URI is necessary in case the collection
 has duplicate items.
 
 See also ``URIsWithPositionsContainer``.
 */
public struct URIWithPositions {
    
    /// The URI for the Spotify content.
    public var uri: SpotifyURIConvertible
    
    /**
     The zero-indexed positions of the item corresponding to ``uri`` in a
     collection (usually a playlist).

     For example, if the track/episode corresponding to ``uri`` appears in the
     first and third position of a playlist, then ``positions`` would be `[0,
     2]`.
     */
    public var positions: [Int]
    
    /**
     A URI along with its positions in a collection.
    
     For example, this may represent all of the positions in a playlist of a
     specific track. The positions of the URIs are necessary in case the
     collection has duplicate items.
     
     - Parameters:
       - uri: A Spotify URI.
       - positions: The zero-indexed positions of the item associated with the
             uri in a collection (usually a playlist).
     */
    public init(uri: SpotifyURIConvertible, positions: [Int]) {
        self.uri = uri.uri
        self.positions = positions
    }
    
}

extension URIWithPositions: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uri = try container.decode(
            String.self, forKey: .uri
        )
        self.positions = try container.decode(
            [Int].self, forKey: .positions
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(
            self.uri.uri, forKey: .uri
        )
        try container.encode(
            self.positions, forKey: .positions
        )
    }
    
    private enum CodingKeys: String, CodingKey {
        case uri, positions
    }
    
}

extension URIWithPositions: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.uri.uri)
        hasher.combine(self.positions)
    }
        
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uri.uri == rhs.uri.uri &&
                lhs.positions == rhs.positions
    }

}
