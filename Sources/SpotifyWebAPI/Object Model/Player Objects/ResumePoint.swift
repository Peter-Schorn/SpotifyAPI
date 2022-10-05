import Foundation

/**
 A Spotify resume point object. Represents the user’s most recent position
 in an episode or audiobook chapter.
 
 Retrieving this object requires the ``Scope/userReadPlaybackPosition`` scope.

 */
public struct ResumePoint: Codable, Hashable {
    
    /// Whether or not the content has been fully played by the user.
    public let fullyPlayed: Bool
    
    /// The user's most recent position in the content in milliseconds.
    public let resumePositionMS: Int

    /**
     Creates a resume point object.
     
     Represents the user’s most recent position in an episode or audiobook
     chapter.
     
     - Parameters:
       - fullyPlayed: Whether or not the content has been fully played by the
             user.
       - resumePositionMS: The user's most recent position in the content in
             milliseconds.
     */
    public init(fullyPlayed: Bool, resumePositionMS: Int) {
        self.fullyPlayed = fullyPlayed
        self.resumePositionMS = resumePositionMS
    }
    
    private enum CodingKeys: String, CodingKey {
        case fullyPlayed = "fully_played"
        case resumePositionMS = "resume_position_ms"
    }
    
}
