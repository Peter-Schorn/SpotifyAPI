import Foundation

/// The repeat mode of the user's player.
/// Either `off`, `track`, or `context`.
public enum RepeatMode: String, Codable, Hashable, CaseIterable {
    
    /// Repeat mode is off.
    case off
    
    /// The current track is playing on repeat.
    case track
    
    /**
     The current context, such as a playlist, is playing on repeat.
     
     Indicates that when the user reaches the end of the context,
     the track/episode at the beginning of the context will play again,
     and so on. If repeat mode is off, then, depending on the user's
     settings, playback may stop after the user reaches the end of the
     context or songs similar to the context may begin to play.
     */
    case context
    
}
