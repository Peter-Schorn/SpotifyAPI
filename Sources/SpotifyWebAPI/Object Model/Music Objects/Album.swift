import Foundation

/// A Spotify album.
public struct Album: Hashable {
    
    /// The name of the album.
    ///
    /// In case of an album takedown, the value may be an empty string.
    public let name: String
    
    /**
     The tracks of the album.
     
     For certain endpoints, this property may be `nil`, especially if it is
     nested inside a much larger object. For example, it will be `nil` if
     retrieved from the search endpoint or if nested inside a ``Track``. When
     this property is `nil`, use
     ``SpotifyAPI/albumTracks(_:market:limit:offset:)`` instead, passing in the
     URI of this album.
     */
    public let tracks: PagingObject<Track>?
    
    /// The artists of the album. The simplified versions will be returned.
    ///
    /// Each artist object includes a link in href to more detailed information
    /// about the artist.
    public let artists: [Artist]?
    
    /// The date the album was first released. See also
    /// ``releaseDatePrecision``.
    public let releaseDate: Date?
    
    /// The [Spotify URI][1] for the album.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String?
    
    /// The [Spotify ID][1] for the album.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String?
    
    /// The cover art for the album in various sizes, widest first.
    public let images: [SpotifyImage]?
    
    /**
     The popularity of the album.

     The value will be between 0 and 100, with 100 being the most popular. The
     popularity is calculated from the popularity of the album’s individual
     tracks.

     Only available for the full album object.
     */
    public let popularity: Int?
    
    /// The label for the album.
    ///
    /// Do not confuse this with the ``name`` of the album.
    public let label: String?
    
    /**
     A list of the genres the artist is associated with.
    
     For example: "Prog Rock" , "Post-Grunge". (If not yet classified, the array
     is empty.)
    
     Only available for the full album object.
     */
    public let genres: [String]?
    
    /// The total number of tracks in the album.
    public let totalTracks: Int?

    /**
     A link to the Spotify web API endpoint providing the full album object.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``Album`` as
     the response type to retrieve the results.
     */
    public let href: URL?

