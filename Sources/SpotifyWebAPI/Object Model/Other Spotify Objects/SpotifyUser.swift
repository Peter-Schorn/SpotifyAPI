import Foundation

/**
 A [Spotify user][1].
 
 Can represent both the public and private version.
 
 https://developer.spotify.com/documentation/web-api/reference/object-model/#user-object-private
 */
public struct SpotifyUser: SpotifyURIConvertible, Codable, Hashable {
    
    /// The name displayed on the user’s profile.
    /// `nil` if not available.
    public let displayName: String?

    /// The [Spotify URI][1] for this user.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let uri: String
    
    /// The [Spotify user ID][1] for this user.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /// The user's profile image.
    public let images: [SpotifyImage]?
    
    /**
     A link to the Spotify web API endpoint for this user.
     
     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in `SpotifyUser` as the
     response type to retrieve the results.
     */
    public let href: String
    
    /// Information about the followers of this user.
    public let followers: Followers?
    
    /**
     The country of the user, as set in the user’s account profile.
     An [ISO 3166-1 alpha-2 country code][1].
    
     This field is only available when the current user
     has granted access to the `userReadPrivate` scope.
     
     [1]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    public let country: String?
    
    /**
     The user’s email address, as entered by the user when
     creating their account.
     
     This field is only available when the current user has
     granted access to the `userReadEmail` scope.
     
     - Warning: This email address is unverified; there is no proof that
     it actually belongs to the user.
     */
    public let email: String?
    
    /**
     The user’s Spotify subscription level:
     "premium", "free", etc. (The subscription level "open"
     can be considered the same as "free".)
     
     This field is only available when the current user
     has granted access to the `userReadPrivate` scope.
     */
    public let product: String?
    
    
    /**
    Known [external urls][1] for this user.

    - key: The type of the URL, for example:
          "spotify" - The [Spotify URL][2] for the object.
    - value: An external, public URL to the object.

    [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#external-url-object
    [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    */
    public let externalURLs: [String: String]?
    
    /// The object type. Always `user`.
    public let type: IDCategory
    
    public enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case uri
        case id
        case images
        case href
        case followers
        case country
        case email
        case product
        case externalURLs = "external_urls"
        case type
    }
    
}
