import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyContent


final class CodingPlaybackRequestTests: XCTestCase {
    
    static var allTests = [
        ("testCodingPlaybackReqest", testCodingPlaybackReqest)
    ]

    override class func setUp() {
        SpotifyDecodingError.dataDumpfolder = URL(fileURLWithPath:
            "/Users/pschorn/Desktop/"
        )
    }
    
    func testCodingPlaybackReqest() throws {
        
        do {
            let playbackRequest = PlaybackRequest(
                context: .contextURI(URIS.Album.jinx),
                offset: .position(3),  // "fall down"
                positionMS: 50_000  // 50 seconds
            )
        
            if let dataString = encodeDecode(playbackRequest) {
                print("\n\(dataString)\n")
            }
        }
        do {
            let playbackRequest = PlaybackRequest(
                context: .uris([
                    URIS.Track.faces,
                    URIS.Track.illWind,
                    URIS.Track.fearless
                ]),
                offset: .uri(URIS.Track.fearless),
                positionMS: 50_000  // 50 seconds
            )
            
            if let dataString = encodeDecode(playbackRequest) {
                print("\n\(dataString)\n")
            }

        }
            
        do {
            let playbackRequest = PlaybackRequest(
                context: .contextURI(URIS.Playlist.crumb),
                offset: .position(10),
                positionMS: 100_000  // 100 seconds
            )
        
            if let dataString = encodeDecode(playbackRequest) {
                print("\n\(dataString)\n")
            }
        }
        do {
            let playbackRequest = PlaybackRequest(
                context: .contextURI(URIS.Playlist.crumb),
                offset: .uri(URIS.Track.locket),
                positionMS: 100_000  // 100 seconds
            )
        
            if let dataString = encodeDecode(playbackRequest) {
                print("\n\(dataString)\n")
            }
        }
        
        
    }
    
    
}
