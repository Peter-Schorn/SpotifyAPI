import Foundation

/**
 This is a generic object used to represent various time intervals
 within Audio Analysis. For information about Bars, Beats, Tatums, Sections,
 and Segments are determined, please see [Rhythm][1].
 
 Read more at the [Spotify web API reference][1].
 
 [2]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#rhythm
 [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#time-interval-object
 */
public struct SpotifyTimeInterval: Codable, Hashable {
    
    /// The starting point (in seconds) of the time interval.
    public let start: Double
    
    /// The duration (in seconds) of the time interval.
    public let duration: Double
    
    /// The confidence, from 0.0 to 1.0, of the reliability of the interval.
    public let confidence: Double
}
