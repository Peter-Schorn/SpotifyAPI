import Foundation

/// A Spotify [image object][1].
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#image-object
public struct SpotifyImage: Codable, Hashable {
    
    /// The image height in pixels. If unknown: null or not returned.
    public let height: Int?
    /// The image width in pixels. If unknown: null or not returned.
    public let width: Int?
    
    /// The source URL of the image.
    ///
    /// - Warning: If this image belongs to a playlist,
    ///   then this url is temporary and will expire in less
    ///   than a day.
    public let url: String

}
