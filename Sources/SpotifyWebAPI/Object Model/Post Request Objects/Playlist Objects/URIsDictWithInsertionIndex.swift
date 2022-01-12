import Foundation

/**
 Contains an array of URIs and (optionally) the position to insert them
 in a playlist. Used in the body of
 ``SpotifyAPI/addToPlaylist(_:uris:position:)``.
 
 For example:
 ```
 {
    "uris": [
        "spotify:track:4iV5W9uYEdYUVa79Axb7Rh",
        "spotify:track:1301WleyT98MSxVHPZCA6M",
        "spotify:episode:512ojhOuo1ktJprKbVcKyQ"
    ],
    "position": 10
 }
 ```

 [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/add-tracks-to-playlist
 */
public struct URIsDictWithInsertionIndex {
    
    /// An array of track/episode URIs that will be added to a playlist.
    public var uris: [SpotifyURIConvertible]
    
    /// The zero-indexed position at which to insert ``uris`` in a playlist. If
    /// `nil`, then the ``uris`` will be appended to the playlist.
    public var position: Int?
    
    /**
     Creates an array of URIs and the position to insert them in a playlist.
     
     - Parameters:
       - uris: An array of URIs.
       - position: The position to insert the URIs in a playlist. If `nil`
             (default), then they will be appended to the playlist.
     */
    public init(
        uris: [SpotifyURIConvertible], position: Int? = nil
    ) {
        self.uris = uris
        self.position = position
    }
    
}

extension URIsDictWithInsertionIndex: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uris = try container.decode(
            [String].self, forKey: .uris
        )
        
        self.position = try container.decodeIfPresent(
            Int.self, forKey: .position
        )
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(
            self.uris.map(\.uri), forKey: .uris
        )
        try container.encodeIfPresent(
            self.position, forKey: .position
        )
    }

    private enum CodingKeys: String, CodingKey {
        case uris
        case position
    }

}

extension URIsDictWithInsertionIndex: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(uris.map(\.uri))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.position == rhs.position &&
                lhs.uris.map(\.uri) == rhs.uris.map(\.uri)
    }

}
