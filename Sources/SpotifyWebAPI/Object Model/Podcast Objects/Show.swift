import Foundation

/// A Spotify podcast show.
public struct Show: Hashable, SpotifyURIConvertible {

    /// The name of the show.
    public let name: String
    
    /// A description of the show. See also ``htmlDescription``.
    public let description: String
    
    /// A description of the show which may contain HTML tags. See also
    /// ``description``.
    public let htmlDescription: String?
    
    /**
     The episodes for this show: An array of simplified episode objects wrapped
     in a paging object.
     
     Only available for the full version.
     
     See also ``totalEpisodes``.
     */
    public let episodes: PagingObject<Episode>?
    
    /// The total number of episodes in the show.
    ///
    /// Only available for the full version.
    public let totalEpisodes: Int?
    
    /// Whether or not the episode has explicit content. `false` if unknown.
    public let isExplicit: Bool

    /// The [Spotify URI][1] for the episode.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String

    /// The [Spotify ID][1] for the episode.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /// The cover art for the episode in various sizes, widest first.
    public let images: [SpotifyImage]?
    
    /// A list of the countries in which the show can be played, identified by
    /// their [ISO 3166-1 alpha-2][1] codes.
    ///
    /// [1]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
    public let availableMarkets: [String]
    
    /**
     A link to the Spotify web API endpoint providing the full show object.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``Show`` as the
     response type to retrieve the results.
     */
    public let href: URL
       
    /**
     Known external urls for this show.
     
     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
           for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: URL]?
    
    /// `true` if the episode is hosted outside of Spotify's CDN (content
    /// delivery network). Else, `false`.
    public let isExternallyHosted: Bool
    
    /// A list of the languages used in the episode, identified by their [ISO
    /// 639][1] code.
    ///
    /// [1]: https://en.wikipedia.org/wiki/ISO_639
    public let languages: [String]
    
    /// The copyrights for the show. Only available for the full version.
    public let copyrights: [SpotifyCopyright]?
    
    /// The media type of the show.
    public let mediaType: String
    
    /// The publisher of the show.
    public let publisher: String
    
    /// The object type. Always ``IDCategory/show``.
    public let type: IDCategory
    
    /**
     Creates a Spotify podcast show.

     - Parameters:
       - name: The name of the show.
       - description: A description of the show. See also ``htmlDescription``.
       - htmlDescription: A description of the show which may contain HTML tags.
             See also ``description``.
       - episodes: The episodes for this show: An array of simplified episode
             objects wrapped in a paging object.
       - isExplicit: Whether or not the episode has explicit content.
       - uri: The [Spotify URI][1] for the episode.
       - id: The [Spotify ID][1] for the episode.
       - images: The cover art for the episode.
       - availableMarkets: A list of the countries in which the show can be
             played, identified by their [ISO 3166-1 alpha-2][2] code.
       - href: A link to the Spotify web API endpoint providing the full show
             object.
       - externalURLs: Known external urls for this show.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][1] for the object.
             - value: An external, public URL to the object.
       - isExternallyHosted: `true` if the episode is hosted outside of
             Spotify's CDN (content delivery network). Else, `false`.
       - languages: A list of the languages used in the episode, identified by
             their [ISO 639][3] code.
       - copyrights: The copyrights for the show. Only available for the full
             version.
       - mediaType: The media type of the show.
       - publisher: The publisher of the show.
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     [2]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://en.wikipedia.org/wiki/ISO_639
     */
    public init(
        name: String,
        description: String,
        htmlDescription: String? = nil,
        episodes: PagingObject<Episode>? = nil,
        totalEpisodes: Int,
        isExplicit: Bool,
        uri: String,
        id: String,
        images: [SpotifyImage]? = nil,
        availableMarkets: [String],
        href: URL,
        externalURLs: [String: URL]? = nil,
        isExternallyHosted: Bool,
        languages: [String],
        copyrights: [SpotifyCopyright]? = nil,
        mediaType: String,
        publisher: String
    ) {
        self.name = name
        self.description = description
        self.htmlDescription = htmlDescription
        self.episodes = episodes
        self.totalEpisodes = totalEpisodes
        self.isExplicit = isExplicit
        self.uri = uri
        self.id = id
        self.images = images
        self.availableMarkets = availableMarkets
        self.href = href
        self.externalURLs = externalURLs
        self.isExternallyHosted = isExternallyHosted
        self.languages = languages
        self.copyrights = copyrights
        self.mediaType = mediaType
        self.publisher = publisher
        self.type = .show
    }

}

