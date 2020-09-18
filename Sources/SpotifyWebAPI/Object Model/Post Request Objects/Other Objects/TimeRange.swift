import Foundation

/// A Time Range. Used by the `currentUserTopArtists(_:offset:limit:)`
/// and `currentUserTopTracks(_:offset:limit:)` methods.
public enum TimeRange: String, Codable {
    
    /// Long term.
    case longTerm = "long_term"
    
    /// Medium term.
    case mediumTerm = "medium_term"
    
    /// Short term.
    case shortTerm = "shot_term"

}
