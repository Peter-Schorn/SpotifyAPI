import Foundation

/// A Time Range. Used by the
/// ``SpotifyAPI/currentUserTopArtists(_:offset:limit:)`` and
/// ``SpotifyAPI/currentUserTopTracks(_:offset:limit:)`` methods.
public enum TimeRange: String, Codable, Hashable, CaseIterable {
    
    /// Long term.
    case longTerm = "long_term"
    
    /// Medium term.
    case mediumTerm = "medium_term"
    
    /// Short term.
    case shortTerm = "short_term"

}
