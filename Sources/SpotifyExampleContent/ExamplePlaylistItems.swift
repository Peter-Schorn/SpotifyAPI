import Foundation
import SpotifyWebAPI

public extension PlaylistItem {
    
    /// Sample data for testing purposes.
    static let samHarris216 = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "#216 — September 3, 2020 - PlaylistItem",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let samHarris217 = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "#217 — The New Religion of Anti-Racism - PlaylistItem",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let joeRogan1536 = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "#1536 - Edward Snowden - PlaylistItem",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let joeRogan1537 = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "#1537 - Lex Fridman - PlaylistItem",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let oceanBloom = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Hans Zimmer & Radiohead - Ocean Bloom (full song HQ) - PlaylistItem",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let echoesAcousticVersion = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Echoes - Acoustic Version - PlaylistItem",
        type: Self.self
    )!

    /// Sample data for testing purposes.
    static let killshot = Bundle.spotifyExampleContentModule.decodeJson(
        forResource: "Killshot - PlaylistItem",
        type: Self.self
    )!
    
}
