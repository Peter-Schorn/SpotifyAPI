import Foundation
import SpotifyWebAPI

public extension Artist {
    
    /// Sample data for testing purposes.
    static let crumb = Bundle.module.decodeJson(
        forResource: "Crumb - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let levitationRoom = Bundle.module.decodeJson(
        forResource: "Levitation Room - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let pinkFloyd = Bundle.module.decodeJson(
        forResource: "Pink Floyd - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let radiohead = Bundle.module.decodeJson(
        forResource: "Radiohead - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let skinshape = Bundle.module.decodeJson(
        forResource: "Skinshape - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let theBeatles = Bundle.module.decodeJson(
        forResource: "The Beatles - Artist", type: Self.self
    )!
     
}
