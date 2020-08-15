import Foundation

/// A Spotify [album][1].
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#album-object-full
public struct Album: SpotifyURIConvertible, Hashable {

    /// The name of the album.
    ///
    /// In case of an album takedown,
    /// the value may be an empty string.
    public let name: String
    
    /**
     The tracks of the album.
     
     The simplified versions will be returned
     inside of a paging object.
     */
    public let tracks: PagingObject<Track>
    
    /// The artists of the album. The simplified versions will be returned.
    ///
    /// Each artist object includes a link in href
    /// to more detailed information about the artist.
    public let artists: [Artist]
    
    /// The date the album was first released, for example 1981.
    ///
    /// Depending on the precision,
    /// it might be shown as 1981-12 or 1981-12-15.
    public let releaseDate: Date
    
    /// The [Spotify URI][1] for the album.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String
    
    /// The [Spotify ID] for the album.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /// The cover art for the album in various sizes, widest first.
    public let images: [SpotifyImage]
    
    /**
     The popularity of the album.

     The value will be between 0 and 100,
     with 100 being the most popular.
     The popularity is calculated
     from the popularity of the album’s individual tracks.
     
     Only available for the full album object.
     */
    public let popularity: Int?
    
    /// The label for the album.
    ///
    /// Do not confuse this with the name of the album.
    public let label: String?
    
    /// A list of the genres the artist is associated with.
    ///
    /// For example: "Prog Rock" , "Post-Grunge".
    /// (If not yet classified, the array is empty.)
    ///
    /// Only available for the full album object.
    public let genres: [String]?
    
    /// A link to the Web API endpoint
    /// providing the full album object.
    public let href: String

    /**
     Known [external urls][1] for this artist.

     - key: The type of the URL, for example:
           "spotify" - The [Spotify url][2] for the object.
     - value: An external, public url to the object.

     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#external-url-object
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: String]?
    
    /**
     Known external IDs for the album.

     - key: The identifier type, for example:
       - "isrc": [International Standard Recording Code][1]
       - "ean": [International Article Number][2]
       - "upc": [Universal Product Code][3]
     - value: An external identifier for the object.
     
     Only available for the full album object.
     
     [1]: http://en.wikipedia.org/wiki/International_Standard_Recording_Code
     [2]: http://en.wikipedia.org/wiki/International_Article_Number_%28EAN%29
     [3]: http://en.wikipedia.org/wiki/Universal_Product_Code
     */
    public let externalIds: [String: String]?
    
    /// The type of the album: one of "album" , "single" , or "compilation".
    public let albumType: String?

    /**
     This field is present when getting an artist’s albums.
     
     Possible values are "album", "single", "compilation", and "appears_on".
     Compare to album_type this field represents
     the relationship between the artist and the album.
     */
    public let albumGroup: String?
    
    /// The markets in which the album is available:
    /// ISO 3166-1 alpha-2 country codes.
    ///
    /// Note that an album is considered available in a market
    /// when at least 1 of its tracks is available in that market.
    public let availableMarkets: [String]?

    public let copyrights: [SpotifyCopyright]?

    /// The precision with which `releaseDate` value is known:
    /// "year", "month", or "day".
    public let releaseDatePrecision: String?

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
    
    /// The object type. Always "album".
    public let type: String
    
}


extension Album: CustomCodable {
    
    
    public static func decoded(from data: Data) throws -> Self {
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(
            decodeSpotifyAlbumReleaseDate(decoder:)
        )
        return try decoder.decode(Self.self, from: data)
        
    }
    
    public func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            return try encodeSpotifyAlbumReleaseDate(
                date, to: encoder,
                datePrecision: self.releaseDatePrecision
            )
        }
        return try encoder.encode(self)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case name
        case tracks
        case artists
        case releaseDate = "release_date"
        case uri
        case id
        case images
        case popularity
        case label
        case genres
        case href
        case externalURLs = "external_urls"
        case externalIds = "external_ids"
        case albumType = "album_type"
        case albumGroup = "album_group"
        case availableMarkets = "available_markets"
        case copyrights
        case releaseDatePrecision = "release_date_precision"
        case restrictions
        case type
    }
    

}
