import Foundation
import SpotifyWebAPI

public extension Show {
    
    /// Sample data for testing purposes.
    static let seanCarroll = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Sean Carroll - Show", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let samHarris = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Sam Harris - Show", type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let joeRogan = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Joe Rogan - Show", type: Self.self
    )!

}
