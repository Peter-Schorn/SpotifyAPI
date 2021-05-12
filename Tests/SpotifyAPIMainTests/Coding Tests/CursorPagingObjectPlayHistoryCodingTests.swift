import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyExampleContent
import SpotifyAPITestUtilities

final class CodingCursorPagingObjectPlayHistoryTests: SpotifyAPITestCase {
    
    
    func testCoding() throws {
        
        let playHistory = CursorPagingObject.sampleRecentlyPlayed
        try encodeDecode(playHistory, areEqual: { lhs, rhs in
            for x in [playHistory, lhs, rhs] {
                try self.checkPlayHistory(x)
            }
            XCTAssertEqual(lhs, playHistory)
            XCTAssertEqual(playHistory, rhs)
            return lhs == rhs
        })

    }
    
    func checkPlayHistory(
        _ playHistory: CursorPagingObject<PlayHistory>
    ) throws {
        
        XCTAssertEqual(
            playHistory.href,
            URL(string: "https://api.spotify.com/v1/me/player/recently-played?before=1600723343395&limit=45")!
        )
        XCTAssertEqual(
            playHistory.next,
            URL(string: "https://api.spotify.com/v1/me/player/recently-played?before=1600459749010&limit=45")!
        )
        XCTAssertEqual(playHistory.limit, 45)
        
        let cursors = try XCTUnwrap(playHistory.cursors)
        XCTAssertEqual(cursors.before, "1600459749010")
        XCTAssertEqual(cursors.after, "1600711411419")
        

        let items = playHistory.items
        try XCTSkipIf(items.count != 45)
        
        // MARK: First Track
        do {
            let bones = items[0]
            XCTAssertEqual(
                bones.playedAt.timeIntervalSince1970,
                1600729411,
                accuracy: 43_200
            )
            
            let context = try XCTUnwrap(bones.context)
            XCTAssertEqual(
                context.uri,
                "spotify:playlist:33yLOStnp2emkEA76ew1Dz"
            )
            XCTAssertEqual(
                context.href,
                URL(string: "https://api.spotify.com/v1/playlists/33yLOStnp2emkEA76ew1Dz")!
            )
            XCTAssertEqual(context.type, .playlist)
            
            let track = bones.track
            XCTAssertEqual(track.name, "Bones")
            XCTAssertEqual(track.uri, "spotify:track:4rL1OrbBCOD5hDgXWPCqW3")
            XCTAssertEqual(track.album?.name, "Crumb")
            XCTAssertEqual(track.artists?.first?.name, "Crumb")

        }
        
        // MARK: Tenth Track
        do {
            let echoes = items[10]
            XCTAssertEqual(
                echoes.playedAt.timeIntervalSince1970,
                1600604204,
                accuracy: 43_200
            )
            
            XCTAssertNil(echoes.context)
            
            let track = echoes.track
            XCTAssertEqual(track.name, "Echoes")
            XCTAssertEqual(track.uri, "spotify:track:7kriFJLY2KOhw5en9iI2jb")
            XCTAssertEqual(track.album?.name, "Meddle")
            XCTAssertEqual(track.artists?.first?.name, "Pink Floyd")
        }

        // MARK: 44th Track
        do {
            let breathe = items[44]
            XCTAssertEqual(
                breathe.playedAt.timeIntervalSince1970,
                1600477749,
                accuracy: 43_200
            )
            
            let context = try XCTUnwrap(breathe.context)
            XCTAssertEqual(
                context.uri,
                "spotify:album:4LH4d3cOWNNsVw41Gqt2kv"
            )
            XCTAssertEqual(
                context.href,
                URL(string: "https://api.spotify.com/v1/albums/4LH4d3cOWNNsVw41Gqt2kv")!
            )
            XCTAssertEqual(context.type, .album)
            
            let track = breathe.track
            XCTAssertEqual(track.name, "Breathe (In the Air)")
            XCTAssertEqual(track.uri, "spotify:track:2ctvdKmETyOzPb2GiJJT53")
            XCTAssertEqual(track.album?.name, "The Dark Side of the Moon")
            XCTAssertEqual(track.artists?.first?.name, "Pink Floyd")
        }

    }
    
    
}
