import Foundation
import XCTest
import SpotifyWebAPI
import SpotifyExampleContent
import SpotifyAPITestUtilities

final class CodingSpotifyPlayerErrorTests: SpotifyAPITestCase {
    
    static let allTests = [
        ("testCodingVolumeControlDisallow", testCodingVolumeControlDisallow)
    ]
    
    func testCodingVolumeControlDisallow() throws {
        
        let errorData = """
            {
              "error": {
                "status": 403,
                "message": "Player command failed: Cannot control device volume",
                "reason": "VOLUME_CONTROL_DISALLOW"
              }
            }
            """.data(using: .utf8)!
        
        decodeEncodeDecode(errorData, type: SpotifyPlayerError.self, areEqual: ==)
        
        let error = try JSONDecoder().decode(
            SpotifyPlayerError.self, from: errorData
        )
        
        XCTAssertEqual(error.statusCode, 403)
        XCTAssertEqual(
            error.message,
            "Player command failed: Cannot control device volume"
        )
        XCTAssertEqual(error.reason, .volumeControlDisallow)

    }

}
