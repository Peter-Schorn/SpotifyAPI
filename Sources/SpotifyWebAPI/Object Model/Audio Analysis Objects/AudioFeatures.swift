import Foundation

/// The audio features of a track.
public struct AudioFeatures: Codable, Hashable {

    /**
     The estimated overall key of the track.
     
     Integers map to pitches using standard [Pitch Class notation][1]. E.g. 0 =
     C, 1 = C♯/D♭, 2 = D, and so on. **If no key was detected, the value is
     -1.**
     
     [1]: https://en.wikipedia.org/wiki/Pitch_class
     */
    public let key: Int

    /**
     Mode indicates the modality (major or minor) of a track, the type of scale
     from which its melodic content is derived.
     
     Major is represented by 1 and minor is 0.
     */
    public let mode: Int

    /**
     An estimated overall time signature of a track.
     
     The time signature (meter) is a notational convention to specify how many
     beats are in each bar (or measure).
     */
    public let timeSignature: Int

    /**
     A confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0
     represents high confidence the track is acoustic.
     */
    public let acousticness: Double
    
    /**
     Danceability describes how suitable a track is for dancing based on a
     combination of musical elements including tempo, rhythm stability, beat
     strength, and overall regularity.

     A value of 0.0 is least danceable and 1.0 is most danceable.
     */
    public let danceability: Double
    
    /**
     Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of
     intensity and activity.
     
     Typically, energetic tracks feel fast, loud, and noisy. For example, death
     metal has high energy, while a Bach prelude scores low on the scale.
     Perceptual features contributing to this attribute include dynamic range,
     perceived loudness, timbre, onset rate, and general entropy.
     */
    public let energy: Double
    
    /**
     Predicts whether a track contains no vocals.
     
     “Ooh” and “aah” sounds are treated as instrumental in this context. Rap or
     spoken word tracks are clearly “vocal”. The closer the instrumentalness
     value is to 1.0, the greater likelihood the track contains no vocal
     content. Values above 0.5 are intended to represent instrumental tracks,
     but confidence is higher as the value approaches 1.0.
     */
    public let instrumentalness: Double

    /**
     Detects the presence of an audience in the recording. Higher liveness
     values represent an increased probability that the track was performed
     live. A value above 0.8 provides strong likelihood that the track is live.
     */
    public let liveness: Double
    
    /**
     The overall loudness of a track in decibels (dB).
     
     Loudness values are averaged across the entire track and are useful for
     comparing relative loudness of tracks. Loudness is the quality of a sound
     that is the primary psychological correlate of physical strength
     (amplitude). Values typical range between -60 and 0 db.
     */
    public let loudness: Double
    
    /**
     Speechiness detects the presence of spoken words in a track.
     
     The more exclusively speech-like the recording (e.g. talk show, audio book,
     poetry), the closer to 1.0 the attribute value. Values above 0.66 describe
     tracks that are probably made entirely of spoken words. Values between 0.33
     and 0.66 describe tracks that may contain both music and speech, either in
     sections or layered, including such cases as rap music. Values below 0.33
     most likely represent music and other non-speech-like tracks.
     */
    public let speechiness: Double
    
    /**
     A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a
     track.

     Tracks with high valence sound more positive (e.g. happy, cheerful,
     euphoric), while tracks with low valence sound more negative (e.g. sad,
     depressed, angry).
     */
    public let valence: Double
    
    /**
     The overall estimated tempo of a track in beats per minute (BPM).

     In musical terminology, tempo is the speed or pace of a given piece and
     derives directly from the average beat duration.
     */
    public let tempo: Double
    
    /// The Spotify URI for the track.
    public let uri: String

    /// The Spotify ID for the track.
    public let id: String
    
    /**
     A link to the Web API endpoint providing full details of the track.
    
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``Track`` as
     the response type to retrieve the results. This is equivalent to using
     ``SpotifyAPI/track(_:market:)``, passing in the URI of this track.
     */
    public let trackHref: String
    
    /**
     An href to the full audio analysis of this track.

     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``AudioAnalysis``
     as the response type to retrieve the results. This is equivalent to using
     ``SpotifyAPI/trackAudioAnalysis(_:)``, passing in the URI of this track.
     */
    public let analysisURL: URL

    /// The duration of the track in milliseconds.
    public let durationMS: Int
    
    /// The object type. Always "audio_features".
    public let type: String
    
    private enum CodingKeys: String, CodingKey {
        case key
        case mode
        case timeSignature = "time_signature"
        case acousticness
        case danceability
        case energy
        case instrumentalness
        case liveness
        case loudness
        case speechiness
        case valence
        case tempo
        case uri
        case id
        case trackHref = "track_href"
        case analysisURL = "analysis_url"
        case durationMS = "duration_ms"
        case type
    }
    
