import Foundation
import XCTest
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities

/// Test encoding and decoding the authorization managers
/// to ensure no data is lost during the encoding and decoding.
final class CodingAuthorizationCodeFlowPKCEManagerTests: SpotifyAPITestCase {
    
    static let allTests = [
        (
            "testCodingAuthorizationCodeFlowManagerClient",
            testCodingAuthorizationCodeFlowManagerClient
        ),
        (
            "testCodingAuthorizationCodeFlowManagerProxy",
            testCodingAuthorizationCodeFlowManagerProxy
        )
    ]
    
    func testCodingAuthorizationCodeFlowManagerClient() throws {
        
        let authManager = AuthorizationCodeFlowPKCEManager(
            clientId: "the client id"
        )
        authManager.mockValues()
        
        encodeDecode(authManager, areEqual: ==)

        let copy = authManager.makeCopy()
        XCTAssertEqual(authManager, copy)
        
        let spotifyAPI = SpotifyAPI(authorizationManager: authManager)

        do {
            let data = try JSONEncoder().encode(spotifyAPI)
            let decoded = try JSONDecoder().decode(
                SpotifyAPI<AuthorizationCodeFlowPKCEManager>.self,
                from: data
            )
            let data2 = try JSONEncoder().encode(decoded)
            _ = data2
        
        } catch {
            XCTFail("\(error)")
        }
        
        
    }
    
    func testCodingAuthorizationCodeFlowManagerProxy() throws {
        
        let authManager = AuthorizationCodeFlowPKCEBackendManager(
            backend: AuthorizationCodeFlowPKCEProxyBackend(
                clientId: "the client id",
                tokensURL: localHostURL,
                tokenRefreshURL: localHostURL
            )
        )
        authManager.mockValues()
        
        encodeDecode(authManager, areEqual: ==)

        let copy = authManager.makeCopy()
        XCTAssertEqual(authManager, copy)
        
        let spotifyAPI = SpotifyAPI(authorizationManager: authManager)

        do {
            let data = try JSONEncoder().encode(spotifyAPI)
            let decoded = try JSONDecoder().decode(
                SpotifyAPI<AuthorizationCodeFlowPKCEBackendManager<AuthorizationCodeFlowPKCEProxyBackend>>.self,
                from: data
            )
            let data2 = try JSONEncoder().encode(decoded)
            _ = data2
        
        } catch {
            XCTFail("\(error)")
        }
        
        
    }
    
}
