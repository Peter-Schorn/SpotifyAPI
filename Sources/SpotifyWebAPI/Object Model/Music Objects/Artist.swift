import Foundation

/// A Spotify artist.
public struct Artist: Hashable {
    
    /// The name of the artist.
    public let name: String
    
    /// The [Spotify URI][1] for the artist.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String?

    /// The [Spotify ID][1] for the artist.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String?
    
    /// Images of the artist in various sizes, widest first.
    ///
    /// Only available for the full artist object.
    public let images: [SpotifyImage]?
    
    /**
     The popularity of the artist.
    
     The value will be between 0 and 100, with 100 being the most popular. The
     artist’s popularity is calculated from the popularity of all the artist’s
     tracks.
    
     Only available for the full artist object.
     */
    public let popularity: Int?
    
    /**
     Known external urls for this artist.
    
     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
           for the object.
     - value: An external, public URL to the object.
    
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: URL]?
    
    /// Information about the followers of the artist.
    ///
    /// Only available for the full artist object.
    public let followers: Followers?
    
    /**
     A list of the genres the artist is associated with.
    
     For example: "Prog Rock" , "Post-Grunge". (If not yet classified, the array
     is empty.)
    
     Only available for the full artist object.
     */
    public let genres: [String]?

    /**
     A link to the Spotify web API endpoint providing the full artist object.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``Artist`` as
     the response type to retrieve the results.
     */
    public let href: URL?
    
    /// The object type. Always ``IDCategory/artist``.
    public let type: IDCategory
    
    /**
     A Spotify artist.
     
     - Parameters:
       - name: The name of the artist.
       - uri: The [Spotify URI][1] for the artist.
       - id: The [Spotify ID][1] for the artist.
       - images: Images of the artist.
       - popularity: The popularity of the artist. Should be between 0 and 100,
             inclusive.
       - externalURLs: Known external urls for this artist.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][1] for the object.
             - value: An external, public URL to the object.
       - followers: Information about the followers of the artist.
       - genres: A list of the genres the artist is associated with.
       - href: A link to the Spotify web API endpoint providing the full
             artist object.
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public init(
        name: String,
        uri: String? = nil,
        id: String? = nil,
        images: [SpotifyImage]? = nil,
        popularity: Int? = nil,
        externalURLs: [String: URL]? = nil,
        followers: Followers? = nil,
        genres: [String]? = nil,
        href: URL? = nil
    ) {
        self.name = name
        self.uri = uri
        self.id = id
        self.images = images
        self.popularity = popularity
        self.externalURLs = externalURLs
        self.followers = followers
        self.genres = genres
        self.href = href
        self.type = .artist
    }

}

extension Artist: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case uri
        case id
        case images
        case popularity
        case externalURLs = "external_urls"
        case followers
        case genres
        case href
        case type
    }
    
}
