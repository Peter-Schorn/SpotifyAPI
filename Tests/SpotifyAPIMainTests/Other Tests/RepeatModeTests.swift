import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyAPITestUtilities

class RepeatModeTests: SpotifyAPITestCase {
    
    static let allTests = [
        ("testCycle", testCycle),
        ("testCycled", testCycled)
    ]
    
    func testCycle() {

        // off
        // context
        // track

        var repeatMode = RepeatMode.off
        repeatMode.cycle()
        XCTAssertEqual(repeatMode, .context)
        repeatMode.cycle()
        XCTAssertEqual(repeatMode, .track)
        repeatMode.cycle()
        XCTAssertEqual(repeatMode, .off)

    }
    
    func testCycled() {
            
        let context = RepeatMode.context
        let track = context.cycled()
        XCTAssertEqual(track, .track)
        let off = track.cycled()
        XCTAssertEqual(off, .off)
        let context2 = off.cycled()
        XCTAssertEqual(context2, .context)

    }

}
