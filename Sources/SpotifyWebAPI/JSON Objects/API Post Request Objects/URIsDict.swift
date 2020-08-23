import Foundation


/**
 Contains an array of URIs.
 Used in the body of `removeAllOccurencesFromPlaylist`.

 ```
 {
    "tracks": [
        { "uri": "spotify:track:4iV5W9uYEdYUVa79Axb7Rh" },
        { "uri": "spotify:track:1301WleyT98MSxVHPZCA6M" },
        { "uri": "spotify:episode:512ojhOuo1ktJprKbVcKyQ" }
    ]
 }
 ```
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/remove-tracks-playlist/
 */
struct URIsDict: Codable, Hashable {
    
    let tracks: [[String: String]]
    
    init(_ uris: [SpotifyURIConvertible]) {
        self.tracks = uris.map { uri in
            return ["uri": uri.uri]
        }
        
    }

}
