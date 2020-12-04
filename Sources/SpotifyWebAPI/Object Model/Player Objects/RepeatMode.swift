import Foundation

/// The repeat mode of the user's player.
/// Either `off`, `track`, or `context`.
public enum RepeatMode: String, Codable, Hashable, CaseIterable {
    
    /// Repeat mode is off.
    case off
    
    /// The current context, such as a playlist, is playing on repeat.
    case context

    /// The current track is playing on repeat.
    case track
    
}

public extension RepeatMode {
    
    /**
     Cycles self between the repeat modes.
     
     If the repeat mode is `off`, then it becomes `context`;
     if the repeat mode is `context`, then it becomes `track`;
     if the repeat mode is `track`, then it becomes `off`.
     */
    mutating func cycle() {
        if self == .off {
            self = .context
        }
        else if self == .context {
            self = .track
        }
        else if self == .track {
            self = .off
        }
    }
    
}
