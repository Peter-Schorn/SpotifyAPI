import Foundation
import XCTest
@testable import SpotifyWebAPI
import _SpotifyAPITestUtilities

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
        
        encodeDecode(authManager)
        
    }
    
}
