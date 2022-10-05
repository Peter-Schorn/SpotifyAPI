import Foundation


/// A Spotify track link object.
///
/// See the [Track relinking Guide][2].
/// [2]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
public struct TrackLink: SpotifyURIConvertible, Hashable {
    
    /**
     Known external urls for this track.

     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
           for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: URL]?
    
    /**
     A link to the Spotify web API endpoint providing the full track object.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)`` to retrieve the results.
     */
    public let href: URL
    
    /// The [Spotify URI][1] for the track.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String
    
    /// The [Spotify ID][1] for the track.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /// The object type. Always ``IDCategory/track``.
    public let type: IDCategory
    
    /**
     Creates a Spotify track link object.
     
     See the [Track relinking Guide][1].
     
     - Parameters:
       - externalURLs: Known external urls for this artist.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][2] for the object.
             - value: An external, public URL to the object.
       - href: A link to the Spotify web API endpoint providing the full track
             object.
       - uri: The [Spotify URI][2] for the track.
       - id: The [Spotify ID][2] for the track.
     
     [1]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public init(
        externalURLs: [String: URL]? = nil,
        href: URL,
        uri: String,
        id: String
    ) {
        self.externalURLs = externalURLs
        self.href = href
        self.uri = uri
        self.id = id
        self.type = .track
    }

}

extension TrackLink: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case externalURLs = "external_urls"
        case href
        case uri
        case id
        case type
    }
    
}
