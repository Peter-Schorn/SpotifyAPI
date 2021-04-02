import Foundation
import SpotifyWebAPI

public extension SpotifyUser {
    
    /// Sample data for testing purposes.
    static let sampleCurrentUserProfile = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Current User Profile - SpotifyUser",
        type: Self.self
    )!

}
