import Foundation
import SpotifyWebAPI

public extension CursorPagingObject where Item == PlayHistory {
    
    /// Sample data for testing purposes.
    static let recentlyPlayed = Bundle.module.decodeJson(
        forResource: "Recently Played - CursorPagingObject<PlayHistory>",
        type: Self.self
    )!
}

public extension CurrentlyPlayingContext {
    
    /// Sample data for testing purposes.
    static let currentPlayback = Bundle.module.decodeJson(
        forResource: "Current Playback - CurrentlyPlayingContext",
        type: Self.self
    )!

}
