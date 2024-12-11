import Foundation


/// A Spotify podcast episode.
public struct Episode: Hashable {

    /// The name of the episode.
    public let name: String?

    /// The show on which the episode belongs (simplified version).
    ///
    /// Only available for the full version.
    public let show: Show?
    
    /// A URL to a 30 second preview (MP3 format) of the episode, if available.
    public let audioPreviewURL: URL?
    
    /// A description of the episode. See also ``htmlDescription``.
    public let description: String?

    /// A description of the episode which may contain HTML tags. See also
    /// ``description``.
    public let htmlDescription: String?

    /**
     The user’s most recent position in the episode.
    
     Non-`nil` only if the application has been authorized for the
     ``Scope/userReadPlaybackPosition`` scope.
     */
    public let resumePoint: ResumePoint?
    
    /// The episode length in milliseconds.
    public let durationMS: Int?

    /// Whether or not the episode has explicit content. `false` if unknown.
    public let isExplicit: Bool

    /// The date the episode was first released.
    ///
    /// See also ``releaseDatePrecision``.
    public let releaseDate: String?

    /// The [Spotify URI][1] for the episode.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
    public let uri: String?

    /// The [Spotify ID][1] for the episode.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
    public let id: String?

    /// The cover art for the episode in various sizes, widest first.
    public let images: [SpotifyImage]?

    /**
     A link to the Spotify web API endpoint providing the full episode object.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``Episode`` as
     the response type to retrieve the results.
     */
    public let href: URL?

    /// `true` if the episode is playable in the given market. Else, `false`.
    public let isPlayable: Bool?

    /**
     Known external urls for this episode.

     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
           for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
     */
    public let externalURLs: [String: URL]?
    
    /// `true` if the episode is hosted outside of Spotify's CDN (content
    /// delivery network). Else, `false`.
    public let isExternallyHosted: Bool?

    /// A list of the languages used in the episode, identified by their [ISO
    /// 639][1] code.
    ///
    /// [1]: https://en.wikipedia.org/wiki/ISO_639
    public let languages: [String]?

    /// The precision with which ``releaseDate`` is known: "year", "month", or
    /// "day".
    public let releaseDatePrecision: String?
 
    /**
     Part of the response when a content restriction is applied.
     
     The key will be "reason", and the value will be one of the
     following:
     * "market" - The content item is not available in the given market.
     * "product" - The content item is not available for the user’s
       subscription type.
     * "explicit" - The content item is explicit and the user’s account is
       set to not play explicit content.
     
     Additional reasons and additional keys may be added in the future.
     */
    public let restrictions: [String: String]?

    /// The object type. Always ``IDCategory/episode``.
    public let type: IDCategory
 
    /**
     Creates a Spotify podcast episode.
     
     - Parameters:
       - name: The name of the episode.
       - show: The show on which the episode belongs.
       - audioPreviewURL: A URL to a 30 second preview (MP3 format) of the
             episode.
       - description: A description of the episode. See also
             ``htmlDescription``.
       - htmlDescription: A description of the episode which may contain HTML
             tags. See also ``description``.
       - resumePoint: The user’s most recent position in the episode. Set if the
             supplied access token is a user token and has the
             ``Scope/userReadPlaybackPosition`` scope.
       - durationMS: The episode length in milliseconds.
       - isExplicit: Whether or not the episode has explicit content.
       - releaseDate: The date the episode was first released.
       - uri: The [Spotify URI][1] for the episode.
       - id: The [Spotify ID][1] for the episode.
       - images: The cover art for the episode in various sizes.
       - href: A link to the Spotify web API endpoint providing the full episode
             object.
       - isPlayable: `true` if the episode is playable in the given market.
            Else, `false`.
       - externalURLs: Known external urls for this episode.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][1] for the object.
             - value: An external, public URL to the object.
       - isExternallyHosted: `true` if the episode is hosted outside of
             Spotify's CDN (content delivery network). Else, `false`.
       - languages: A list of the languages used in the episode, identified by
             their [ISO 639][2] codes.
       - releaseDatePrecision: The precision with which ``releaseDate`` is
             known: "year", "month", or "day".
       - restrictions: Part of the response when a content restriction is
             applied. Else, `nil`. The key will be
             "reason", and the value will be one of the following:
             * "market" - The content item is not available in the given market.
             * "product" - The content item is not available for the user’s
               subscription type.
             * "explicit" - The content item is explicit and the user’s account
               is set to not play explicit content.
             Additional reasons and additional keys may be added in the future.
     
     [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
     [2]: https://en.wikipedia.org/wiki/ISO_639
     */
    public init(
        name: String? = nil,
        show: Show? = nil,
        audioPreviewURL: URL? = nil,
        description: String? = nil,
        htmlDescription: String? = nil,
        resumePoint: ResumePoint? = nil,
        durationMS: Int? = nil,
        isExplicit: Bool = false,
        releaseDate: String? = nil,
        uri: String? = nil,
        id: String? = nil,
        images: [SpotifyImage]? = nil,
        href: URL? = nil,
        isPlayable: Bool? = nil,
        externalURLs: [String: URL]? = nil,
        isExternallyHosted: Bool? = nil,
        languages: [String]? = nil,
        releaseDatePrecision: String? = nil,
        restrictions: [String: String]? = nil
    ) {
        self.name = name
        self.show = show
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
        self.href = href
        self.isPlayable = isPlayable
        self.externalURLs = externalURLs
        self.isExternallyHosted = isExternallyHosted
        self.languages = languages
        self.releaseDatePrecision = releaseDatePrecision
        self.type = .episode
        self.restrictions = restrictions
    }

}

