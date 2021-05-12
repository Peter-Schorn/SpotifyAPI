import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

final class CodingPlaybackRequestTests: SpotifyAPITestCase {
    
    static let allTests = [
        ("testCodingContextOption1", testCodingContextOption1),
        ("testCodingContextOption2", testCodingContextOption2),
        ("testCodingOffsetOption1", testCodingOffsetOption1),
        ("testCodingOffsetOption2", testCodingOffsetOption2),
        ("testCodingPlaybackReqest1", testCodingPlaybackReqest1),
        ("testCodingPlaybackReqest2", testCodingPlaybackReqest2),
        ("testCodingPlaybackReqest3", testCodingPlaybackReqest3),
        ("testCodingPlaybackReqest4", testCodingPlaybackReqest4),
        ("testCodingPlaybackReqest5", testCodingPlaybackReqest5),
        ("testCodingPlaybackReqest6", testCodingPlaybackReqest6),
        ("testCodingPlaybackReqest7", testCodingPlaybackReqest7),
        ("testCodingPlaybackReqest8", testCodingPlaybackReqest8),
        ("testCodingPlaybackReqest9", testCodingPlaybackReqest9),
        ("testCodingPlaybackReqest10", testCodingPlaybackReqest10),
        ("testCodingPlaybackReqest11", testCodingPlaybackReqest11),
        ("testCodingPlaybackReqest12", testCodingPlaybackReqest12),
        ("testCodingPlaybackReqest13", testCodingPlaybackReqest13),
        ("testCodingPlaybackReqest14", testCodingPlaybackReqest14),
        (
            "testCodingPlaybackReqestSingleTrack",
            testCodingPlaybackReqestSingleTrack
        ),
        (
            "testCodingPlaybackReqestSingleTrackWithPositionMS",
            testCodingPlaybackReqestSingleTrackWithPositionMS
        )
    ]

