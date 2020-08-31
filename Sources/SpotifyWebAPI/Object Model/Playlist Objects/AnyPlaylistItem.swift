/**
 Either a track or an episode. Used for endpoints
 that return track and/or episode objects.
 
 This is usually, but not always, returned in the context of
 a playlist.
 
 - Warning: This struct is limited to the properties
       common to both tracks and episodes. Compare with
       `Track` and `Episode`.
 
 Use the `type` property to check whether the item is
 a track or an episode.
 */
public struct AnyPlaylistItem: Hashable {
    
    /// The name of the playlist item
    public let name: String
    
    /// The [Spotify URI][1] for the item.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String?
    
    /// The [Spotify ID] for the item.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String?
    
    /// The length of the item in milliseconds.
    public let durationMS: Int
    
    /// Whether or not the item has explicit content.
    /// `false` if unknown.
    public let isExplicit: Bool
    
    /// Part of the response when [Track Relinking][1] is applied.
    /// Else, `nil`. If `true`, the item is playable in the given market.
    /// Otherwise, `false`.
    ///
    /// [1]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
    public let isPlayable: Bool?
    
    /**
     A link to the Spotify web API endpoint
     providing the full version of the item.
     
     Use `getHref(_:responseType:)` to retrieve the full results.
     */
    public let href: String
    
    /**
     Known [external urls][1] for this item.

     - key: The type of the URL, for example:
           "spotify" - The [Spotify URL][2] for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#external-url-object
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: String]?
 
    /// The object type. Either `track` or `episode`.
    public let type: IDCategory
    
}

extension AnyPlaylistItem: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case name
        case uri
        case id
        case durationMS = "duration_ms"
        case isExplicit = "explicit"
        case isPlayable = "is_playable"
        case href
        case externalURLs = "external_urls"
        case type

    }
    
}