extension Episode: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(
            String.self, forKey: .name
        )
        
        self.show = try container.decodeIfPresent(
            Show.self, forKey: .show
        )
        self.audioPreviewURL = try container.decodeIfPresent(
            URL.self, forKey: .audioPreviewURL
        )
        self.description = try container.decodeIfPresent(
            String.self, forKey: .description
        )
        self.htmlDescription = try container.decodeIfPresent(
            String.self, forKey: .htmlDescription
        )
        self.resumePoint = try? container.decodeIfPresent(
            ResumePoint.self, forKey: .resumePoint
        )
        self.durationMS = try container.decodeIfPresent(
            Int.self, forKey: .durationMS
        )
        self.isExplicit = try container.decodeIfPresent(
            Bool.self, forKey: .isExplicit
        ) ?? false

        self.releaseDate = try container.decodeIfPresent(
            String.self, forKey: .releaseDate
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
        
        self.images = try container.decodeSpotifyImages(forKey: .images)
        
        self.href = try container.decodeIfPresent(
            URL.self, forKey: .href
        )
        
        self.isPlayable = try container.decodeIfPresent(
            Bool.self, forKey: .isPlayable
        ) ?? true

        self.externalURLs = try container.decodeIfPresent(
            [String: URL].self, forKey: .externalURLs
        )
        self.isExternallyHosted = try container.decodeIfPresent(
            Bool.self, forKey: .isExternallyHosted
        ) ?? false
        self.languages = try container.decodeAndUnwrapArray(forKey: .languages)
        self.restrictions = try container.decodeIfPresent(
            [String: String].self, forKey: .restrictions
        )

        self.type = (try? container.decodeIfPresent(
            IDCategory.self, forKey: .type
        )) ?? .episode

    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(
            self.name, forKey: .name
        )
        try container.encodeIfPresent(
            self.show, forKey: .show
        )
        try container.encodeIfPresent(
            self.audioPreviewURL, forKey: .audioPreviewURL
        )
        try container.encodeIfPresent(
            self.description, forKey: .description
        )
        try container.encodeIfPresent(
            self.htmlDescription, forKey: .htmlDescription
        )
        try container.encodeIfPresent(
            self.resumePoint, forKey: .resumePoint
        )
        try container.encodeIfPresent(
            self.durationMS, forKey: .durationMS
        )
        try container.encode(
            self.isExplicit, forKey: .isExplicit
        )
        
        try container.encodeIfPresent(
            self.releaseDate,
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
            self.href, forKey: .href
        )
        
        try container.encodeIfPresent(
            self.isPlayable, forKey: .isPlayable
        )
        
        try container.encodeIfPresent(
            self.externalURLs, forKey: .externalURLs
        )
        try container.encodeIfPresent(
            self.isExternallyHosted, forKey: .isExternallyHosted
        )
        try container.encodeIfPresent(
            self.languages, forKey: .languages
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
        case show
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
        case href
        case externalURLs = "external_urls"
        case isExternallyHosted = "is_externally_hosted"
        case isPlayable = "is_playable"
        case languages
        case releaseDatePrecision = "release_date_precision"
        case restrictions
        case type
    }
    
}

extension Episode: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
     ``Episode/releaseDate`` is compared using `timeIntervalSince1970`, so it
     is considered a floating point property for the purposes of this method.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
        
        return self.name == other.name &&
                self.show == other.show &&
                self.audioPreviewURL == other.audioPreviewURL &&
                self.description == other.description &&
                self.htmlDescription == other.htmlDescription &&
                self.resumePoint == other.resumePoint &&
                self.durationMS == other.durationMS &&
                self.isExplicit == other.isExplicit &&
                self.uri == other.uri &&
                self.id == other.id &&
                self.images == other.images &&
                self.href == other.href &&
                self.isPlayable == other.isPlayable &&
                self.externalURLs == other.externalURLs &&
                self.isExternallyHosted == other.isExternallyHosted &&
                self.languages == other.languages &&
                self.releaseDatePrecision == other.releaseDatePrecision &&
                self.type == other.type &&
                self.releaseDate == other.releaseDate &&
                self.show.isApproximatelyEqual(to: other.show)
        
    }

}
