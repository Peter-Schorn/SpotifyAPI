import Foundation

/**
 A Spotify [podcast show][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#show-object-full
 */
public struct Show: Hashable {

    /// The name of the show.
    public let name: String
    
    /// A description of the show.
    public let description: String
    
    /**
     The episodes for this show: An array of simplified episode objects
     wrapped in a paging object.
     
     Only available for the full version.
     
     See also `totalEpisodes`.
     */
    public let episodes: PagingObject<Episode>?
    
    /// The total number of episodes in the show.
    ///
    /// Only available for the full version.
    public let totalEpisodes: Int?
    
    /// Whether or not the episode has explicit content.
    /// `false` if unknown.
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
    
    /// A list of the countries in which the show can be played,
    /// identified by their [ISO 3166-1 alpha-2][1] code.
    ///
    /// [1]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
    public let availableMarkets: [String]
    
    /**
     A link to the Spotify web API endpoint providing the full show object.
     
     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in `Show` as the
     response type to retrieve the results.
     */
    public let href: String
       
    /**
     Known [external urls][1] for this episode.

     - key: The type of the URL, for example:
           "spotify" - The [Spotify URL][2] for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#external-url-object
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: String]?
    
    /// `true` if the episode is hosted outside of Spotify's CDN
    /// (content delivery network). Else, `false`.
    public let isExternallyHosted: Bool
    
    /// A list of the languages used in the episode,
    /// identified by their [ISO 639][1] code.
    ///
    /// [1]: https://en.wikipedia.org/wiki/ISO_639
    public let languages: [String]
    
    /// An array of copyright objects.
    /// Only available for the full version.
    public let copyrights: [SpotifyCopyright]?
    
    /// The media type of the show.
    public let mediaType: String
    
    /// The publisher of the show.
    public let publisher: String
    
    /// The object type. Always `show`.
    public let type: IDCategory
    
    /**
     Creates a Spotify [podcast show][1].
     
     - Parameters:
       - name: The name of the show.
       - description: A description of the show.
       - episodes: The episodes for this show: An array of simplified episode
             objects wrapped in a paging object.
       - isExplicit: Whether or not the episode has explicit content.
       - uri: The [Spotify URI][2] for the episode.
       - id: The [Spotify ID][2] for the episode.
       - images: The cover art for the episode.
       - availableMarkets: A list of the countries in which the show can be
             played, identified by their [ISO 3166-1 alpha-2][3] code.
       - href: A link to the Spotify web API endpoint providing the full show
             object.
       - externalURLs: Known [external urls][4] for this artist.
             - key: The type of the URL, for example:
                   "spotify" - The [Spotify URL][2] for the object.
             - value: An external, public URL to the object.
       - isExternallyHosted: `true` if the episode is hosted outside of
             Spotify's CDN (content delivery network). Else, `false`.
       - languages: A list of the languages used in the episode,
             identified by their [ISO 639][5] code.
       - copyrights: An array of copyright objects.
       - mediaType: The media type of the show.
       - publisher: The publisher of the show.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#album-object-full
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     [3]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [4]: https://developer.spotify.com/documentation/web-api/reference/object-model/#external-url-object
     [5]: https://en.wikipedia.org/wiki/ISO_639
     */
    public init(
        name: String,
        description: String,
        episodes: PagingObject<Episode>? = nil,
        totalEpisodes: Int,
        isExplicit: Bool,
        uri: String,
        id: String,
        images: [SpotifyImage]? = nil,
        availableMarkets: [String],
        href: String,
        externalURLs: [String : String]? = nil,
        isExternallyHosted: Bool,
        languages: [String],
        copyrights: [SpotifyCopyright]? = nil,
        mediaType: String,
        publisher: String
    ) {
        self.name = name
        self.description = description
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
    
    /// :nodoc:
    public enum CodingKeys: String, CodingKey {
        case name
        case description
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
    
}