    func compareToData<T: Codable & Equatable>(
        _ type: T,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ((_ lhs: T, _ rhs: T) -> Bool) {
        
        return { lhs, rhs in
            XCTAssertEqual(lhs, rhs, file: file, line: line)
            XCTAssertEqual(rhs, type, file: file, line: line)
            return lhs == type
        }

    }
    
    func testCodingContextOption1() {
        
        let contextOption = PlaybackRequest.Context.contextURI(
            URIs.Tracks.because
        )
        encodeDecode(contextOption, areEqual: ==)

        let data = """
            {
                "context_uri": "\(URIs.Tracks.because.rawValue)"
            }
            """.data(using: .utf8)!

        decodeEncodeDecode(
            data,
            type: PlaybackRequest.Context.self,
            areEqual: self.compareToData(contextOption)
        )

    }
    
    func testCodingContextOption2() {
        
        let uris = URIs.Tracks.array(.eclipse, .faces, .friends)
        let contextOption = PlaybackRequest.Context.uris(uris)
        encodeDecode(contextOption, areEqual: ==)
        
        let data = """
            {
                "uris": \(uris)
            }
            """.data(using: .utf8)!

        decodeEncodeDecode(
            data,
            type: PlaybackRequest.Context.self,
            areEqual: self.compareToData(contextOption)
        )

    }
    
    func testCodingOffsetOption1() {
        
        let offsetOption = PlaybackRequest.Offset.position(5)
        encodeDecode(offsetOption, areEqual: ==)
        
        let data = """
            {
                "position": 5
            }
            """.data(using: .utf8)!

        decodeEncodeDecode(
            data,
            type: PlaybackRequest.Offset.self,
            areEqual: self.compareToData(offsetOption)
        )

    }
    
    func testCodingOffsetOption2() {
        
        let offsetOption = PlaybackRequest.Offset.uri(URIs.Tracks.because)
        encodeDecode(offsetOption, areEqual: ==)
        
        let data = """
            {
                "uri": "\(URIs.Tracks.because.rawValue)"
            }
            """.data(using: .utf8)!

        decodeEncodeDecode(
            data,
            type: PlaybackRequest.Offset.self,
            areEqual: self.compareToData(offsetOption)
        )

    }

    func testCodingPlaybackReqest1() throws {
        
        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Albums.jinx),
            offset: .position(3)  // "fall down"
        )
    
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "context_uri": "\(URIs.Albums.jinx.rawValue)",
                "offset": { "position": 3 }
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }
    
    func testCodingPlaybackReqest2() throws {
        
        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Albums.jinx),
            offset: .position(3),  // "fall down"
            positionMS: 5
        )
    
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "context_uri": "\(URIs.Albums.jinx.rawValue)",
                "offset": { "position": 3 },
                "position_ms": 5
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }
    
    func testCodingPlaybackReqest3() throws {
        
        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Playlists.crumb),
            offset: .uri(URIs.Tracks.locket)
        )
    
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "context_uri": "\(URIs.Playlists.crumb.rawValue)",
                "offset": { "uri": "\(URIs.Tracks.locket.rawValue)" }
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }
    
    func testCodingPlaybackReqest4() throws {
        
        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Playlists.crumb),
            offset: .uri(URIs.Tracks.locket),
            positionMS: 90
        )
    
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "context_uri": "\(URIs.Playlists.crumb.rawValue)",
                "offset": { "uri": "\(URIs.Tracks.locket.rawValue)" },
                "position_ms": 90
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }

    func testCodingPlaybackReqest5() throws {
        
        let uris = URIs.Tracks.array(.faces, .illWind, .fearless)
        let playbackRequest = PlaybackRequest(
            context: .uris(uris),
            offset: .position(0)
        )
        
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "uris": \(uris),
                "offset": { "position": 0 }
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )
        
    }
    
    func testCodingPlaybackReqest6() throws {
        
        let uris = URIs.Tracks.array(.faces, .illWind, .fearless)
        let playbackRequest = PlaybackRequest(
            context: .uris(uris),
            offset: .position(0),
            positionMS: 11_000
        )
        
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "uris": \(uris),
                "offset": { "position": 0 },
                "position_ms": 11000
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )
    }

    func testCodingPlaybackReqest7() throws {
        
        let uris = URIs.Tracks.array(.faces, .illWind, .fearless)
        let playbackRequest = PlaybackRequest(
            context: .uris(uris),
            offset: .uri(URIs.Tracks.fearless)
        )
        
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "uris": \(uris),
                "offset": { "uri": "\(URIs.Tracks.fearless.rawValue)" }
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }
    
    func testCodingPlaybackReqest8() throws {
        
        let uris = URIs.Tracks.array(.faces, .illWind, .fearless)
        let playbackRequest = PlaybackRequest(
            context: .uris(uris),
            offset: .uri(URIs.Tracks.fearless),
            positionMS: 50_000
        )
        
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "uris": \(uris),
                "offset": { "uri": "\(URIs.Tracks.fearless.rawValue)" },
                "position_ms": 50000
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )
    }
        
    func testCodingPlaybackReqest9() throws {
        
        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Playlists.crumb),
            offset: .position(10)
        )
    
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "context_uri": "\(URIs.Playlists.crumb.rawValue)",
                "offset": { "position": 10 }
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }
    
    func testCodingPlaybackReqest10() throws {
        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Playlists.crumb),
            offset: .position(10),
            positionMS: 100_000  // 100 seconds
        )
    
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "context_uri": "\(URIs.Playlists.crumb.rawValue)",
                "offset": { "position": 10 },
                "position_ms": 100000
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }
    
    // MARK: nil offset

    func testCodingPlaybackReqest11() throws {
        
        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Playlists.crumb),
            offset: nil
        )
    
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "context_uri": "\(URIs.Playlists.crumb.rawValue)"
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }
    
    func testCodingPlaybackReqest12() throws {
        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Playlists.crumb),
            offset: nil,
            positionMS: 56_234_040
        )
    
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "context_uri": "\(URIs.Playlists.crumb.rawValue)",
                "position_ms": 56234040
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }
    
    func testCodingPlaybackReqest13() throws {
        
        let uris = URIs.Episodes.array(
            .seanCarroll111, .samHarris213, .samHarris217
        )
        let playbackRequest = PlaybackRequest(
            context: .uris(uris),
            offset: nil
        )
    
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "uris": \(uris)
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )
        
    }
    
    func testCodingPlaybackReqest14() throws {
        
        let uris = URIs.Episodes.array(
            .joeRogan1531,
            .samHarris212
        )
        let playbackRequest = PlaybackRequest(
            context: .uris(uris),
            offset: nil,
            positionMS: 56_234_040
        )
    
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "uris": \(uris),
                "position_ms": 56234040
            }
            """
            .data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )
        
    }
    
    func testCodingPlaybackReqestSingleTrack() throws {
        
        let playbackRequest = PlaybackRequest(URIs.Tracks.because)
        
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "uris": ["\(URIs.Tracks.because.rawValue)"]
            }
            """.data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }
    
    func testCodingPlaybackReqestSingleTrackWithPositionMS() throws {
        
        let playbackRequest = PlaybackRequest(
            URIs.Tracks.anyColourYouLike,
            positionMS: 10_000
        )
        
        encodeDecode(playbackRequest, areEqual: ==)
        
        let data = """
            {
                "uris": ["\(URIs.Tracks.anyColourYouLike.rawValue)"],
                "position_ms": 10000
            }
            """.data(using: .utf8)!

        decodeEncodeDecode(
            data, type: PlaybackRequest.self,
            areEqual: self.compareToData(playbackRequest)
        )

    }
    
}
