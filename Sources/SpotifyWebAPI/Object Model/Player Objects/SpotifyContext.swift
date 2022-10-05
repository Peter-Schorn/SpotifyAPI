import Foundation

/**
 The context that a track/episode is being played in.
 
 For example, if a track is being played, then the context may be an album, an
 artist, or a playlist.
 */
public struct SpotifyContext: Hashable {
    
    /// The URI of the context.
    public let uri: String
    
    /**
     A link to an endpoint providing further details about the context.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)`` to retrieve the results.
     */
    public let href: URL?
    
    /**
     Known external urls for the context.

     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
           for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: URL]?
    
    /**
     The object type of the item's context. Valid values are
     ``IDCategory/album``, ``IDCategory/artist``, ``IDCategory/playlist``,
     ``IDCategory/show``, ``IDCategory/ad``, and ``IDCategory/collection``.
    
     For example, if ``type`` is ``IDCategory/playlist``, then the current
     track/episode is playing in the context of a playlist.
     
     If ``type`` is ``IDCategory/collection``, then the user is playing their
     saved tracks (labeled as "Liked Songs" in the native Spotify clients).
     */
    public let type: IDCategory
    
    /**
     The context that a track/episode is being played in.
     
     - Parameters:
       - uri: The URI of the context.
       - href: A link to an endpoint providing further details about the
             context.
       - externalURLs: Known [external urls][1] for the context.
       - type: The object type of the item's context. Valid values are
             ``IDCategory/album``, ``IDCategory/artist``, and
             ``IDCategory/playlist``.
     */
    public init(
        uri: String,
        href: URL?,
        externalURLs: [String: URL]?,
        type: IDCategory
    ) {
        self.uri = uri
        self.href = href
        self.externalURLs = externalURLs
        self.type = type
    }
    
}

extension SpotifyContext: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case uri
        case href
        case externalURLs = "external_urls"
        case type
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uri = try container.decode(String.self, forKey: .uri)
        self.href = try container.decodeIfPresent(URL.self, forKey: .href)
        self.externalURLs = try container.decodeIfPresent(
            [String: URL].self, forKey: .externalURLs
        )
        
        let typeString = try container.decode(String.self, forKey: .type)
        self.type = IDCategory(rawValue: typeString) ?? .unknown

    }

}
