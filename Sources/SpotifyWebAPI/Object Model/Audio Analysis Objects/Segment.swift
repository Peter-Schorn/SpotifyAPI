import Foundation

/**
 A segment of a track with a roughly consistent sound.
 
 Read more at the [Spotify web API reference][1].

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
     
     Combined with ``loudnessMax`` and ``loudnessMaxTime``, these components can
     be used to describe the “attack” of the segment.
     */
    public let loudnessStart: Double
    
    /**
     The peak loudness of the segment in decibels (dB).
     
     Combined with ``loudnessStart`` and ``loudnessMaxTime``, these components
     can be used to describe the “attack” of the segment.
     */
    public let loudnessMax: Double
    
    /**
     The segment-relative offset of the segment peak loudness in seconds.
     
     Combined with ``loudnessStart`` and ``loudnessMax``, these components can
     be used to describe the “attack” of the segment.
     */
    public let loudnessMaxTime: Double
    
    /**
     A “chroma” vector representing the pitch content of the segment,
     corresponding to the 12 pitch classes C, C#, D to B, with values ranging
     from 0 to 1 that describe the relative dominance of every pitch in the
     chromatic scale. More details about how to interpret this vector can be
     found [here][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#pitch
     */
    public let pitches: [Double]
    
    /**
     Timbre is the quality of a musical note or sound that distinguishes
     different types of musical instruments, or voices. Timbre vectors are best
     used in comparison with each other. More details about how to interpret
     this vector can be found [here][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#timbre
     */
    public let timbre: [Double]
    
    /// The offset loudness of the segment in decibels (dB).
    ///
    /// This value should be equivalent to the ``loudnessStart`` of the
    /// following segment.
    public let loudnessEnd: Double

    /**
     Creates a segment of a track.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - start: The starting point (in seconds) of the segment.
       - duration: The duration (in seconds) of the segment.
       - confidence: The confidence, from 0.0 to 1.0, of the reliability of the
             segmentation. Segments of the song which are difficult to logically
             segment (e.g: noise) may correspond to low values in this field.
       - loudnessStart: The onset loudness of the segment in decibels (dB).
             Combined with ``loudnessMax`` and ``loudnessMaxTime``, these
             components can be used to describe the “attack” of the segment.
       - loudnessMax: The peak loudness of the segment in decibels (dB).
             Combined with ``loudnessStart`` and ``loudnessMaxTime``, these
             components can be used to describe the “attack” of the segment.
       - loudnessMaxTime: The segment-relative offset of the segment peak
             loudness in seconds. Combined with ``loudnessStart`` and
             ``loudnessMax``, these components can be used to describe the
             “attack” of the segment.
       - pitches: A “chroma” vector representing the pitch content of the
             segment, corresponding to the 12 pitch classes C, C#, D to B, with
             values ranging from 0 to 1 that describe the relative dominance of
             every pitch in the chromatic scale. More details about how to
             interpret this vector can be found [here][2].
       - timbre: Timbre is the quality of a musical note or sound that
             distinguishes different types of musical instruments, or voices.
             Timbre vectors are best used in comparison with each other. More
             details about how to interpret this vector can be found [here][3].
       - loudnessEnd: The offset loudness of the segment in decibels (dB). This
             value should be equivalent to the ``loudnessStart`` of the
             following segment.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#segment-object
     [2]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#pitch
     [3]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#timbre
     */
    public init(
        start: Double,
        duration: Double,
        confidence: Double,
        loudnessStart: Double,
        loudnessMax: Double,
        loudnessMaxTime: Double,
        pitches: [Double],
        timbre: [Double],
        loudnessEnd: Double
    ) {
        self.start = start
        self.duration = duration
        self.confidence = confidence
        self.loudnessStart = loudnessStart
        self.loudnessMax = loudnessMax
        self.loudnessMaxTime = loudnessMaxTime
        self.pitches = pitches
        self.timbre = timbre
        self.loudnessEnd = loudnessEnd
    }
    
}

extension Segment: Codable {
    
    private enum CodingKeys: String, CodingKey {
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

extension Segment: ApproximatelyEquatable {
    
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
        if !self.loudnessStart.isApproximatelyEqual(
            to: other.loudnessStart, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.loudnessMax.isApproximatelyEqual(
            to: other.loudnessMax, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.loudnessMaxTime.isApproximatelyEqual(
            to: other.loudnessMaxTime, absoluteTolerance: 0.001
        ) {
            return false
        }
        for (lhs, rhs) in zip(self.pitches, other.pitches) {
            if !lhs.isApproximatelyEqual(to: rhs, absoluteTolerance: 0.001) {
                return false
            }
        }
        for (lhs, rhs) in zip(self.timbre, other.timbre) {
            if !lhs.isApproximatelyEqual(to: rhs, absoluteTolerance: 0.001) {
                return false
            }
        }
        return self.loudnessEnd.isApproximatelyEqual(
            to: other.loudnessEnd, absoluteTolerance: 0.001
        )
    }

}
