import Foundation
import SpotifyWebAPI

public extension Album {
    
    /// Sample data for testing purposes.
    static let abbeyRoad = Bundle.module.decodeJSON(
        forResource: "Abbey Road - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let darkSideOfTheMoon = Bundle.module.decodeJSON(
        forResource: "Dark Side Of The Moon - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let inRainbows = Bundle.module.decodeJSON(
        forResource: "In Rainbows - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let jinx = Bundle.module.decodeJSON(
        forResource: "Jinx - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let meddle = Bundle.module.decodeJSON(
        forResource: "Meddle - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let skiptracing = Bundle.module.decodeJSON(
        forResource: "Skiptracing - Album", type: Self.self
    )!
    
}
