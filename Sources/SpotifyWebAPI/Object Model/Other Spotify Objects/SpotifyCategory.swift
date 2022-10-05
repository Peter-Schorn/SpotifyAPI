import Foundation

/// A Spotify category object.
public struct SpotifyCategory: Codable, Hashable {
    
    /// The name of the category.
    public let name: String
    
    /// The id of the category.
    public let id: String
    
    /**
     A link to the Spotify web API endpoint providing the full category object.

     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in
     ``SpotifyCategory`` as the response type to retrieve the results.
     */
    public let href: URL

    /// The category icon, in various sizes.
    public let icons: [SpotifyImage]

    /**
     Creates a Spotify category object.
     
     - Parameters:
       - name: The name of the category.
       - id: The id of the category.
       - href: A link to the Spotify web API endpoint providing the full
             category object.
       - icons: The category icon, in various sizes.
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
