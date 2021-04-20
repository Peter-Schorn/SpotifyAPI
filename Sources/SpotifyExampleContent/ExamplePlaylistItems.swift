import Foundation
import SpotifyWebAPI

public extension PlaylistItem {
    
    /// Sample data for testing purposes.
    static let samHarris216 = Bundle.module.decodeJSON(
        forResource: "#216 — September 3, 2020 - PlaylistItem",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let samHarris217 = Bundle.module.decodeJSON(
        forResource: "#217 — The New Religion of Anti-Racism - PlaylistItem",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let joeRogan1536 = Bundle.module.decodeJSON(
        forResource: "#1536 - Edward Snowden - PlaylistItem",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let joeRogan1537 = Bundle.module.decodeJSON(
        forResource: "#1537 - Lex Fridman - PlaylistItem",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let oceanBloom = Bundle.module.decodeJSON(
        forResource: "Hans Zimmer & Radiohead - Ocean Bloom (full song HQ) - PlaylistItem",
        type: Self.self
    )!
    
    /// Sample data for testing purposes.
    static let echoesAcousticVersion = Bundle.module.decodeJSON(
        forResource: "Echoes - Acoustic Version - PlaylistItem",
        type: Self.self
    )!

    /// Sample data for testing purposes.
    static let killshot = Bundle.module.decodeJSON(
        forResource: "Killshot - PlaylistItem",
        type: Self.self
    )!
    
}
