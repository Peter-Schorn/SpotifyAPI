import Foundation

/// A Spotify copyright object.
public struct SpotifyCopyright: Codable, Hashable {
    
    /// The copyright text.
    public let text: String
    
    /// The type of copyright.
    /// 
    /// C = the copyright; P = the sound recording (performance) copyright.
    public let type: String

    /**
     Creates a Spotify copyright object.
     
     - Parameters:
       - text: The copyright text.
       - type: The type of copyright: C = the copyright; P = the sound recording
             (performance) copyright.
     */
    public init(text: String, type: String) {
        self.text = text
        self.type = type
    }

}

