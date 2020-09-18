import Foundation

/**
 A Spotify [category][1] object.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/browse/get-category/#categoryobject
 */
public struct SpotifyCategory: Codable, Hashable {

    /// The name of the category.
    public let name: String
    
    /// The [Spotify category ID][1] of the category.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    public let id: String
    
    /**
     A link to the Spotify web API endpoint providing the
     full category object.
     
     Use `SpotifyAPI.getFromHref(_:responseType:)`, passing in
     `SpotifyCategory` as the response type to retrieve the results.
     */
    public let href: String

    /// The category icon, in various sizes.
    public let icons: [SpotifyImage]

}
