import Foundation
import SpotifyWebAPI

public extension Show {
    
    /// Sample data for testing purposes.
    static let seanCarroll = Bundle.module.decodeJson(
        forResource: "Sean Carroll - Show", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let samHarris = Bundle.module.decodeJson(
        forResource: "Sam Harris - Show", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let joeRogan = Bundle.module.decodeJson(
        forResource: "Joe Rogan - Show", type: Self.self
    )!

}
