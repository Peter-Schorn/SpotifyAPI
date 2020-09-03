import Foundation

/**
 A [segment][1] of a track with a roughly consistent sound
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#segment-object
 */
public struct Segment: Hashable {
    
    /// The starting point (in seconds) of the segment.
    public let start: Double
    
    /// The duration (in seconds) of the segment.
    public let duration: Double
    
    /**
     The confidence, from 0.0 to 1.0, of the reliability of the segmentation.
     
     Segments of the song which are difficult to logically segment (e.g: noise)
     may correspond to low values in this field.
     */
    public let confidence: Double
    
    /**
     The onset loudness of the segment in decibels (dB).
     
     Combined with `loudnessMax` and `loudnessMaxTime`, these components
     can be used to describe the “attack” of the segment.
     */
    public let loudnessStart: Double
    
    /**
     The peak loudness of the segment in decibels (dB).
     
     Combined with `loudnessStart` and `loudnessMaxTime`, these components
     can be used to describe the “attack” of the segment.
     */
    public let loudnessMax: Double
    
    
    /**
     The segment-relative offset of the segment peak loudness in seconds.
     Combined with `loudnessStart` and `loudnessMax`, these components can
     be used to describe the “attack” of the segment.
     */
    public let loudnessMaxTime: Double
    
    /**
     A “chroma” vector representing the pitch content of the segment,
     corresponding to the 12 pitch classes C, C#, D to B, with values
     ranging from 0 to 1 that describe the relative dominance of every
     pitch in the chromatic scale. More details about how to interpret
     this vector can be found [here][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#pitch
     */
    public let pitches: [Double]
    
    /**
     Timbre is the quality of a musical note or sound that distinguishes
     different types of musical instruments, or voices. Timbre vectors are
     best used in comparison with each other. More details about how to
     interpret this vector can be found [here][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#timbre
     */
    public let timbre: [Double]
    
    /// The offset loudness of the segment in decibels (dB).
    ///
    /// This value should be equivalent to the `loudnessStart` of the
    /// following segment.
    public let loudnessEnd: Double?

}

extension Segment: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case start
        case duration
        case confidence
        case loudnessStart = "loudness_start"
        case loudnessMax = "loudness_max"
        case loudnessMaxTime = "loudness_max_time"
        case pitches
        case timbre
        case loudnessEnd = "loudness_end"
    }
}
