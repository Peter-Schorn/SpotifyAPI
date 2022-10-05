import Foundation

/// A Spotify audiobook.
public struct Audiobook: Hashable, SpotifyURIConvertible {
    
    /// The name of the audiobook.
    public let name: String
    
    /// The authors of the audiobook.
    public let authors: [AudiobookAuthor]
        
    /// The narrators of the audiobook.
    public let narrators: [AudiobookAuthor]
    
    /// The publisher of the audiobook.
    public let publisher: String
    
    /// A description of the audiobook. See also ``htmlDescription``.
    public let description: String
    
    /// A description of the audiobook which may contain HTML tags. See also
    /// ``description``.
    public let htmlDescription: String
    
    /**
     The chapters of this audiobook.
     
     For certain endpoints, this property will be `nil`, especially if nested
     inside a much larger object. For example, it will be `nil` if retrieved
     from the ``SpotifyAPI/chapter(_:market:)`` endpoint.
     */
    public let chapters: PagingObject<AudiobookChapter>?
    
    /// The total number of chapters in the audiobook.
    public let totalChapters: Int?
    
    /// Whether or not the audiobook is explicit. `false` if unknown.
    public let isExplicit: Bool

    /// The [Spotify URI][1] for the audiobook.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String
    
    
    /// The [Spotify ID][1] for the audiobook.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String

    /// Images for the audiobook in various sizes, widest first.
    public let images: [SpotifyImage]?
    
    /**
     A list of the countries in which the audiobook can be played, identified
     by their [ISO 3166-1 alpha-2][1] codes.
     
     If a market parameter was supplied in the request that returned this
     audiobook, then this property will be `nil`.
    
     [1]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    public let availableMarkets: [String]?
    
    /**
     A link to the Spotify web API endpoint providing the full audiobook object.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``Audioboook``
     as the response type to retrieve the results.
     */
    public let href: URL

    /**
     Known external urls for the audiobook.
     
     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
     for the object.
     - value: An external, public URL to the object.
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: URL]?

    /// A list of the languages used in the audiobook, identified by their [ISO
    /// 639][1] codes.
    ///
    /// [1]: https://en.wikipedia.org/wiki/ISO_639
    public let languages: [String]

    /// The copyrights for the audiobook.
    public let copyrights: [SpotifyCopyright]?
    
    /// The media type of the audiobook. For example: "audio".
    public let mediaType: String

    /// The edition of the audiobook. For example: "Unabridged".
    public let edition: String?
    
    /// The object type. Always ``IDCategory/audiobook``.
    public let type: IDCategory
    
    /**
     Creates a Spotify audiobook.
     
     - Parameters:
       - name: The name of the audiobook.
       - authors: The authors of the audiobook.
       - narrators: The narrators of the audiobook.
       - publisher: The publisher of the audiobook.
       - description: A description of the audiobook. See also
             ``htmlDescription``.
       - htmlDescription: A description of the audiobook which may contain HTML
             tags. See also ``description``.
       - chapters: The chapters of this audiobook. For certain endpoints, this
             property will be `nil`, especially if nested inside a much larger
             object. For example, it will be `nil` if retrieved from the
             ``SpotifyAPI/chapter(_:market:)`` endpoint.
       - totalChapters: The total number of chapters in the audiobook.
       - isExplicit: Whether or not the audiobook is explicit. `false` if
             unknown.
       - uri: The [Spotify URI][1] for the audiobook.
       - id: The [Spotify ID][1] for the audiobook.
       - images: Images for the audiobook in various sizes, widest first.
       - availableMarkets: A list of the countries in which the audiobook can be
             played, identified by their [ISO 3166-1 alpha-2][2] codes.
       - href: A link to the Spotify web API endpoint providing the full
             audiobook object. Use ``SpotifyAPI/getFromHref(_:responseType:)``,
             passing in ``Audioboook`` as the response type to retrieve the
             results.
       - externalURLs: Known external urls for the audiobook.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][1] for the object.
             - value: An external, public URL to the object.
       - languages: A list of the languages used in the audiobook, identified by
             their [ISO 639][3] codes.
       - copyrights: The copyrights for the audiobook.
       - mediaType: The media type of the audiobook. For example: "audio".
       - edition: The edition of the audiobook. For example: "Unabridged".
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     [2]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://en.wikipedia.org/wiki/ISO_639
     */
    public init(
        name: String,
        authors: [AudiobookAuthor],
        narrators: [AudiobookAuthor],
        publisher: String,
        description: String,
        htmlDescription: String,
        chapters: PagingObject<AudiobookChapter>?,
        totalChapters: Int? = nil,
        isExplicit: Bool,
        uri: String,
        id: String,
        images: [SpotifyImage]? = nil,
        availableMarkets: [String]? = nil,
        href: URL,
        externalURLs: [String : URL]? = nil,
        languages: [String],
        copyrights: [SpotifyCopyright]? = nil,
        mediaType: String,
        edition: String? = nil
    ) {
        self.name = name
        self.authors = authors
        self.narrators = narrators
        self.publisher = publisher
        self.description = description
        self.htmlDescription = htmlDescription
        self.chapters = chapters
        self.totalChapters = totalChapters
        self.isExplicit = isExplicit
        self.uri = uri
        self.id = id
        self.images = images
        self.availableMarkets = availableMarkets
        self.href = href
        self.externalURLs = externalURLs
        self.languages = languages
        self.copyrights = copyrights
        self.mediaType = mediaType
        self.edition = edition
        self.type = .audiobook
    }

}

