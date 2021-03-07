import Foundation
import XCTest
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities

/// Test encoding and decoding the authorization managers
/// to ensure no data is lost during the encoding and decoding.
final class CodingAuthorizationCodeFlowManagerTests: XCTestCase {
    
    static var allTests = [
        (
            "testCodingAuthorizationCodeFlowManager",
            testCodingAuthorizationCodeFlowManager
        )
    ]
    
    func testCodingAuthorizationCodeFlowManager() throws {
        
        let authManager = AuthorizationCodeFlowManager(
            clientId: "the client id", clientSecret: "the client secret"
        )
        authManager.mockValues()
        
        encodeDecode(authManager, areEqual: ==)

        let copy = authManager.makeCopy()
        XCTAssertEqual(authManager, copy)
        
        let spotifyAPI = SpotifyAPI(authorizationManager: authManager)

        do {
            let data = try JSONEncoder().encode(spotifyAPI)
            let decoded = try JSONDecoder().decode(
                SpotifyAPI<AuthorizationCodeFlowManager>.self,
                from: data
            )
            let data2 = try JSONEncoder().encode(decoded)
            _ = data2
        
        } catch {
            XCTFail("\(error)")
        }
        
        
    }
    
}
