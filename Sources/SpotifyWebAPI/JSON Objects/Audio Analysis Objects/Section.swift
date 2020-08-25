import Foundation

/**
 [Sections][1] are defined by large variations in rhythm or timbre,
 e.g. chorus, verse, bridge, guitar solo, etc.
 
 Each section contains its own descriptions of tempo, key, mode,
 time_signature, and loudness.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#section-object
 */
public struct Section: Hashable {
    
    /// The starting point (in seconds) of the section.
    public let start: Double
    
    /// The duration (in seconds) of the section.
    public let duration: Double
    
    /// The confidence, from 0.0 to 1.0, of the reliability of the
    /// section’s “designation”.
    public let confidence: Double
    
    /// The overall loudness of the section in decibels (dB).
    ///
    /// Loudness values are useful for comparing relative loudness
    /// of sections within tracks.
    public let loudness: Double
    
    /**
     The overall estimated tempo of the section in beats per minute (BPM).
     
     In musical terminology, tempo is the speed or pace of a given piece and
     derives directly from the average beat duration.
     */
    public let tempo: Double
    
    /**
     The confidence, from 0.0 to 1.0, of the reliability of the `tempo`.
     
     Some tracks contain tempo changes or sounds which don’t contain tempo
     (like pure speech) which would correspond to a low value in this field.
     */
    public let tempoConfidence: Double
    
    /**
     The estimated overall key of the section.
     
     The values in this field ranging from 0 to 11 mapping to pitches using
     standard [Pitch Class notation][1] (E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on).
     If no key was detected, the value is -1.
     
     [1]: https://en.wikipedia.org/wiki/Pitch_class
     */
    public let key: Int
    
    /// The confidence, from 0.0 to 1.0, of the reliability of the `key`.
    ///
    /// Songs with many key changes may correspond to low values in this field.
    public let keyConfidence: Double
    
    /**
     Indicates the modality (major or minor) of a track, the type of scale
     from which its melodic content is derived.
     
     This field will contain a
     0 for “minor”, a 1 for “major”, or a -1 for no result. Note that the
     major key (e.g. C major) could more likely be confused with the minor
     key at 3 semitones lower (e.g. A minor) as both keys carry the same
     pitches.
     */
    public let mode: Int
    
    /// The confidence, from 0.0 to 1.0, of the reliability of the `mode`.
    public let modeConfidence: Double
    
    /**
     An estimated overall time signature of a track.
     
     The time signature (meter) is a notational convention to specify
     how many beats are in each bar (or measure). The time signature
     ranges from 3 to 7 indicating time signatures of “3/4”, to “7/4”.
     */
    public let timeSignature: Int
    
    /**
     The confidence, from 0.0 to 1.0, of the reliability of the
     time_signature.
     
     Sections with time signature changes may correspond to low values
     in this field.
     */
    public let timeSignatureConfidence: Double
    
}

extension Section: Codable {
    
    public enum CodingKeys: String, CodingKey {
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
