import Foundation
import SpotifyWebAPI

public extension AudioFeatures {
    
    /// Sample data for testing purposes.
    static let fearless = Bundle.module.decodeJSON(
        forResource: "Fearless - AudioFeatures", type: Self.self
    )!

}
