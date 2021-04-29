import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyExampleContent
import SpotifyAPITestUtilities

final class CodingTrackAttributesTests: SpotifyAPITestCase {
    
    static let allTests = [
        ("testCodingTrackAttributesFull", testCodingTrackAttributesFull),
        ("testCodingTrackAttributesSmall", testCodingTrackAttributesSmall)
    ]
    
    func testCodingTrackAttributesFull() throws {
        
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
        
        encodeDecode(trackAttributesFull)
        
        let queryDictionary = try trackAttributesFull.queryDictionary()

        XCTAssertEqual(
            queryDictionary["seed_artists"],
            "3WrFJ7ztbogyGnTHbHJFl2,4kSGbjWGxTchKpIxXPJv0B"
        )
        XCTAssertEqual(
            queryDictionary["seed_tracks"],
            "7AalBKBoLDR4UmRYRJpdbj"
        )
        XCTAssertEqual(
            queryDictionary["seed_genres"],
            "rock,party"
        )
        XCTAssertEqual(
            queryDictionary["min_acousticness"].flatMap(Double.init),
            0.35
        )
        XCTAssertEqual(
            queryDictionary["target_acousticness"].flatMap(Double.init),
            0.5
        )
        XCTAssertEqual(
            queryDictionary["max_acousticness"].flatMap(Double.init),
            0.9
        )
        XCTAssertEqual(
            queryDictionary["min_danceability"].flatMap(Double.init),
            0.1
        )
        XCTAssertEqual(
            queryDictionary["target_danceability"].flatMap(Double.init),
            0.3
        )
        XCTAssertEqual(
            queryDictionary["max_danceability"].flatMap(Double.init),
            0.98
        )
        XCTAssertEqual(
            queryDictionary["min_duration_ms"].flatMap(Int.init),
            100000
        )
        XCTAssertEqual(
            queryDictionary["target_duration_ms"].flatMap(Int.init),
            200000
        )
        XCTAssertEqual(
            queryDictionary["max_duration_ms"].flatMap(Int.init),
            500000
        )
        XCTAssertEqual(
            queryDictionary["min_energy"].flatMap(Double.init),
            0.004
        )
        XCTAssertEqual(
            queryDictionary["target_energy"].flatMap(Double.init),
            0.9
        )
        XCTAssertEqual(
            queryDictionary["max_energy"].flatMap(Double.init),
            1
        )
        XCTAssertEqual(
            queryDictionary["min_instrumentalness"].flatMap(Double.init),
            0.1
        )
        XCTAssertEqual(
            queryDictionary["target_instrumentalness"].flatMap(Double.init),
            0.2
        )
        XCTAssertEqual(
            queryDictionary["max_instrumentalness"].flatMap(Double.init),
            0.4
        )
        XCTAssertEqual(
            queryDictionary["min_key"].flatMap(Int.init),
            1
        )
        XCTAssertEqual(
            queryDictionary["target_key"].flatMap(Double.init),
            5
        )
        XCTAssertEqual(
            queryDictionary["max_key"].flatMap(Int.init),
            10
        )
        XCTAssertEqual(
            queryDictionary["min_liveness"].flatMap(Double.init),
            0.1
        )
        XCTAssertEqual(
            queryDictionary["target_liveness"].flatMap(Double.init),
            0.5
        )
        XCTAssertEqual(
            queryDictionary["max_liveness"].flatMap(Double.init),
            0.9
        )
        XCTAssertEqual(
            queryDictionary["min_loudness"].flatMap(Double.init),
            0.7
        )
        XCTAssertEqual(
            queryDictionary["target_loudness"].flatMap(Double.init),
            0.8
        )
        XCTAssertEqual(
            queryDictionary["max_loudness"].flatMap(Double.init),
            0.9
        )
        XCTAssertEqual(
            queryDictionary["min_mode"].flatMap(Int.init),
            5
        )
        XCTAssertEqual(
            queryDictionary["min_popularity"].flatMap(Int.init),
            20
        )
        XCTAssertEqual(
            queryDictionary["target_popularity"].flatMap(Int.init),
            90
        )
        XCTAssertEqual(
            queryDictionary["max_popularity"].flatMap(Int.init),
            100
        )
        XCTAssertEqual(
            queryDictionary["min_speechiness"].flatMap(Double.init),
            0.4
        )
        XCTAssertEqual(
            queryDictionary["target_speechiness"].flatMap(Double.init),
            0.7
        )
        XCTAssertEqual(
            queryDictionary["max_speechiness"].flatMap(Double.init),
            1
        )
        XCTAssertEqual(
            queryDictionary["min_tempo"].flatMap(Double.init),
            0.1
        )
        XCTAssertEqual(
            queryDictionary["target_tempo"].flatMap(Double.init),
            0.3
        )
        XCTAssertEqual(
            queryDictionary["max_tempo"].flatMap(Double.init),
            0.8
        )
        XCTAssertEqual(
            queryDictionary["min_time_signature"].flatMap(Int.init),
            0
        )
        XCTAssertEqual(
            queryDictionary["target_time_signature"].flatMap(Int.init),
            5
        )
        XCTAssertEqual(
            queryDictionary["max_time_signature"].flatMap(Int.init),
            10
        )
        XCTAssertEqual(
            queryDictionary["min_valence"].flatMap(Double.init),
            0.8
        )
        XCTAssertEqual(
            queryDictionary["target_valence"].flatMap(Double.init),
            0.8
        )
        XCTAssertEqual(
            queryDictionary["max_valence"].flatMap(Double.init),
            0.9
        )

        XCTAssertEqual(queryDictionary.count, 43)

    }
    
    func testCodingTrackAttributesSmall() throws {
        
        let trackAttributesSmall = TrackAttributes(
            seedTracks: URIs.Tracks.array(.anyColourYouLike, .breathe),
            seedGenres: [],
            energy: .init(min: 0.1, target: 0.43, max: 0.8),
            popularity: .init(min: 20),
            timeSignature: .init(max: 5),
            valence: .init(target: 0.3)
        )
        
        encodeDecode(trackAttributesSmall)
        
        let queryDictionary = try trackAttributesSmall.queryDictionary()
        
        XCTAssertEqual(
            queryDictionary["seed_tracks"],
            "6FBPOJLxUZEair6x4kLDhf,2ctvdKmETyOzPb2GiJJT53"
        )
        XCTAssertEqual(
            queryDictionary["seed_genres"],
            ""
        )
        XCTAssertEqual(
            queryDictionary["min_energy"].flatMap(Double.init),
            0.1
        )
        XCTAssertEqual(
            queryDictionary["target_energy"].flatMap(Double.init),
            0.43
        )
        XCTAssertEqual(
            queryDictionary["max_energy"].flatMap(Double.init),
            0.8
        )
        XCTAssertEqual(
            queryDictionary["min_popularity"].flatMap(Int.init),
            20
        )
        XCTAssertEqual(
            queryDictionary["max_time_signature"].flatMap(Int.init),
            5
        )
        XCTAssertEqual(
            queryDictionary["target_valence"].flatMap(Double.init),
            0.3
        )
        XCTAssertEqual(queryDictionary.count, 8)
        
    }
    
    
}
