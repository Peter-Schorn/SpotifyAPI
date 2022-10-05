import Foundation

/**
 A Spotify user.
 
 Can represent both the public and private version. When the public version is
 returned, properties that are only available in the private version will be
 `nil`.
 */
public struct SpotifyUser: SpotifyURIConvertible, Hashable {
    
    /// The name displayed on the user’s profile.
    public let displayName: String?

    /// The [Spotify URI][1] for this user.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String
    
    /// The [Spotify user ID][1] for this user.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /// The user's profile image in various sizes.
    public let images: [SpotifyImage]?
    
    /**
     A link to the Spotify web API endpoint for this user.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``SpotifyUser``
     as the response type to retrieve the results.
     */
    public let href: URL

    /**
     When `true`, indicates that explicit content *is* allowed. If `false`, then
     explicit content should *not* be played because the user has disabled it in
     their settings.

     This property is only available for the *current* user and requires the
     ``Scope/userReadPrivate`` scope. Otherwise, it will be `nil`.
     */
    public let allowsExplicitContent: Bool?
    
    /**
     When `true`, indicates that the explicit content setting is locked and
     can’t be changed by the user.
     
     For example, this user may be associated with a kids account that has
     content restrictions on it (e.g., parental controls).

     This property is only available for the *current* user and requires the
     ``Scope/userReadPrivate`` scope. Otherwise, it will be `nil`.
     */
    public let explicitContentSettingIsLocked: Bool?

    /// Information about the followers of this user.
    public let followers: Followers?
    
    /**
     The country of the user, as set in the user’s account profile. An ISO
     3166-1 alpha-2 country code.
    
     Read about [ISO 3166-1 alpha-2 codes][1].

     This property is only available for the *current* user and requires the
     ``Scope/userReadPrivate`` scope. Otherwise, it will be `nil`.
     
     [1]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    public let country: String?
    
    /**
     The user’s email address, as entered by the user when creating their
     account.
     
     This property is only available for the *current* user and requires the
     ``Scope/userReadEmail`` scope. Otherwise, it will be `nil`.
     
     - Warning: This email address is unverified; there is no proof that it
           actually belongs to the user.
     */
    public let email: String?
    
    /**
     The user’s Spotify subscription level: "premium", "free", etc. (The
     subscription level "open" can be considered the same as "free".)
     
     This property is only available for the *current* user and requires the
     ``Scope/userReadPrivate`` scope. Otherwise, it will be `nil`.
     */
    public let product: String?
    
    /**
    Known external urls for this user.

    - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
          for the object.
    - value: An external, public URL to the object.

    [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    */
    public let externalURLs: [String: URL]?
    
    /// The object type. Always ``IDCategory/user``.
    public let type: IDCategory
    
