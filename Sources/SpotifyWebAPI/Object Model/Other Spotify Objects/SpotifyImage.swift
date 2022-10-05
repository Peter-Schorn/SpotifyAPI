#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

#if canImport(AppKit)
import AppKit
/// `NSImage` on macOS; else, `UIImage`.
typealias PlatformImage = NSImage
#elseif canImport(UIKit)
import UIKit
/// `NSImage` on macOS; else, `UIImage`.
typealias PlatformImage = UIImage
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation


/**
 A Spotify image object.

 Includes the URL to the image and its height and width.
 
  - Warning: If this image belongs to a playlist, then the URL is temporary and
         will expire in less than a day. Use ``SpotifyAPI/playlistImage(_:)`` to
         retrieve the image for a playlist.
 */
public struct SpotifyImage: Codable, Hashable {
    
    /// The image height in pixels.
    ///
    /// May be `nil`, especially if uploaded by a user.
    public let height: Int?
    
    /// The image width in pixels.
    ///
    /// May be `nil`, especially if uploaded by a user.
    public let width: Int?
    
    /**
     The source URL of the image.
     
     Consider using ``load()`` to load the image from this URL into
     `SwiftUI.Image`.
     
     - Warning: If this image belongs to a playlist, then it is temporary and
           will expire in less than a day. Use ``SpotifyAPI/playlistImage(_:)``
           to retrieve the image for a playlist.
     */
    public let url: URL

    /**
     Creates a Spotify image object.
     
     - Parameters:
       - height: The image height in pixels.
       - width: The image width in pixels.
       - url: The source URL of the image.
     */
    public init(
        height: Int? = nil,
        width: Int? = nil,
        url: URL
    ) {
        self.height = height
        self.width = width
        self.url = url
    }

}

public extension SpotifyImage {
    
    #if (canImport(AppKit) || canImport(UIKit)) && canImport(SwiftUI) && !targetEnvironment(macCatalyst)
    /**
     Loads the image from ``url``.
     
     This method will **always** use `URLSessionDataTask`. If you want to use
     your own network client, then do so directly by making a GET request to
     ``url``.
     
     - Warning: If this image belongs to a playlist, then it is temporary and
           will expire in less than a day. Use ``SpotifyAPI/playlistImage(_:)``
           to retrieve the image for a playlist.

     - Throws: If the data cannot be converted to `Image`, or if some other
           network error occurs.
     */
    func load() -> AnyPublisher<Image, Error> {

        let publisher = URLSession.shared.dataTaskPublisher(
            for: self.url
        )

        return publisher
            .tryMap { data, response -> Image in

                if let image = PlatformImage(data: data).map({
                    image -> Image in
                  
                    #if canImport(AppKit)
                    return Image(nsImage: image)
                    #elseif canImport(UIKit)
                    return Image(uiImage: image)
                    #endif
                }) {
                    return image
                }
                throw SpotifyGeneralError.other(
                    "couldn't convert data to image"
                )

            }
            .eraseToAnyPublisher()
        
    }
    #endif
    
}

public extension Sequence where Element == SpotifyImage {
    
    /**
     Returns the largest image in this sequence of ``SpotifyImage``, or `nil` if
     the sequence is empty.
    
     When determining the largest image, Images with `nil` for
     ``SpotifyImage/height`` and/or ``SpotifyImage/width`` are considered to
     have a ``SpotifyImage/height`` and/or ``SpotifyImage/width`` of 0.
     
     The largest image is calculated based on ``SpotifyImage/height`` *
     ``SpotifyImage/width``.
     */
    var largest: SpotifyImage? {
        
        // areInIncreasingOrder
        // A predicate that returns true if its first argument should
        // be ordered before its second argument; otherwise, false.
        return self.max(by: { (lhs: SpotifyImage, rhs: SpotifyImage) -> Bool in
            let lhsDimensions = (lhs.width ?? 0) * (lhs.height ?? 0)
            let rhsDimensions = (rhs.width ?? 0) * (rhs.height ?? 0)
            return lhsDimensions < rhsDimensions
        })
        
    }
    
}