    /**
     Creates a new Audio Features object.
     
     - Parameters:
       - key: The estimated overall key of the track.
             Integers map to pitches using standard [Pitch Class notation][1].
             E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on. **If no key was detected,
             the value is -1.**
       - mode: Mode indicates the modality (major or minor) of a track, the
             type of scale from which its melodic content is derived. Major is
             represented by 1 and minor is 0.
       - timeSignature: An estimated overall time signature of a track. The time
             signature (meter) is a notational convention to specify how many
             beats are in each bar (or measure).
       - acousticness: A confidence measure from 0.0 to 1.0 of whether the track
             is acoustic. 1.0 represents high confidence the track is acoustic.
       - danceability: Danceability describes how suitable a track is for
             dancing based on a combination of musical elements including tempo,
             rhythm stability, beat strength, and overall regularity. A value of
             0.0 is least danceable and 1.0 is most danceable.
       - energy: Energy is a measure from 0.0 to 1.0 and represents a perceptual
             measure of intensity and activity. Typically, energetic tracks feel
             fast, loud, and noisy. For example, death metal has high energy,
             while a Bach prelude scores low on the scale. Perceptual features
             contributing to this attribute include dynamic range, perceived
             loudness, timbre, onset rate, and general entropy.
       - instrumentalness: Predicts whether a track contains no vocals. “Ooh”
             and “aah” sounds are treated as instrumental in this context. Rap
             or spoken word tracks are clearly “vocal”. The closer the
             instrumentalness value is to 1.0, the greater likelihood the track
             contains no vocal content. Values above 0.5 are intended to
             represent instrumental tracks, but confidence is higher as the
             value approaches 1.0.
       - liveness: Detects the presence of an audience in the recording. Higher
             liveness values represent an increased probability that the track
             was performed live. A value above 0.8 provides strong likelihood
             that the track is live.
       - loudness: The overall loudness of a track in decibels (dB). Loudness
             values are averaged across the entire track and are useful for
             comparing relative loudness of tracks. Loudness is the quality of a
             sound that is the primary psychological correlate of physical
             strength (amplitude). Values typical range between -60 and 0 db.
       - speechiness: Speechiness detects the presence of spoken words in a
             track. The more exclusively speech-like the recording (e.g. talk
             show, audio book, poetry), the closer to 1.0 the attribute value.
             Values above 0.66 describe tracks that are probably made entirely
             of spoken words. Values between 0.33 and 0.66 describe tracks that
             may contain both music and speech, either in sections or layered,
             including such cases as rap music. Values below 0.33 most likely
             represent music and other non-speech-like tracks.
       - valence: A measure from 0.0 to 1.0 describing the musical positiveness
             conveyed by a track. Tracks with high valence sound more positive
             (e.g. happy, cheerful, euphoric), while tracks with low valence
             sound more negative (e.g. sad, depressed, angry).
       - tempo: The overall estimated tempo of a track in beats per minute
             (BPM). In musical terminology, tempo is the speed or pace of a
             given piece and derives directly from the average beat duration.
       - uri: The Spotify URI for the track.
       - id: The Spotify ID for the track.
       - trackHref: A link to the Web API endpoint providing full details of the
             track. Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in
             ``Track`` as the response type to retrieve the results.
       - analysisURL: An HTTP URL to access the full audio analysis of this
             track. An access token is required to access this data.
       - durationMS: The duration of the track in milliseconds.
       - type: The object type. Always "audio_features".
     
     [1]: https://en.wikipedia.org/wiki/Pitch_class
     */
    public init(
        key: Int,
        mode: Int,
        timeSignature: Int,
        acousticness: Double,
        danceability: Double,
        energy: Double,
        instrumentalness: Double,
        liveness: Double,
        loudness: Double,
        speechiness: Double,
        valence: Double,
        tempo: Double,
        uri: String,
        id: String,
        trackHref: String,
        analysisURL: URL,
        durationMS: Int,
        type: String
    ) {
        self.key = key
        self.mode = mode
        self.timeSignature = timeSignature
        self.acousticness = acousticness
        self.danceability = danceability
        self.energy = energy
        self.instrumentalness = instrumentalness
        self.liveness = liveness
        self.loudness = loudness
        self.speechiness = speechiness
        self.valence = valence
        self.tempo = tempo
        self.uri = uri
        self.id = id
        self.trackHref = trackHref
        self.analysisURL = analysisURL
        self.durationMS = durationMS
        self.type = type
    }
    
}

extension AudioFeatures: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
        
        if self.key != other.key {
            return false
        }
        if self.mode != other.mode {
            return false
        }
        if self.timeSignature != other.timeSignature {
            return false
        }
        if !self.acousticness.isApproximatelyEqual(
            to: other.acousticness, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.danceability.isApproximatelyEqual(
            to: other.danceability, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.energy.isApproximatelyEqual(
            to: other.energy, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.instrumentalness.isApproximatelyEqual(
            to: other.instrumentalness, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.liveness.isApproximatelyEqual(
            to: other.liveness, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.loudness.isApproximatelyEqual(
            to: other.loudness, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.speechiness.isApproximatelyEqual(
            to: other.speechiness, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.valence.isApproximatelyEqual(
            to: other.valence, absoluteTolerance: 0.001
        ) {
            return false
        }
        if !self.tempo.isApproximatelyEqual(
            to: other.tempo, absoluteTolerance: 0.001
        ) {
            return false
        }
        if self.uri != other.uri {
            return false
        }
        if self.id != other.id {
            return false
        }
        if self.trackHref != other.trackHref {
            return false
        }
        if self.analysisURL != other.analysisURL {
            return false
        }
        if self.durationMS != other.durationMS {
            return false
        }
        return self.type == other.type
        
    }

}
