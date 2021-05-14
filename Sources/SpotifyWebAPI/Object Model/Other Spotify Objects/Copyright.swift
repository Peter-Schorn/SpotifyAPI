import Foundation

/// A Spotify [copyright object][1].
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/#object-copyrightobject
public struct SpotifyCopyright: Codable, Hashable {
    
    /// The copyright text for this album.
    public let text: String
    
    /// The type of copyright.
    /// 
    /// C = the copyright; P = the sound recording (performance) copyright.
    public let type: String

    /**
     Creates a Spotify [copyright object][1].
     
     - Parameters:
       - text: The copyright text for this album.
       - type: The type of copyright: C = the copyright; P = the sound recording
             (performance) copyright.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#object-copyrightobject
     */
    public init(text: String, type: String) {
        self.text = text
        self.type = type
    }

}

