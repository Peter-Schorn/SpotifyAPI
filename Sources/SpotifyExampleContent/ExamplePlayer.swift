import Foundation
import SpotifyWebAPI

public extension CursorPagingObject where Item == PlayHistory {
    
    /// Sample data for testing purposes.
    static let sampleRecentlyPlayed = Bundle.module.decodeJSON(
        forResource: "Recently Played - CursorPagingObject<PlayHistory>",
        type: Self.self
    )!
}

public extension CurrentlyPlayingContext {
    
    /// Sample data for testing purposes.
    static let sampleCurrentPlayback = Bundle.module.decodeJSON(
        forResource: "Current Playback - CurrentlyPlayingContext",
        type: Self.self
    )!

}

public extension SpotifyQueue {
    
    /// Sample data for testing purposes.
    static let sampleQueue = Bundle.module.decodeJSON(
        forResource: "Queue - SpotifyQueue",
        type: Self.self
    )!

}
