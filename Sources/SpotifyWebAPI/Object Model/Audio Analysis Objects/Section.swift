import Foundation

/**
 Sections are defined by large variations in rhythm or timbre, e.g. chorus,
 verse, bridge, guitar solo, etc.

 Each section contains its own descriptions of tempo, key, mode, time signature,
 and loudness.
 
 Read more at the [Spotify web API reference][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#section-object
 */
public struct Section: Hashable {
    
    /// The starting point (in seconds) of the section.
    public let start: Double
    
    /// The duration (in seconds) of the section.
    public let duration: Double
    
    /// The confidence, from 0.0 to 1.0, of the reliability of the section’s
    /// “designation”.
    public let confidence: Double
    
    /**
     The overall loudness of the section in decibels (dB).
    
     Loudness values are useful for comparing relative loudness of sections
     within tracks.
     */
    public let loudness: Double
    
    /**
     The overall estimated tempo of the section in beats per minute (BPM).
     
     In musical terminology, tempo is the speed or pace of a given piece and
     derives directly from the average beat duration.
     */
    public let tempo: Double
    
    /**
     The confidence, from 0.0 to 1.0, of the reliability of the ``tempo``.
     
     Some tracks contain tempo changes or sounds which don’t contain tempo (like
     pure speech) which would correspond to a low value in this field.
     */
    public let tempoConfidence: Double
    
    /**
     The estimated overall key of the section.
     
     The values in this field ranging from 0 to 11 mapping to pitches using
     standard [Pitch Class notation][1] (E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so
     on). If no key was detected, the value is -1.
     
     [1]: https://en.wikipedia.org/wiki/Pitch_class
     */
    public let key: Int
    
    /// The confidence, from 0.0 to 1.0, of the reliability of the ``key``.
    ///
    /// Songs with many key changes may correspond to low values in this field.
    public let keyConfidence: Double
    
    /**
     Indicates the modality (major or minor) of a track, the type of scale from
     which its melodic content is derived.
     
     This field will contain a 0 for “minor”, a 1 for “major”, or a -1 for no
     result. Note that the major key (e.g. C major) could more likely be
     confused with the minor key at 3 semitones lower (e.g. A minor) as both
     keys carry the same pitches.
     */
    public let mode: Int
    
    /// The confidence, from 0.0 to 1.0, of the reliability of the ``mode``.
    public let modeConfidence: Double
    
    /**
     An estimated overall time signature of a track.
     
     The time signature (meter) is a notational convention to specify how many
     beats are in each bar (or measure). The time signature ranges from 3 to 7
     indicating time signatures of “3/4”, to “7/4”.
     */
    public let timeSignature: Int
    
    /**
     The confidence, from 0.0 to 1.0, of the reliability of the time signature.
     
     Sections with time signature changes may correspond to low values in this
     field.
     */
    public let timeSignatureConfidence: Double
    
    /**
     Creates a Section object.
     
     Sections are defined by large variations in rhythm or timbre, e.g. chorus,
     verse, bridge, guitar solo, etc.
     
     Each section contains its own descriptions of tempo, key, mode, time
     signature, and loudness.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - start: The starting point (in seconds) of the section.
       - duration: The duration (in seconds) of the section.
       - confidence: The confidence, from 0.0 to 1.0, of the reliability of the
             section’s “designation”.
       - loudness: The overall loudness of the section in decibels (dB).
             Loudness values are useful for comparing relative loudness of
             sections within tracks.
       - tempo: The overall estimated tempo of the section in beats per minute
             (BPM). In musical terminology, tempo is the speed or pace of a
             given piece and derives directly from the average beat duration.
       - tempoConfidence: The confidence, from 0.0 to 1.0, of the reliability of
             the ``tempo``. Some tracks contain tempo changes or sounds which
             don’t contain tempo (like pure speech) which would correspond to a
             low value in this field.
       - key: The estimated overall key of the section. The values in this field
             ranging from 0 to 11 mapping to pitches using standard [Pitch Class
             notation][2] (E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on). If no key
             was detected, the value is -1.
       - keyConfidence: The confidence, from 0.0 to 1.0, of the reliability of
             the ``key``. Songs with many key changes may correspond to low
             values in this field.
       - mode: Indicates the modality (major or minor) of a track, the type of
             scale from which its melodic content is derived. This field will
             contain a 0 for “minor”, a 1 for “major”, or a -1 for no result.
             Note that the major key (e.g. C major) could more likely be
             confused with the minor key at 3 semitones lower (e.g. A minor) as
             both keys carry the same pitches.
       - modeConfidence: The confidence, from 0.0 to 1.0, of the reliability of
             the ``mode``.
       - timeSignature: An estimated overall time signature of a track. The time
             signature (meter) is a notational convention to specify how many
             beats are in each bar (or measure). The time signature ranges from
             3 to 7 indicating time signatures of “3/4”, to “7/4”.
       - timeSignatureConfidence: The confidence, from 0.0 to 1.0, of the
             reliability of the time signature. Sections with time signature
             changes may correspond to low values in this field.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#section-object
     [2]: https://en.wikipedia.org/wiki/Pitch_class
     */
    public init(
        start: Double,
        duration: Double,
        confidence: Double,
        loudness: Double,
        tempo: Double,
        tempoConfidence: Double,
        key: Int,
        keyConfidence: Double,
        mode: Int,
        modeConfidence: Double,
        timeSignature: Int,
        timeSignatureConfidence: Double
    ) {
        self.start = start
        self.duration = duration
        self.confidence = confidence
        self.loudness = loudness
        self.tempo = tempo
        self.tempoConfidence = tempoConfidence
        self.key = key
        self.keyConfidence = keyConfidence
        self.mode = mode
        self.modeConfidence = modeConfidence
        self.timeSignature = timeSignature
        self.timeSignatureConfidence = timeSignatureConfidence
    }
    
}

extension Section: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case start
        case duration
        case confidence
        case loudness
        case tempo
        case tempoConfidence = "tempo_confidence"
        case key
        case keyConfidence = "key_confidence"
        case mode
        case modeConfidence = "mode_confidence"
        case timeSignature = "time_signature"
        case timeSignatureConfidence = "time_signature_confidence"
        
    }
    
}

extension Section: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
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
        if !self.loudness.isApproximatelyEqual(
            to: other.loudness, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.tempo.isApproximatelyEqual(
            to: other.tempo, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.tempoConfidence.isApproximatelyEqual(
            to: other.tempoConfidence, absoluteTolerance: 0.001
        ) {
            return false
        }
        if self.key != other.key {
            return false
        }
        if !self.keyConfidence.isApproximatelyEqual(
            to: other.keyConfidence, absoluteTolerance: 0.001
        ) {
            return false
        }
        if self.mode != other.mode {
            return false
        }
        if !self.modeConfidence.isApproximatelyEqual(
            to: other.modeConfidence, absoluteTolerance: 0.001
        ) {
            return false
        }
        if self.timeSignature != other.timeSignature {
            return false
        }
        return self.timeSignatureConfidence.isApproximatelyEqual(
            to: other.timeSignatureConfidence, absoluteTolerance: 0.001
        )
    }
    
}
