import Foundation
import SpotifyWebAPI

public extension Album {
    
    /// Sample data for testing purposes.
    static let abbeyRoad = Bundle.module.decodeJson(
        forResource: "Abbey Road - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let darkSideOfTheMoon = Bundle.module.decodeJson(
        forResource: "Dark Side Of The Moon - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let inRainbows = Bundle.module.decodeJson(
        forResource: "In Rainbows - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let jinx = Bundle.module.decodeJson(
        forResource: "Jinx - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let meddle = Bundle.module.decodeJson(
        forResource: "Meddle - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let skiptracing = Bundle.module.decodeJson(
        forResource: "Skiptracing - Album", type: Self.self
    )!
    
}
