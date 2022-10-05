import Foundation

/// A Spotify audiobook chapter.
public struct AudiobookChapter: Hashable, SpotifyURIConvertible {
    
    /// The name of the audiobook chapter.
    public let name: String
    
    /// The audiobook that this chapter belongs to.
    public let audiobook: Audiobook?
    
    /// The zero-based index of this chapter in the audiobook it belongs to.
    public let chapterNumber: Int
    
    /// A URL to a 30 second preview (MP3 format) of this chapter, if available.
    public let audioPreviewURL: URL?
    
    /// A description of the chapter. See also ``htmlDescription``.
    public let description: String
    
    /// A description of the chapter which may contain HTML tags. See also
    /// ``description``.
    public let htmlDescription: String
    
    /**
     The user’s most recent position in the chapter.
    
     Non-`nil` only if the application has been authorized for the
     ``Scope/userReadPlaybackPosition`` scope.
     */
    public let resumePoint: ResumePoint?
    
    /// The chapter length, in milliseconds.
    public let durationMS: Int
    
    /// Whether or not the chapter is explicit. `false` if unknown.
    public let isExplicit: Bool
    
    /// The date the chapter was released.
    ///
    /// See also ``releaseDatePrecision``.
    public let releaseDate: Date?
    
    /// The [Spotify URI][1] for the chapter.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String

    /// The [Spotify ID][1] for the chapter.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /// Images for the chapter in various sizes, widest first.
    public let images: [SpotifyImage]?
    
    /**
     A list of the countries in which the chapter can be played, identified
     by their [ISO 3166-1 alpha-2][1] codes.
     
     If a market parameter was supplied in the request that returned this
     chapter, then this property will be `nil`.
    
     [1]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    public let availableMarkets: [String]?
    
    /**
     A link to the Spotify web API endpoint providing the full chapter object.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in
     ``AudiobookChapter`` as the response type to retrieve the results.
     */
    public let href: URL
    
    /// `true` if the chapter is playable in the given market. Else, `false`.
    public let isPlayable: Bool?
    
    /**
     Known external urls for this audiobook chapter.
     
     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
           for the object.
     - value: An external, public URL to the object.
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public let externalURLs: [String: URL]?
    
    /// A list of the languages used in the chapter, identified by their [ISO
    /// 639][1] code.
    ///
    /// [1]: https://en.wikipedia.org/wiki/ISO_639
    public let languages: [String]
    
    /**
     Part of the response when a content restriction is applied.
     
     The key will be "reason", and the value will be one of the
     following:
     * "payment_required" - The content item requires payment to be played.
     * "market" - The content item is not available in the given market.
     * "product" - The content item is not available for the user’s
       subscription type.
     * "explicit" - The content item is explicit and the user’s account is
       set to not play explicit content.
     
     Additional reasons and additional keys may be added in the future.
     */
    public let restrictions: [String: String]?
    
    /// The precision with which ``releaseDate`` is known: "year", "month", or
    /// "day".
    public let releaseDatePrecision: String?
    
    /// The object type. Always ``IDCategory/chapter``
    public let type: IDCategory
    
    /**
     Creates a Spotify audiobook chapter.
     
     - Parameters:
       - name: The name of the audiobook chapter.
       - audiobook: The audiobook that this chapter belongs to.
       - chapterNumber: The zero-based index of this chapter in the audiobook it
             belongs to.
       - audioPreviewURL: A URL to a 30 second preview (MP3 format) of this
             chapter, if available.
       - description: A description of the chapter. See also
             ``htmlDescription``.
       - htmlDescription: A description of the chapter which may contain HTML
             tags. See also ``description``.
       - resumePoint: The user’s most recent position in the chapter. Non-`nil`
         only if the application has been authorized for the
         ``Scope/userReadPlaybackPosition`` scope.
       - durationMS: The chapter length, in milliseconds.
       - isExplicit: Whether or not the chapter is explicit. `false` if unknown.
       - releaseDate: The date the chapter was released. See also
             ``releaseDatePrecision``.
       - uri: The [Spotify URI][1] for the chapter.
       - id: The [Spotify ID][1] for the chapter.
       - images: Images for the chapter in various sizes, widest first.
       - availableMarkets: A list of the countries in which the chapter can be
             played, identified by their [ISO 3166-1 alpha-2][2] codes.
       - href: A link to the Spotify web API endpoint providing the full chapter
             object. Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in
             ``AudiobookChapter`` as the response type to retrieve the results.
       - isPlayable: `true` if the chapter is playable in the given market.
             Else, `false`.
       - externalURLs: Known external urls for the chapter.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][1] for the object.
             - value: An external, public URL to the object.
       - languages: A list of the languages used in the chapter, identified by
             their [ISO 639][3] codes.
       - restrictions: Part of the response when a content restriction is
             applied. The key will be "reason", and the value will be one of the
             following:
             * "payment_required" - The content item requires payment to be
             played.
             * "market" - The content item is not available in the given market.
             * "product" - The content item is not available for the user’s
               subscription type.
             * "explicit" - The content item is explicit and the user’s account
               is set to not play explicit content.
             Additional reasons and additional keys may be added in the future.
       - releaseDatePrecision: The precision with which ``releaseDate`` is
             known: "year", "month", or "day".
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     [2]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://en.wikipedia.org/wiki/ISO_639
     */
    public init(
        name: String,
        audiobook: Audiobook? = nil,
        chapterNumber: Int,
        audioPreviewURL: URL? = nil,
        description: String,
        htmlDescription: String,
        resumePoint: ResumePoint? = nil,
        durationMS: Int,
        isExplicit: Bool,
        releaseDate: Date? = nil,
        uri: String,
        id: String,
        images: [SpotifyImage]? = nil,
        availableMarkets: [String]? = nil,
        href: URL,
        isPlayable: Bool?,
        externalURLs: [String : URL]? = nil,
        languages: [String],
        restrictions: [String : String]? = nil,
        releaseDatePrecision: String? = nil
    ) {
        self.name = name
        self.audiobook = audiobook
        self.chapterNumber = chapterNumber
        self.audioPreviewURL = audioPreviewURL
        self.description = description
        self.htmlDescription = htmlDescription
        self.resumePoint = resumePoint
        self.durationMS = durationMS
        self.isExplicit = isExplicit
        self.releaseDate = releaseDate
        self.uri = uri
        self.id = id
        self.images = images
        self.availableMarkets = availableMarkets
        self.href = href
        self.isPlayable = isPlayable
        self.externalURLs = externalURLs
        self.languages = languages
        self.restrictions = restrictions
        self.releaseDatePrecision = releaseDatePrecision
        self.type = .chapter
    }

}

