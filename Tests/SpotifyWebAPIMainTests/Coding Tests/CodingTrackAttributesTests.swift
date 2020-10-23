import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyExampleContent
import SpotifyAPITestUtilities

final class CodingTrackAttributesTests: XCTestCase {
    
    static var allTests = [
        ("testCodingTrackAttributes", testCodingTrackAttributes)
    ]
    
    func testCodingTrackAttributes() {
        
        let trackAttributesFull = TrackAttributes(
            seedArtists: URIs.Artists.array(.theBeatles, .crumb),
            seedTracks: URIs.Tracks.array(.fearless),
            seedGenres: ["rock", "party"],
            acousticness: .init(min: 0.35, target: 0.5, max: 0.9),
            danceability: .init(min: 0.1, target: 0.3, max: 0.98),
            durationMS: .init(min: 100_000, target: 200_000, max: 500_000),
            energy: .init(min: 0.004, target: 0.9, max: 1),
            instrumentalness: .init(min: 0.1, target: 0.2, max: 0.4),
            key: .init(min: 1, target: 5, max: 10),
            liveness: .init(min: 0.1, target: 0.5, max: 0.9),
            loudness: .init(min: 0.7, target: 0.8, max: 0.9),
            mode: .init(min: 5),
            popularity: .init(min: 20, target: 90, max: 100),
            speechiness: .init(min: 0.4, target: 0.7, max: 1),
            tempo: .init(min: 0.1, target: 0.3, max: 0.8),
            timeSignature: .init(min: 0, target: 5, max: 10),
            valence: .init(min: 0.8, target: 0.8, max: 0.9)
        )
        
        encodeDecode(
            trackAttributesFull,
            areEqual: { $0.isApproximatelyEqual(to: $1) }
        )
        
        let trackAttributesSmall = TrackAttributes(
            seedTracks: URIs.Tracks.array(.anyColourYouLike, .breathe),
            seedGenres: [],
            energy: .init(min: 0.1, target: 0.43, max: 0.8),
            popularity: .init(min: 20),
            timeSignature: .init(max: 5),
            valence: .init(target: 0.3)
        )
        
        encodeDecode(
            trackAttributesSmall,
            areEqual: { $0.isApproximatelyEqual(to: $1) }
        )
        
    }
    
    
}