extension Show: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case htmlDescription = "html_description"
        case episodes
        case totalEpisodes = "total_episodes"
        case isExplicit = "explicit"
        case uri
        case id
        case images
        case availableMarkets = "available_markets"
        case href
        case externalURLs = "external_urls"
        case isExternallyHosted = "is_externally_hosted"
        case languages
        case copyrights
        case mediaType = "media_type"
        case publisher
        case type
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(
            String.self, forKey: .name
        )
        self.description = try container.decode(
            String.self, forKey: .description
        )
        self.htmlDescription = try container.decodeIfPresent(
            String.self, forKey: .htmlDescription
        )
        self.episodes = try container.decodeIfPresent(
            PagingObject<Episode>.self, forKey: .episodes
        )
        self.totalEpisodes = try container.decodeIfPresent(
            Int.self, forKey: .totalEpisodes
        )
        self.isExplicit = try container.decode(
            Bool.self, forKey: .isExplicit
        )
        self.uri = try container.decode(
            String.self, forKey: .uri
        )
        self.id = try container.decode(
            String.self, forKey: .id
        )
        self.images = try container.decodeIfPresent(
            [SpotifyImage].self, forKey: .images
        )
        self.availableMarkets = try container.decode(
            [String].self, forKey: .availableMarkets
        )
        self.href = try container.decode(
            URL.self, forKey: .href
        )
        self.externalURLs = try container.decodeIfPresent(
            [String : URL].self, forKey: .externalURLs
        )
        self.isExternallyHosted = try container.decodeIfPresent(
            Bool.self, forKey: .isExternallyHosted
        ) ?? false
        self.languages = try container.decode(
            [String].self, forKey: .languages
        )
        self.copyrights = try container.decodeIfPresent(
            [SpotifyCopyright].self, forKey: .copyrights
        )
        self.mediaType = try container.decode(
            String.self, forKey: .mediaType
        )
        self.publisher = try container.decode(
            String.self, forKey: .publisher
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
        try container.encode(
            self.description, forKey: .description
        )
        try container.encodeIfPresent(
            self.htmlDescription, forKey: .htmlDescription
        )
        try container.encodeIfPresent(
            self.episodes, forKey: .episodes
        )
        try container.encodeIfPresent(
            self.totalEpisodes, forKey: .totalEpisodes
        )
        try container.encode(
            self.isExplicit, forKey: .isExplicit
        )
        try container.encode(
            self.uri, forKey: .uri
        )
        try container.encode(
            self.id, forKey: .id
        )
        try container.encodeIfPresent(
            self.images, forKey: .images
        )
        try container.encode(
            self.availableMarkets, forKey: .availableMarkets
        )
        try container.encode(
            self.href, forKey: .href
        )
        try container.encodeIfPresent(
            self.externalURLs, forKey: .externalURLs
        )
        try container.encode(
            self.isExternallyHosted, forKey: .isExternallyHosted
        )
        try container.encode(
            self.languages, forKey: .languages
        )
        try container.encodeIfPresent(
            self.copyrights, forKey: .copyrights
        )
        try container.encode(
            self.mediaType, forKey: .mediaType
        )
        try container.encode(
            self.publisher, forKey: .publisher
        )
        try container.encode(
            self.type, forKey: .type
        )
        
    }
    
}

extension Show: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
     Dates are compared using `timeIntervalSince1970`, so they are considered
     floating point properties for the purposes of this method.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
     
        return self.name == other.name &&
                self.description == other.description &&
                self.htmlDescription == other.htmlDescription &&
                self.totalEpisodes == other.totalEpisodes &&
                self.isExplicit == other.isExplicit &&
                self.uri == other.uri &&
                self.id == other.id &&
                self.images == other.images &&
                self.availableMarkets == other.availableMarkets &&
                self.href == other.href &&
                self.externalURLs == other.externalURLs &&
                self.isExternallyHosted == other.isExternallyHosted &&
                self.languages == other.languages &&
                self.copyrights == other.copyrights &&
                self.mediaType == other.mediaType &&
                self.publisher == other.publisher &&
                self.type == other.type &&
                self.episodes.isApproximatelyEqual(to: other.episodes)

    }

}
