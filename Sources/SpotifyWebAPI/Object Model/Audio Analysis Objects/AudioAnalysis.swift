import Foundation

/**
 Describes a tracks structure and musical content, including rhythm, pitch, and
 timbre.

 All information is precise to the audio sample. Many elements of analysis
 include confidence values, a floating-point number ranging from 0.0 to 1.0.
 Confidence indicates the reliability of its corresponding attribute. Elements
 carrying a small confidence value should be considered speculative. There may
 not be sufficient data in the audio to compute the attribute with high
 certainty.
 
 Read more at the [Spotify web API reference][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#audio-analysis-object
 */
public struct AudioAnalysis: Codable, Hashable {
    
    /**
     The time intervals of the bars throughout the track.
    
     A bar (or measure) is a segment of time defined as a given number of beats.
     Bar offsets also indicate downbeats, the first beat of the measure.
     */
    public let bars: [SpotifyTimeInterval]
    
    /**
     The time intervals of beats throughout the track.
    
     A beat is the basic time unit of a piece of music; for example, each tick
     of a metronome. Beats are typically multiples of tatums.
     */
    public let beats: [SpotifyTimeInterval]
    
    /**
     A tatum represents the lowest regular pulse train that a listener
     intuitively infers from the timing of perceived musical events (segments).
    
     For more information about tatums, see [Rhythm][1].
    
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#rhythm
     */
    public let tatums: [SpotifyTimeInterval]

    /// Sections are defined by large variations in rhythm or timbre, e.g.
    /// chorus, verse, bridge, guitar solo, etc. Each section contains its own
    /// descriptions of tempo, key, mode, time signature, and loudness.
    public let sections: [Section]
    
    /// Audio segments attempts to subdivide a song into many segments, with
    /// each segment containing a roughly consistent sound throughout its
    /// duration.
    public let segments: [Segment]
    
    /**
     Creates a new Audio Analysis object.
     
     Describes a tracks structure and musical content, including rhythm, pitch,
     and timbre.

     All information is precise to the audio sample. Many elements of analysis
     include confidence values, a floating-point number ranging from 0.0 to 1.0.
     Confidence indicates the reliability of its corresponding attribute.
     Elements carrying a small confidence value should be considered
     speculative. There may not be sufficient data in the audio to compute the
     attribute with high certainty.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - bars: The time intervals of the bars throughout the track. A bar (or
             measure) is a segment of time defined as a given number of beats.
             Bar offsets also indicate downbeats, the first beat of the measure.
       - beats: The time intervals of beats throughout the track. A beat is the
             basic time unit of a piece of music; for example, each tick of a
             metronome. Beats are typically multiples of tatums.
       - tatums: A tatum represents the lowest regular pulse train that a
             listener intuitively infers from the timing of perceived musical
             events (segments). For more information about tatums, see
             [Rhythm][2].
       - sections: Sections are defined by large variations in rhythm or timbre,
             e.g. chorus, verse, bridge, guitar solo, etc. Each section contains
             its own descriptions of tempo, key, mode, time signature, and
             loudness.
       - segments: Audio segments attempts to subdivide a song into many
             segments, with each segment containing a roughly consistent sound
             throughout it's duration.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#audio-analysis-object
     [2]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#rhythm
     */
    public init(
        bars: [SpotifyTimeInterval],
        beats: [SpotifyTimeInterval],
        tatums: [SpotifyTimeInterval],
        sections: [Section],
        segments: [Segment]
    ) {
        self.bars = bars
        self.beats = beats
        self.tatums = tatums
        self.sections = sections
        self.segments = segments
    }

}

extension AudioAnalysis: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {

        return self.bars.isApproximatelyEqual(to: other.bars) &&
                self.beats.isApproximatelyEqual(to: other.beats) &&
                self.tatums.isApproximatelyEqual(to: other.tatums) &&
                self.sections.isApproximatelyEqual(to: other.sections) &&
                self.segments.isApproximatelyEqual(to: other.segments)

    }

}
