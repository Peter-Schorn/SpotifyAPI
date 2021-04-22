import Foundation
import SpotifyWebAPI

public extension Episode {
    
    /// Sample data for testing purposes.
    static let seanCarroll111 = Bundle.module.decodeJSON(
        forResource: "Sean Carroll 111 - Episode", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let seanCarroll112 = Bundle.module.decodeJSON(
        forResource: "Sean Carroll 112 - Episode", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let samHarris213 = Bundle.module.decodeJSON(
        forResource: "Sam Harris 213 - Episode", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let samHarris214 = Bundle.module.decodeJSON(
        forResource: "Sam Harris 214 - Episode", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let samHarris215 = Bundle.module.decodeJSON(
        forResource: "Sam Harris 215 - Episode", type: Self.self
    )!

}
