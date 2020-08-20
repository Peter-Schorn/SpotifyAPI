import Foundation

/**
 Used in the body of [add tracks to playlist][1].

 Contains an array of uris and (optionally) the position
 to insert them in the playlist.
 
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

 [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/add-tracks-to-playlist/
 */
struct URIsDictWithInsertionIndex: Codable, Hashable {
    
    let uris: [String]
    let position: Int?
    
    init(
        uris: [SpotifyURIConvertible], postion: Int?
    ) {
        self.uris = uris.map(\.uri)
        self.position = postion
    }
}
