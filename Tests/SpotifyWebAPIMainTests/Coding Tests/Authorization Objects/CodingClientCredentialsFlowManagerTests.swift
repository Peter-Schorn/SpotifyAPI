import Foundation
import XCTest
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities

/// Test encoding and decoding the authorization managers
/// to ensure no data is lost during the encoding and decoding.
final class CodingClientCredentialsFlowManagerTests: SpotifyAPITestCase {
    
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
        
        encodeDecode(clientCredentialsManager, areEqual: ==)
        
        let copy = clientCredentialsManager.makeCopy()
        XCTAssertEqual(clientCredentialsManager, copy)
        
        let spotifyAPI = SpotifyAPI(
            authorizationManager: clientCredentialsManager
        )
        
        do {
            let data = try JSONEncoder().encode(spotifyAPI)
            let decoded = try JSONDecoder().decode(
                SpotifyAPI<ClientCredentialsFlowManager>.self,
                from: data
            )
            let data2 = try JSONEncoder().encode(decoded)
            _ = data2
        
        } catch {
            XCTFail("\(error)")
        }
        
    }
    
    
}
