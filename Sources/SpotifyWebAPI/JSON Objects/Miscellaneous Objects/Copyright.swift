import Foundation

/// A Spotify [copyright object][1].
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#copyright-object
public struct SpotifyCopyright: CustomCodable, Hashable {
    
    /// The copyright text for this album.
    public let text: String
    
    /// The type of copyright:
    /// C = the copyright;
    /// P = the sound recording (performance) copyright.
    public let type: String

}

