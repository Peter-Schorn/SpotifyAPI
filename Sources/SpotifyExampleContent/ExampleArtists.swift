import Foundation
import SpotifyWebAPI

public extension Artist {
    
    /// Sample data for testing purposes.
    static let crumb = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Crumb - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let levitationRoom = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Levitation Room - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let pinkFloyd = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Pink Floyd - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let radiohead = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Radiohead - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let skinshape = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Skinshape - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let theBeatles = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "The Beatles - Artist", type: Self.self
    )!
     
}
