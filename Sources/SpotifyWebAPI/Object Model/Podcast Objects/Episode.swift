import Foundation


/**
 A Spotify [podcast episode][1].
 
 [1]:https://developer.spotify.com/documentation/web-api/reference/#object-episodeobject
 */
public struct Episode: Hashable, SpotifyURIConvertible {

    /// The name of the episode.
    public let name: String
    
    /// The show on which the episode belongs (simplified version).
    ///
    /// Only available for the full version.
    public let show: Show?
    
    /// A URL to a 30 second preview (MP3 format) of the episode, if available.
    public let audioPreviewURL: URL?
    
    /// A description of the episode.
    public let description: String
    
    /**
     The user’s most recent position in the episode.
    
     Non-`nil` only if the application has been authorized for the
     `userReadPlaybackPosition` scope.
     */
    public let resumePoint: ResumePoint?
    
    /// The episode length in milliseconds.
    public let durationMS: Int

    /// Whether or not the episode has explicit content. `false` if unknown.
    public let isExplicit: Bool

    /// The date the episode was first released.
    ///
    /// See also `releaseDatePrecision`.
    public let releaseDate: Date?
    
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
    
    /**
     A link to the Spotify web API endpoint providing the full episode object.
     
     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in `Episode` as the
     response type to retrieve the results.
     */
    public let href: URL
       
    /// `true` if the episode is playable in the given market. Else, `false`.
    public let isPlayable: Bool

    /**
     Known [external urls][1] for this episode.

     - key: The type of the URL, for example: "spotify" - The [Spotify URL][2]
           for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/reference/#object-externalurlobject
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
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
    
    /// The precision with which `releaseDate` is known: "year", "month", or
    /// "day".
    public let releaseDatePrecision: String?
 
    /// The object type. Always `episode`.
    public let type: IDCategory
 
    /**
     Creates a Spotify [podcast episode][1].
     
     - Parameters:
       - name: The name of the episode.
       - show: The show on which the episode belongs.
       - audioPreviewURL: A URL to a 30 second preview (MP3 format) of the
             episode.
       - description: A description of the episode.
       - resumePoint: The user’s most recent position in the episode. Set if the
             supplied access token is a user token and has the
             `userReadPlaybackPosition` scope.
       - durationMS: The episode length in milliseconds.
       - isExplicit: Whether or not the episode has explicit content.
       - releaseDate: The date the episode was first released.
       - uri: The [Spotify URI][2] for the episode.
       - id: The [Spotify ID][2] for the episode.
       - images: The cover art for the episode in various sizes.
       - href: A link to the Spotify web API endpoint providing the full episode
             object.
       - isPlayable: `true` if the episode is playable in the given market.
            Else, `false`.
       - externalURLs: Known [external urls][3] for this artist.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][2] for the object.
             - value: An external, public URL to the object.
       - isExternallyHosted: `true` if the episode is hosted outside of
             Spotify's CDN (content delivery network). Else, `false`.
       - languages: A list of the languages used in the episode, identified by
             their [ISO 639][4] code.
       - releaseDatePrecision: The precision with which `releaseDate` is known:
             "year", "month", or "day".
     
     [1]:https://developer.spotify.com/documentation/web-api/reference/#object-episodeobject
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     [3]: https://developer.spotify.com/documentation/web-api/reference/#object-externalurlobject
     [4]: https://en.wikipedia.org/wiki/ISO_639
     */
    public init(
        name: String,
        show: Show? = nil,
        audioPreviewURL: URL? = nil,
        description: String,
        resumePoint: ResumePoint? = nil,
        durationMS: Int,
        isExplicit: Bool,
        releaseDate: Date? = nil,
        uri: String,
        id: String,
        images: [SpotifyImage]? = nil,
        href: URL,
        isPlayable: Bool,
        externalURLs: [String: URL]? = nil,
        isExternallyHosted: Bool,
        languages: [String],
        releaseDatePrecision: String? = nil
    ) {
        self.name = name
        self.show = show
        self.audioPreviewURL = audioPreviewURL
        self.description = description
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
    }

}

extension Episode: Codable {
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(
            String.self, forKey: .name
        )
        self.show = try container.decodeIfPresent(
            Show.self, forKey: .show
        )
        self.audioPreviewURL = try container.decodeIfPresent(
            URL.self, forKey: .audioPreviewURL
        )
        self.description = try container.decode(
            String.self, forKey: .description
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
        
        // MARK: Decode Release Date
        // this is the only property that needs to be decoded in a custom manner
        self.releaseDate = try container.decodeSpotifyDateIfPresent(
            forKey: .releaseDate
        )
        
        self.releaseDatePrecision = try container.decodeIfPresent(
            String.self, forKey: .releaseDatePrecision
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
        
        self.href = try container.decode(
            URL.self, forKey: .href
        )
        self.isPlayable = try container.decode(
            Bool.self, forKey: .isPlayable
        )
        self.externalURLs = try container.decodeIfPresent(
            [String: URL].self, forKey: .externalURLs
        )
        self.isExternallyHosted = try container.decode(
            Bool.self, forKey: .isExternallyHosted
        )
        self.languages = try container.decode(
            [String].self, forKey: .languages
        )
        self.type = try container.decode(
            IDCategory.self, forKey: .type
        )
        
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(
            self.name, forKey: .name
        )
        try container.encodeIfPresent(
            self.show, forKey: .show
        )
        try container.encodeIfPresent(
            self.audioPreviewURL, forKey: .audioPreviewURL
        )
        try container.encode(
            self.description, forKey: .description
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
            self.href, forKey: .href
        )
        
        try container.encode(
            self.isPlayable, forKey: .isPlayable
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
        
        try container.encode(
            self.type, forKey: .type
        )
       
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case show
        case audioPreviewURL = "audio_preview_url"
        case description
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
        case type
        
    }
    
}

extension Episode: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
     `Episode.releaseDate` is compared using `timeIntervalSince1970`, so it
     is considered a floating point property for the purposes of this method.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
        
        return self.name == other.name &&
                self.show == other.show &&
                self.audioPreviewURL == other.audioPreviewURL &&
                self.description == other.description &&
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
                self.releaseDate.isApproximatelyEqual(to: other.releaseDate) &&
                self.show.isApproximatelyEqual(to: other.show)
        
    }

}
