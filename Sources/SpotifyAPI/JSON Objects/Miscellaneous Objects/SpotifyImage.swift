import Foundation

/// A Spotify [image object][1].
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#image-object
public struct SpotifyImage: CustomCodable, Hashable {
    
    /// The image height in pixels. If unknown: null or not returned.
    public let height: Int?
    /// The image width in pixels. If unknown: null or not returned.
    public let width: Int?
    /// The source URL of the image.
    public let url: String

}
