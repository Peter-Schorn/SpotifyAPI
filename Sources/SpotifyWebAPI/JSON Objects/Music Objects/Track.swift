import Foundation

/// A [Spotify track][1].
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#track-object-full
public struct Track: Hashable {

    /// The name of the track.
    public let name: String
    
    /**
     The album on which the track appears.
     
     The simplified version will be returned.
     The album object includes a link in href
     to full information about the album.
     
     Only available for the full track object.
     */
    public let album: Album?

    /// The artists who performed the track.
    /// The simplified versions will be returned.
    ///
    /// Each artist object includes a link in href
    /// to more detailed information about the artist.
    public let artists: [Artist]?
    
    /// The [Spotify URI][1] for the track.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String?
    
    /// The [Spotify ID] for the track.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String?
    
    /// Whether or not the track is from a [local file][1].
    ///
    /// When this is `true`, expect many of the other properties
    /// to be `nil`.
    ///
    /// [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#local-files
    public let isLocal: Bool
    
    /**
     The popularity of the track.
     
     The value will be between 0 and 100, with 100 being the most popular.
     The popularity of a track is a value between 0 and 100,
     with 100 being the most popular.
     The popularity is calculated by algorithm and is based,
     in the most part, on the total number of plays the track
     has had and how recent those plays are.
     Generally speaking, songs that are being played a lot
     now will have a higher popularity than songs that were played
     a lot in the past. Duplicate tracks (e.g. the same track from
     a single and an album) are rated independently.
     Artist and album popularity is derived mathematically
     from track popularity. Note that the popularity value
     may lag actual popularity by a few days:
     the value is not updated in real time.
     
     Only available for the full track object.
     */
    public let popularity: Int?
    
    /// The track length in milliseconds
    public let durationMS: Int?

    /// The number of the track.
    ///
    /// If an album has several discs,
    /// the track number is the number on the specified disc.
    public let trackNumber: Int?
    
    /// Whether or not the track has explicit lyrics.
    /// `false` if unknown.
    public let explicit: Bool
    
    /// Part of the response when [Track Relinking][1] is applied.
    /// Else, `nil`. If `true`, the track is playable in the given market.
    /// Otherwise, `false`.
    ///
    /// [1]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
    public let isPlayable: Bool?

    /// A link to the Spotify web API endpoint
    /// providing the full track object.
    public let href: String?

    /// A link to a 30 second preview (MP3 format) of the track.
    /// May be `nil`.
    public let previewURL: String?
    
    /**
     Known [external urls][1] for this track.

     - key: The type of the URL, for example:
           "spotify" - The [Spotify url][2] for the object.
     - value: An external, public url to the object.

     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#external-url-object
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: String]?
    
    /// Known external IDs for the track.
    ///
    /// Only available for the full track object.
    public let externalIds: [String: String]?
    
    /// A list of the countries in which the track can be played,
    /// identified by their ISO 3166-1 alpha-2 code.
    public let availableMarkets: [String]?

    /**
     Part of the response when [Track Relinking][1] is applied,
     and the requested track has been replaced with different track.
     The track link contains
     information about the originally requested track.
    
     [1]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    public let linkedFrom: TrackLink?
    
    /**
     Part of the response when [Track Relinking][1] is applied,
     the original track is not available in the given market,
     and Spotify did not have any tracks to relink it with.
     
     The track response will still contain metadata for
     the original track, and a restrictions object
     containing the reason why the track is not available:
     `{"reason" : "market"}`.
     
     [1]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    public let restrictions: [String: String]?
    
    /// The disc number
    /// (usually 1 unless the album consists of more than one disc).
    public let discNumber: Int?

    /// The object type. Always `track`.
    public let type: IDCategory
    
}

extension Track: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case name
        case album
        case artists
        case uri
        case id
        case isLocal = "is_local"
        case popularity
        case durationMS = "duration_ms"
        case trackNumber
        case explicit
        case isPlayable = "is_playable"
        case href
        case previewURL
        case externalURLs = "external_urls"
        case externalIds = "external_ids"
        case availableMarkets = "available_markets"
        case linkedFrom = "linked_from"
        case restrictions
        case discNumber = "disc_number"
        case type

    }
    
}