    /**
     Known external urls for this artist.

     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
           for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: URL]?
    
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
    
    /// The type of the album: one of ``AlbumType/album``, ``AlbumType/single``,
    /// or ``AlbumType/compilation``. See also ``albumGroup``.
    public let albumType: AlbumType?

    /**
     This property is present when getting an artist’s albums.
     
     Possible values are ``AlbumType/album``, ``AlbumType/single``,
     ``AlbumType/compilation``, and ``AlbumType/appearsOn``. Compared to
     ``albumType`` this field represents the relationship between the artist and
     the album.
     
     See also ``albumType``.
     */
    public let albumGroup: AlbumType?
    /**
     A list of the countries in which the album is available, identified by
     their [ISO 3166-1 alpha-2][1] codes.

     Note that an album is considered available in a market when at least 1 of
     its tracks is available in that market.

     [1]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    public let availableMarkets: [String]?

    /// The copyrights for the album.
    public let copyrights: [SpotifyCopyright]?

    /// The precision with which ``releaseDate`` is known: "year", "month", or
    /// "day".
    public let releaseDatePrecision: String?

    /**
     Part of the response when a content restriction, such as Track
     Relinking, is applied. Else, `nil`.
     
     The key will be "reason", and the value will be one of the
     following:
     * "market" - The content item is not available in the given market.
     * "product" - The content item is not available for the user’s subscription
       type.
     * "explicit" - The content item is explicit and the user’s account is set
       to not play explicit content.
     
     Additional reasons and additional keys may be added in the future.
     
     Read about [Track Relinking][1].

     [1]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    public let restrictions: [String: String]?
    
    /// The object type. Always ``IDCategory/album``.
    public let type: IDCategory
    
    /**
     Creates a Spotify album.
     
     - Parameters:
       - name: The name of the album.
       - tracks: The tracks of the album.
       - artists:  The artists of the album.
       - releaseDate: The date the album was first released.
       - uri: The [Spotify URI][1] for the album.
       - id: The [Spotify ID][1] for the album.
       - images: The cover art for the album.
       - popularity: The popularity of the album. Should be between 0 and 100,
             inclusive.
       - label: The label for the album. Do not confuse this with the ``name``
             of the album.
       - genres: A list of the genres the artist is associated with.
       - totalTracks: The total number of tracks in the album.
       - href: A link to the Spotify web API endpoint providing the full album
             object.
       - externalURLs: Known external urls for this artist.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][1] for the object.
             - value: An external, public URL to the object.
       - externalIds: Known external IDs for the album.
             - key: The identifier type, for example:
               - "isrc": [International Standard Recording Code][2]
               - "ean": [International Article Number][3]
               - "upc": [Universal Product Code][4]
             - value: An external identifier for the object.
       - albumType: The type of the album: one of ``AlbumType/album``,
             ``AlbumType/single``, or ``AlbumType/compilation``.
       - albumGroup: This field is present when getting an artist’s albums.
             Possible values are ``AlbumType/album``, ``AlbumType/single``,
             ``AlbumType/compilation``, and ``AlbumType/appearsOn``. Compared to
             ``albumType`` this field represents the relationship between the
             artist and the album.
       - availableMarkets: A list of the countries in which the album is
             available, identified by their [ISO 3166-1 alpha-2][5] codes. Note
             that an album is considered available in a market when at least 1
             of its tracks is available in that market.
       - copyrights: The copyrights for the album.
       - releaseDatePrecision: The precision with which ``releaseDate`` is known:
             "year", "month", or "day".
       - restrictions: Part of the response when a content restriction, such as
             [Track Relinking][6], is applied. Else, `nil`. The key will be
             "reason", and the value will be one of the following:
             * "market" - The content item is not available in the given market.
             * "product" - The content item is not available for the user’s
               subscription type.
             * "explicit" - The content item is explicit and the user’s account
               is set to not play explicit content.
             Additional reasons and additional keys may be added in the future.
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     [2]: http://en.wikipedia.org/wiki/International_Standard_Recording_Code
     [3]: http://en.wikipedia.org/wiki/International_Article_Number_%28EAN%29
     [4]: http://en.wikipedia.org/wiki/Universal_Product_Code
     [5]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [6]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    public init(
        name: String,
        tracks: PagingObject<Track>? = nil,
        artists: [Artist]? = nil,
        releaseDate: Date? = nil,
        uri: String? = nil,
        id: String? = nil,
        images: [SpotifyImage]? = nil,
        popularity: Int? = nil,
        label: String? = nil,
        genres: [String]? = nil,
        totalTracks: Int? = nil,
        href: URL? = nil,
        externalURLs: [String: URL]? = nil,
        externalIds: [String: String]? = nil,
        albumType: AlbumType? = nil,
        albumGroup: AlbumType? = nil,
        availableMarkets: [String]? = nil,
        copyrights: [SpotifyCopyright]? = nil,
        releaseDatePrecision: String? = nil,
        restrictions: [String: String]? = nil
    ) {
        self.name = name
        self.tracks = tracks
        self.artists = artists
        self.releaseDate = releaseDate
        self.uri = uri
        self.id = id
        self.images = images
        self.popularity = popularity
        self.label = label
        self.genres = genres
        self.totalTracks = totalTracks
        self.href = href
        self.externalURLs = externalURLs
        self.externalIds = externalIds
        self.albumType = albumType
        self.albumGroup = albumGroup
        self.availableMarkets = availableMarkets
        self.copyrights = copyrights
        self.releaseDatePrecision = releaseDatePrecision
        self.restrictions = restrictions
        self.type = .album
    }

}

extension Album: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(
            String.self, forKey: .name
        )
        self.tracks = try container.decodeIfPresent(
            PagingObject<Track>.self, forKey: .tracks
        )
        self.artists = try container.decodeIfPresent(
            [Artist].self, forKey: .artists
        )
        
        // MARK: Decode Release Date
        // this is the only property that needs to be decoded
        // in a custom manner
        self.releaseDate = try container.decodeSpotifyDateIfPresent(
            forKey: .releaseDate
        )
        
        self.releaseDatePrecision = try container.decodeIfPresent(
            String.self, forKey: .releaseDatePrecision
        )
        self.uri = try container.decodeIfPresent(
            String.self, forKey: .uri
        )
        self.id = try container.decodeIfPresent(
            String.self, forKey: .id
        )
        self.images = try container.decodeIfPresent(
            [SpotifyImage].self, forKey: .images
        )
        self.popularity = try container.decodeIfPresent(
            Int.self, forKey: .popularity
        )
        self.label = try container.decodeIfPresent(
            String.self, forKey: .label
        )
        self.genres = try container.decodeIfPresent(
            [String].self, forKey: .genres
        )
        self.totalTracks = try container.decodeIfPresent(
            Int.self, forKey: .totalTracks
        )
        self.href = try container.decodeIfPresent(
            URL.self, forKey: .href
        )
        self.externalURLs = try container.decodeIfPresent(
            [String: URL].self, forKey: .externalURLs
        )
        self.externalIds = try container.decodeIfPresent(
            [String: String].self, forKey: .externalIds
        )
        self.albumType = try container.decodeIfPresent(
            AlbumType.self, forKey: .albumType
        )
        self.albumGroup = try container.decodeIfPresent(
            AlbumType.self, forKey: .albumGroup
        )
        self.availableMarkets = try container.decodeIfPresent(
            [String].self, forKey: .availableMarkets
        )
        self.copyrights = try container.decodeIfPresent(
            [SpotifyCopyright].self, forKey: .copyrights
        )
        self.restrictions = try container.decodeIfPresent(
            [String: String].self, forKey: .restrictions
        )
        self.type = try container.decode(
            IDCategory.self, forKey: .type
        )
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(
            self.name, forKey: .name
        )
        try container.encodeIfPresent(
            self.tracks, forKey: .tracks
        )
        try container.encodeIfPresent(
            self.artists, forKey: .artists
        )
        
        // MARK: Encode Release Date
        // this is the only property that needs to be encoded
        // in a custom manner
        try container.encodeSpotifyDateIfPresent(
            self.releaseDate,
            datePrecision: self.releaseDatePrecision,
            forKey: .releaseDate
        )
        
        try container.encodeIfPresent(
            self.releaseDatePrecision,
            forKey: .releaseDatePrecision
        )
        try container.encodeIfPresent(
            self.uri, forKey: .uri
        )
        try container.encodeIfPresent(
            self.id, forKey: .id
        )
        try container.encodeIfPresent(
            self.images, forKey: .images
        )
        try container.encodeIfPresent(
            self.popularity, forKey: .popularity
        )
        try container.encodeIfPresent(
            self.label, forKey: .label
        )
        try container.encodeIfPresent(
            self.genres, forKey: .genres
        )
        try container.encodeIfPresent(
            self.totalTracks, forKey: .totalTracks
        )
        try container.encodeIfPresent(
            self.href, forKey: .href
        )
        try container.encodeIfPresent(
            self.externalURLs, forKey: .externalURLs
        )
        try container.encodeIfPresent(
            self.externalIds, forKey: .externalIds
        )
        try container.encodeIfPresent(
            self.albumType, forKey: .albumType
        )
        try container.encodeIfPresent(
            self.albumGroup, forKey: .albumGroup
        )
        try container.encodeIfPresent(
            self.availableMarkets, forKey: .availableMarkets
        )
        try container.encodeIfPresent(
            self.copyrights, forKey: .copyrights
        )
        try container.encodeIfPresent(
            self.restrictions, forKey: .restrictions
        )
        try container.encode(
            self.type, forKey: .type
        )
        
    }
    
    private enum CodingKeys: String, CodingKey {
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
        case totalTracks = "total_tracks"
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

extension Album: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
     ``Album/releaseDate`` is compared using `timeIntervalSince1970`, so it
     is considered a floating point property for the purposes of this method.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
        
        return self.name == other.name &&
                self.tracks == other.tracks &&
                self.artists == other.artists &&
                self.uri == other.uri &&
                self.id == other.id &&
                self.images == other.images &&
                self.popularity == other.popularity &&
                self.label == other.label &&
                self.genres == other.genres &&
                self.totalTracks == other.totalTracks &&
                self.href == other.href &&
                self.externalURLs == other.externalURLs &&
                self.externalIds == other.externalIds &&
                self.albumType == other.albumType &&
                self.albumGroup == other.albumGroup &&
                self.availableMarkets == other.availableMarkets &&
                self.copyrights == other.copyrights &&
                self.releaseDatePrecision == other.releaseDatePrecision &&
                self.restrictions == other.restrictions &&
                self.type == other.type &&
                self.releaseDate.isApproximatelyEqual(to: other.releaseDate)
            
    }

}
