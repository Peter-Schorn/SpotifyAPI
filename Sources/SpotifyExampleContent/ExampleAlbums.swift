import Foundation
import SpotifyWebAPI

extension Album {
    
    /// Sample data for testing purposes.
    public static let abbeyRoad = Bundle.module.decodeJSON(
        forResource: "Abbey Road - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    public static let darkSideOfTheMoon = Bundle.module.decodeJSON(
        forResource: "Dark Side Of The Moon - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    public static let inRainbows = Bundle.module.decodeJSON(
        forResource: "In Rainbows - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    public static let jinx = Bundle.module.decodeJSON(
        forResource: "Jinx - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    public static let meddle = Bundle.module.decodeJSON(
        forResource: "Meddle - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    public static let skiptracing = Bundle.module.decodeJSON(
        forResource: "Skiptracing - Album", type: Self.self
    )!
    
}
