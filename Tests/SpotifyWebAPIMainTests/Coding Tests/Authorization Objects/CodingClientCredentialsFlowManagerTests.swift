import Foundation
import XCTest
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities

/// Test encoding and decoding the authorization managers
/// to ensure no data is lost during the encoding and decoding.
final class CodingClientCredentialsFlowManagerTests: XCTestCase {
    
    static var allTests = [
        (
            "testCodingClientCredentialsFlowManager",
            testCodingClientCredentialsFlowManager
        )
    ]
    
    func testCodingClientCredentialsFlowManager() throws {
        
        let clientCredentialsManager = ClientCredentialsFlowManager(
            clientId: "the client id", clientSecret: "the client secret"
        )
        clientCredentialsManager.mockValues()
        
        encodeDecode(clientCredentialsManager)
        
    }
    
    
}
