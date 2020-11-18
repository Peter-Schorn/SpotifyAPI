import Foundation

/// The repeat mode of the user's player.
/// Either `off`, `track`, or `context`.
public enum RepeatMode: String, Codable, Hashable, CaseIterable {
    
    /// Repeat mode is off.
    case off
    
    /// The current track is playing on repeat.
    case track
    
    /// The current context, such as a playlist, is playing on repeat.
    case context
    
}
