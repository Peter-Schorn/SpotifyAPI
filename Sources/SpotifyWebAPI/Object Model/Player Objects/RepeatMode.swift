import Foundation

/// The repeat mode of the user's player. Either ``off``, ``track``, or
/// ``context``.
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
     Cycles self among the between modes.
     
     If the repeat mode is ``off``, then it becomes ``context``; if the repeat
     mode is ``context``, then it becomes ``track``; if the repeat mode is
     ``track``, then it becomes ``off``.
     
     See also ``cycled()``.
     */
    mutating func cycle() {
        self = self.cycled()
    }
    
    /**
     Returns self cycled among the repeat modes.
     
     If the repeat mode is ``off``, then ``context`` is returned; if the repeat
     mode is ``context``, then ``track`` is returned; if the repeat mode is
     ``track``, then ``off`` is returned.
     
     See also ``cycle()``.
     */
    func cycled() -> Self {
        
        switch self {
            case .off:
                return .context
            case .context:
                return .track
            case .track:
                return .off
        }

    }
    
}
