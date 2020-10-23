import Foundation
import SpotifyWebAPI

public extension CursorPagingObject where Item == PlayHistory {
    
    /// Sample data for testing purposes.
    static let sampleRecentlyPlayed = Bundle.module.decodeJson(
        forResource: "Recently Played - CursorPagingObject<PlayHistory>",
        type: Self.self
    )!
}

public extension CurrentlyPlayingContext {
    
    /// Sample data for testing purposes.
    static let sampleCurrentPlayback = Bundle.module.decodeJson(
        forResource: "Current Playback - CurrentlyPlayingContext",
        type: Self.self
    )!

}
