import Foundation
import SpotifyWebAPI

public extension AudioAnalysis {
    
    /// Sample data for testing purposes.
    static let anyColourYouLike = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Any Colour You Like - AudioAnalysis", type: Self.self
    )!

}
