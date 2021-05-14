import Foundation

/**
 A Spotify [category][1] object.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/#object-categoryobject
 */
public struct SpotifyCategory: Codable, Hashable {
    
    /// The name of the category.
    public let name: String
    
    /// The [Spotify category ID][1] of the category.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /**
     A link to the Spotify web API endpoint providing the full category object.

     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in `SpotifyCategory`
     as the response type to retrieve the results.
     */
    public let href: URL

    /// The category icon, in various sizes.
    public let icons: [SpotifyImage]

    /**
     Creates a Spotify [category][1] object.
     
     - Parameters:
       - name: The name of the category.
       - id: The [ID][2] of the category.
       - href: A link to the Spotify web API endpoint providing the full
             category object.
       - icons: The category icon, in various sizes.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#object-categoryobject
     [2]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    public init(
        name: String,
        id: String,
        href: URL,
        icons: [SpotifyImage]
    ) {
        self.name = name
        self.id = id
        self.href = href
        self.icons = icons
    }

}
