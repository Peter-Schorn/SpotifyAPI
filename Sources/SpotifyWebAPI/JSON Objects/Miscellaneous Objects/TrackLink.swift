import Foundation


/// A Spotify [track link][1] object.
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#track-link
public struct TrackLink: CustomCodable, Hashable {
    
    /**
     Known [external urls][1] for this track.

     - key: The type of the URL, for example:
           "spotify" - The [Spotify url][2] for the object.
     - value: An external, public url to the object.

     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#external-url-object
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: String]?
    
    /// A link to the Web API endpoint
    /// providing the full track object.
    public let href: String
    
    /// The [Spotify URI][1] for the track.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String
    
    /// The [Spotify ID] for the track.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /// The object type. Always "track".
    public let type: String
    
}
