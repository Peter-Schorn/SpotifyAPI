import Foundation

/**
 This is a generic object used to represent various time intervals within Audio
 Analysis. For information about how Bars, Beats, Tatums, Sections, and Segments
 are determined, please see [Rhythm][1].
 
 Read more at the [Spotify web API reference][2].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#rhythm
 [2]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#time-interval-object
 */
public struct SpotifyTimeInterval: Codable, Hashable {
    
    /// The starting point (in seconds) of the time interval.
    public let start: Double
    
    /// The duration (in seconds) of the time interval.
    public let duration: Double
    
    /// The confidence, from 0.0 to 1.0, of the reliability of the interval.
    public let confidence: Double
    
    /**
     Creates a Spotify Time Interval.
     
     This is a generic object used to represent various time intervals within
     Audio Analysis. For information about Bars, Beats, Tatums, Sections, and
     Segments are determined, please see [Rhythm][2].
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - start: The starting point (in seconds) of the time interval.
       - duration: The duration (in seconds) of the time interval.
       - confidence: The confidence, from 0.0 to 1.0, of the reliability of the
             interval.

     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#time-interval-object
     [2]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#rhythm
     */
    public init(
        start: Double,
        duration: Double,
        confidence: Double
    ) {
        self.start = start
        self.duration = duration
        self.confidence = confidence
    }

}

extension SpotifyTimeInterval: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the properties of `self` are approximately equal to
     those of `other` within an absolute tolerance of 0.001. Else, returns
     `false`.

     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
        if !self.start.isApproximatelyEqual(
            to: other.start, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.duration.isApproximatelyEqual(
            to: other.duration, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.confidence.isApproximatelyEqual(
            to: other.confidence, absoluteTolerance: 0.001
        ) {
            return false
        }
        return true
    }

}