    /**
     Creates a Spotify user.
     
     - Parameters:
       - displayName: The name displayed on the user’s profile.
       - uri: The [Spotify URI][1] for this user.
       - id: The [Spotify user ID][1] for this user.
       - images: The user's profile image in various sizes.
       - href: A link to the Spotify web API endpoint for this user.
       - allowsExplicitContent:  When `true`, indicates that explicit content
             *is* allowed. If `false`, then explicit content should *not* be
             played because the user has disabled it in their settings. This
             property is only available for the *current* user and requires the
             ``Scope/userReadPrivate`` scope. Otherwise, it will be `nil`.
       - explicitContentSettingIsLocked: When `true`, indicates that the
             explicit content setting is locked and can’t be changed by the
             user. For example, this user may be associated with a kids account
             that has content restrictions on it (e.g., parental controls). This
             property is only available for the *current* user and requires the
             ``Scope/userReadPrivate`` scope. Otherwise, it will be `nil`.
       - followers: Information about the followers of this user.
       - country: The country of the user, as set in the user’s account profile.
             An [ISO 3166-1 alpha-2 country code][2]. This property is only
             available for the *current* user and requires the
             ``Scope/userReadPrivate`` scope. Otherwise, it will be `nil`.
       - email: The user’s email address, as entered by the user when creating
             their account. This property is only available for the *current*
             user and requires the ``Scope/userReadEmail`` scope. Otherwise, it
             will be `nil`.
       - product:  The user’s Spotify subscription level: "premium", "free",
             etc. (The subscription level "open" can be considered the same as
             "free".) This property is only available for the *current* user and
             requires the ``Scope/userReadPrivate`` scope. Otherwise, it will be
             `nil`.
       - externalURLs: Known external urls for this artist.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][1] for the object.
             - value: An external, public URL to the object.
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    public init(
        displayName: String? = nil,
        uri: String,
        id: String,
        images: [SpotifyImage]? = nil,
        href: URL,
        allowsExplicitContent: Bool? = nil,
        explicitContentSettingIsLocked: Bool? = nil,
        followers: Followers? = nil,
        country: String? = nil,
        email: String? = nil,
        product: String? = nil,
        externalURLs: [String: URL]? = nil
    ) {
        self.displayName = displayName
        self.uri = uri
        self.id = id
        self.images = images
        self.href = href
        self.allowsExplicitContent = allowsExplicitContent
        self.explicitContentSettingIsLocked = explicitContentSettingIsLocked
        self.followers = followers
        self.country = country
        self.email = email
        self.product = product
        self.externalURLs = externalURLs
        self.type = .user
        
    }
    
}

extension SpotifyUser: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.displayName = try container.decodeIfPresent(
            String.self, forKey: .displayName
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
        
        // The user’s explicit content settings are only available when
        // the current user has granted access to the user-read-private
        // scope.
        if try container.contains(.explicitContent) &&
                // ensure the value is non-null
                !container.decodeNil(forKey: .explicitContent) {

            
            let explicitContentContainer = try container.nestedContainer(
                keyedBy: CodingKeys.ExplicitContent.self,
                forKey: .explicitContent
            )

            let disallowsExplicitContent = try explicitContentContainer.decode(
                Bool.self,
                forKey: .disallowsExplicitContent
            )
            self.allowsExplicitContent = !disallowsExplicitContent
            
            self.explicitContentSettingIsLocked = try explicitContentContainer.decode(
                Bool.self,
                forKey: .explicitContentSettingIsLocked
            )

        }
        else {
            self.allowsExplicitContent = nil
            self.explicitContentSettingIsLocked = nil
        }

        self.followers = try container.decodeIfPresent(
            Followers.self, forKey: .followers
        )
        self.country = try container.decodeIfPresent(
            String.self, forKey: .country
        )
        self.email = try container.decodeIfPresent(
            String.self, forKey: .email
        )
        self.product = try container.decodeIfPresent(
            String.self, forKey: .product
        )
        self.externalURLs = try container.decodeIfPresent(
            [String: URL].self, forKey: .externalURLs
        )
        self.type = try container.decode(
            IDCategory.self, forKey: .type
        )

    }

    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(
            self.displayName, forKey: .displayName
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
        
        /*
         The user’s explicit content settings are only available when
         the current user has granted access to the user-read-private
         scope.
        
         if `allowsExplicitContent` is non-`nil`, then
         `explicitContentSettingIsLocked` must also be non-`nil`
         based on how the data is decoded in `init(from:)`.
         */
        if let allowsExplicitContent = self.allowsExplicitContent {
            
            var explicitContentContainer = container.nestedContainer(
                keyedBy: CodingKeys.ExplicitContent.self,
                forKey: .explicitContent
            )

            let disallowsExplicitContent = !allowsExplicitContent
            try explicitContentContainer.encode(
                disallowsExplicitContent,
                forKey: .disallowsExplicitContent
            )
            
            try explicitContentContainer.encodeIfPresent(
                self.explicitContentSettingIsLocked,
                forKey: .explicitContentSettingIsLocked
            )

        }
        
        try container.encodeIfPresent(
            self.followers, forKey: .followers
        )
        try container.encodeIfPresent(
            self.country, forKey: .country
        )
        try container.encodeIfPresent(
            self.email, forKey: .email
        )
        try container.encodeIfPresent(
            self.product, forKey: .product
        )
        try container.encodeIfPresent(
            self.externalURLs, forKey: .externalURLs
        )
        try container.encode(
            self.type, forKey: .type
        )

    }

    private enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case uri
        case id
        case images
        case href
        
        case explicitContent = "explicit_content"
        
        enum ExplicitContent: String, CodingKey {
            case disallowsExplicitContent = "filter_enabled"
            case explicitContentSettingIsLocked = "filter_locked"
        }
        
        case followers
        case country
        case email
        case product
        case externalURLs = "external_urls"
        case type
    }

}