extension AudiobookChapter: Codable {

    private enum CodingKeys: String, CodingKey {
        case name
        case audiobook
        case chapterNumber = "chapter_number"
        case audioPreviewURL = "audio_preview_url"
        case description
        case htmlDescription = "html_description"
        case resumePoint = "resume_point"
        case durationMS = "duration_ms"
        case isExplicit = "explicit"
        case releaseDate = "release_date"
        case uri
        case id
        case images
        case availableMarkets = "available_markets"
        case href
        case isPlayable = "is_playable"
        case externalURLs = "external_urls"
        case languages
        case restrictions
        case restriction
        case releaseDatePrecision = "release_date_precision"
        case type
    }
    
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.restrictions) {
            self.restrictions = try container.decodeIfPresent(
                [String : String].self, forKey: .restrictions
            )
        }
        else if container.contains(.restriction) {
            self.restrictions = try container.decodeIfPresent(
                [String : String].self, forKey: .restriction
            )
        }
        else {
            self.restrictions = nil
        }
        
        self.name = try container.decode(
            String.self, forKey: .name
        )
        self.audiobook = try container.decodeIfPresent(
            Audiobook.self, forKey: .audiobook
        )
        self.chapterNumber = try container.decode(
            Int.self, forKey: .chapterNumber
        )
        self.audioPreviewURL = try container.decodeIfPresent(
            URL.self, forKey: .audioPreviewURL
        )
        self.description = try container.decode(
            String.self, forKey: .description
        )
        self.htmlDescription = try container.decode(
            String.self, forKey: .htmlDescription
        )
        self.resumePoint = try container.decodeIfPresent(
            ResumePoint.self, forKey: .resumePoint
        )
        self.durationMS = try container.decode(
            Int.self, forKey: .durationMS
        )
        self.isExplicit = try container.decode(
            Bool.self, forKey: .isExplicit
        )
        self.releaseDate = try container.decodeSpotifyDateIfPresent(
            forKey: .releaseDate
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
        self.isPlayable = try container.decodeIfPresent(
            Bool.self, forKey: .isPlayable
        )
        self.externalURLs = try container.decodeIfPresent(
            [String : URL].self, forKey: .externalURLs
        )
        self.languages = try container.decode(
            [String].self, forKey: .languages
        )
        self.releaseDatePrecision = try container.decodeIfPresent(
            String.self, forKey: .releaseDatePrecision
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
            self.audiobook, forKey: .audiobook
        )
        try container.encode(
            self.chapterNumber, forKey: .chapterNumber
        )
        try container.encodeIfPresent(
            self.audioPreviewURL, forKey: .audioPreviewURL
        )
        try container.encode(
            self.description, forKey: .description
        )
        try container.encode(
            self.htmlDescription, forKey: .htmlDescription
        )
        try container.encodeIfPresent(
            self.resumePoint, forKey: .resumePoint
        )
        try container.encode(
            self.durationMS, forKey: .durationMS
        )
        try container.encode(
            self.isExplicit, forKey: .isExplicit
        )
        try container.encodeSpotifyDateIfPresent(
            self.releaseDate,
            datePrecision: self.releaseDatePrecision,
            forKey: .releaseDate
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
            self.isPlayable, forKey: .isPlayable
        )
        try container.encodeIfPresent(
            self.externalURLs, forKey: .externalURLs
        )
        try container.encode(
            self.languages, forKey: .languages
        )
        try container.encodeIfPresent(
            self.restrictions, forKey: .restrictions
        )
        try container.encodeIfPresent(
            self.releaseDatePrecision, forKey: .releaseDatePrecision
        )
        try container.encode(
            self.type, forKey: .type
        )
        
    }

}

extension AudiobookChapter: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
     ``AudiobookChapter/releaseDate`` is compared using `timeIntervalSince1970`,
     so it is considered a floating point property for the purposes of this
     method.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: AudiobookChapter) -> Bool {
        
        return self.name == other.name &&
                self.audiobook == other.audiobook &&
                self.chapterNumber == other.chapterNumber &&
                self.audioPreviewURL == other.audioPreviewURL &&
                self.description == other.description &&
                self.htmlDescription == other.htmlDescription &&
                self.resumePoint == other.resumePoint &&
                self.durationMS == other.durationMS &&
                self.isExplicit == other.isExplicit &&
                self.releaseDate.isApproximatelyEqual(to: other.releaseDate) &&
                self.uri == other.uri &&
                self.id == other.id &&
                self.images == other.images &&
                self.availableMarkets == other.availableMarkets &&
                self.href == other.href &&
                self.isPlayable == other.isPlayable &&
                self.externalURLs == other.externalURLs &&
                self.languages == other.languages &&
                self.restrictions == other.restrictions &&
                self.releaseDatePrecision == other.releaseDatePrecision &&
                self.type == other.type

    }

}