extension Audiobook: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case authors
        case narrators
        case publisher
        case description
        case htmlDescription = "html_description"
        case chapters
        case totalChapters = "total_chapters"
        case isExplicit = "explicit"
        case uri
        case id
        case images
        case availableMarkets = "available_markets"
        case href
        case externalURLs = "external_urls"
        case languages
        case copyrights
        case mediaType = "media_type"
        case edition
        case type
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(
            String.self, forKey: .name
        )
        self.authors = try container.decode(
            [AudiobookAuthor].self, forKey: .authors
        )
        self.narrators = try container.decode(
            [AudiobookAuthor].self, forKey: .narrators
        )
        self.publisher = try container.decode(
            String.self, forKey: .publisher
        )
        self.description = try container.decode(
            String.self, forKey: .description
        )
        self.htmlDescription = try container.decode(
            String.self, forKey: .htmlDescription
        )
        self.chapters = try? container.decodeIfPresent(
            PagingObject<AudiobookChapter>.self, forKey: .chapters
        )
        self.totalChapters = try container.decodeIfPresent(
            Int.self, forKey: .totalChapters
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
        self.availableMarkets = try container.decodeIfPresent(
            [String].self, forKey: .availableMarkets
        )
        self.href = try container.decode(
            URL.self, forKey: .href
        )
        self.externalURLs = try container.decodeIfPresent(
            [String : URL].self, forKey: .externalURLs
        )
        self.languages = try container.decode(
            [String].self, forKey: .languages
        )
        self.copyrights = try container.decodeIfPresent(
            [SpotifyCopyright].self, forKey: .copyrights
        )
        self.mediaType = try container.decode(
            String.self, forKey: .mediaType
        )
        self.edition = try container.decodeIfPresent(
            String.self, forKey: .edition
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
            self.authors, forKey: .authors
        )
        try container.encode(
            self.narrators, forKey: .narrators
        )
        try container.encode(
            self.publisher, forKey: .publisher
        )
        try container.encode(
            self.description, forKey: .description
        )
        try container.encode(
            self.htmlDescription, forKey: .htmlDescription
        )
        try container.encodeIfPresent(
            self.chapters, forKey: .chapters
        )
        try container.encodeIfPresent(
            self.totalChapters, forKey: .totalChapters
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
        try container.encodeIfPresent(
            self.availableMarkets, forKey: .availableMarkets
        )
        try container.encode(
            self.href, forKey: .href
        )
        try container.encodeIfPresent(
            self.externalURLs, forKey: .externalURLs
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
        try container.encodeIfPresent(
            self.edition, forKey: .edition
        )
        try container.encode(
            self.type, forKey: .type
        )
        
    }
    
}

extension Audiobook: ApproximatelyEquatable {

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
                self.authors == other.authors &&
                self.narrators == other.narrators &&
                self.publisher == other.publisher &&
                self.description == other.description &&
                self.htmlDescription == other.htmlDescription &&
                self.chapters.isApproximatelyEqual(to: other.chapters) &&
                self.totalChapters == other.totalChapters &&
                self.isExplicit == other.isExplicit &&
                self.uri == other.uri &&
                self.id == other.id &&
                self.images == other.images &&
                self.availableMarkets == other.availableMarkets &&
                self.href == other.href &&
                self.externalURLs == other.externalURLs &&
                self.languages == other.languages &&
                self.copyrights == other.copyrights &&
                self.mediaType == other.mediaType &&
                self.edition == other.edition &&
                self.type == other.type

    }

}
