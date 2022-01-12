import Foundation


/**
 An array of simplified album objects wrapped in a paging object and a localized
 message that can be displayed to the user, such as "Good Morning", or
 "Editors's picks".
 
 Returned by the endpoint for a [list of new album releases][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-new-releases
 */
public struct NewAlbumReleases: Codable, Hashable {
    
    /// A localized message that can be displayed to the user, such as "Good
    /// Morning", or "Editors's picks".
    public let message: String?
    
    /// The new album releases.
    public let albums: PagingObject<Album>
    
    /**
     Creates a New Album Releases object.
     
     An array of simplified album objects wrapped in a paging object and a
     localized message that can be displayed to the user, such as "Good
     Morning", or "Editors's picks".
     
     Returned by the endpoint for a [list of new album releases][1].

     - Parameters:
       - message: A localized message that can be displayed to the user, such as
             "Good Morning", or "Editors's picks"
       - albums: The new album releases.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-new-releases
     */
    public init(
        message: String? = nil,
        albums: PagingObject<Album>
    ) {
        self.message = message
        self.albums = albums
    }

}

extension NewAlbumReleases: ApproximatelyEquatable {
    
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
     
        return self.message == other.message &&
                self.albums.isApproximatelyEqual(to: other.albums)

    }

}
