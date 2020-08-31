import Foundation

/**
 The context that a track/episode is being played in.
 
 For example, if a track is being played, then the context
 may be an album, an artist, or a playlist.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#context-object
 */
public struct SpotifyContext: Codable, Hashable {
    
    /// The URI of the context
    public let uri: String
    
    /**
     A link to an endpoint providing further
     details about the context.
     
     Use `getHref(_:responseType:)` to retrieve the results.
     */
    public let href: String?
    
    /**
     Known [external urls][1] for the context.

     - key: The type of the URL, for example:
           "spotify" - The [Spotify URL][2] for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#external-url-object
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: String]?
    
    /// The object type of the item's context:
    /// Valid values are `album`, `artist`, and `playlist`.
    public let type: IDCategory
    
}
