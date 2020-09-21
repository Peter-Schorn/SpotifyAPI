import Foundation


/**
 An array of simplified album objects wrapped in a paging object
 and a localized message that can be displayed to the user, such as
 "Good Morning", or "Editors's picks".
 
 Returned by the endpoint for a [list of new album releases][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/browse/get-list-new-releases/
 */
public struct NewAlbumReleases: Codable, Hashable {
    
    /// A localized message that can be displayed to the user, such as
    /// "Good Morning", or "Editors's picks"
    public let message: String?
    
    /// The new album releases.
    public let albums: PagingObject<Album>
    
    /**
     Creates a New Album Releases object.
     
     An array of simplified album objects wrapped in a paging object
     and a localized message that can be displayed to the user, such as
     "Good Morning", or "Editors's picks".
     
     Returned by the endpoint for a [list of new album releases][1].

     - Parameters:
       - message: A localized message that can be displayed to the user,
             such as "Good Morning", or "Editors's picks"
       - albums: The new album releases.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/browse/get-list-new-releases/
     */
    public init(
        message: String? = nil,
        albums: PagingObject<Album>
    ) {
        self.message = message
        self.albums = albums
    }

}
