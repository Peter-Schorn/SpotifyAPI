import Foundation
import SpotifyWebAPI

public extension Album {
    
    /// Sample data for testing purposes.
    static let abbeyRoad = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Abbey Road - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let darkSideOfTheMoon = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Dark Side Of The Moon - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let inRainbows = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "In Rainbows - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let jinx = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Jinx - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let meddle = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Meddle - Album", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let skiptracing = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Skiptracing - Album", type: Self.self
    )!
    
}
