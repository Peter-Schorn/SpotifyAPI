import Foundation
import SwiftUI
import Combine

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
#else
import UIKit
typealias PlatformImage = UIImage
#endif


/// A Spotify [image object][1].
///
/// Includes the URL to the image and its height and width.
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#image-object
public struct SpotifyImage: Codable, Hashable {
    
    /// The image height in pixels.
    /// May be `nil`, especially if uploaded by the user.
    public let height: Int?
    /// The image width in pixels.
    /// May be `nil`, especially if uploaded by the user.
    public let width: Int?
    
    /// The source URL of the image.
    ///
    /// - Warning: If this image belongs to a playlist,
    ///   then this it is temporary and will expire in less
    ///   than a day.
    public let url: String

    public init(height: Int?, width: Int?, url: String) {
        self.height = height
        self.width = width
        self.url = url
    }
    
}

public extension SpotifyImage {
    
    /// Loads the image from `url`.
    /// Throws if the URL cannot be converted to
    /// `URL` or the data cannot be converted to `Image`.
    func load() -> AnyPublisher<Image, Error> {
        
        guard let imageURL = URL(string: url) else {
            return SpotifyLocalError.other(
                "couldn't convert string to url: '\(url)'"
            )
            .anyFailingPublisher(Image.self)
            
        }
        
        return URLSession.shared.dataTaskPublisher(for: imageURL)
            .tryMap { data, response -> Image in
                guard let image = PlatformImage(data: data).map({
                    image -> Image in
                    
                    #if os(macOS)
                    return Image(nsImage: image)
                    #else
                    return Image(uiImage: image)
                    #endif
                })
                else {
                    throw SpotifyLocalError.other(
                        "couldn't get image from data"
                    )
                }
                return image
            }
            .eraseToAnyPublisher()
        
    }
    
}

public extension Sequence where Element == SpotifyImage {
    
    /// Returns the largest image in this sequence
    /// of `SpotifyImage`, or `nil` if the sequence is empty.
    ///
    /// When determining the largest image, Images with
    /// `nil` for `height` and/or `width` are considered
    /// to have a `height` and/or `width` of 0.
    /// The largest image is calculated based on `height` * `width`.
    var largest: SpotifyImage? {
        
        // areInIncreasingOrder
        // A predicate that returns true if its first argument should
        // be ordered before its second argument; otherwise, false.
        return self.max(by: { lhs, rhs in
            (lhs.width ?? 0) * (lhs.height ?? 0) <
            (rhs.width ?? 0) * (rhs.height ?? 0)
        })
        
    }
    
}
