import Foundation
import XCTest
@testable import SpotifyWebAPI

/// Test encoding and decoding the authorization managers
/// to ensure no data is lost during the encoding and decoding.
final class CodingAuthorizationManagersTests: XCTestCase {
    
    static var allTests = [
        (
            "testCodingAuthorizationCodeFlowManager",
            testCodingAuthorizationCodeFlowManager
        ),
        (
            "testCodingClientCredentialsFlowManager",
            testCodingClientCredentialsFlowManager
        )
    ]
    
    func testCodingAuthorizationCodeFlowManager() throws {
        
        let authManager = AuthorizationCodeFlowManager(
            clientId: "the client id", clientSecret: "the client secret"
        )
        authManager.mockValues()
        
        encodeDecode(authManager)
        
    }
    
    func testCodingClientCredentialsFlowManager() throws {
        
        let clientCredentialsManager = ClientCredentialsFlowManager(
            clientId: "the client id", clientSecret: "the client secret"
        )
        clientCredentialsManager.mockValues()
        
        encodeDecode(clientCredentialsManager)
        
    }
    
    
}
