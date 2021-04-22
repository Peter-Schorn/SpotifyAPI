import Foundation
import SpotifyWebAPI

public extension Artist {
    
    /// Sample data for testing purposes.
    static let crumb = Bundle.module.decodeJSON(
        forResource: "Crumb - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let levitationRoom = Bundle.module.decodeJSON(
        forResource: "Levitation Room - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let pinkFloyd = Bundle.module.decodeJSON(
        forResource: "Pink Floyd - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let radiohead = Bundle.module.decodeJSON(
        forResource: "Radiohead - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let skinshape = Bundle.module.decodeJSON(
        forResource: "Skinshape - Artist", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let theBeatles = Bundle.module.decodeJSON(
        forResource: "The Beatles - Artist", type: Self.self
    )!
     
}
