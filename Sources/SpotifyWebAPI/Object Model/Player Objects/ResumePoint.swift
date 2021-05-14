import Foundation

/**
 A Spotify [resume point object][1]. Represents the user’s most recent position
 in an episode.

 Retrieving this object requires the `userReadPlaybackPosition` scope.

 [1]: https://developer.spotify.com/documentation/web-api/reference/#object-resumepointobject
 */
public struct ResumePoint: Codable, Hashable {
    
    /// Whether or not the episode has been fully played by the user.
    public let fullyPlayed: Bool
    
    /// The user's most recent position in the episode in milliseconds.
    public let resumePositionMS: Int

    /**
     Creates a [resume point object][1].
     
     - Parameters:
       - fullyPlayed: Whether or not the episode has been fully played by the
             user.
       - resumePositionMS: The user's most recent position in the episode in
             milliseconds.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#object-resumepointobject
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
