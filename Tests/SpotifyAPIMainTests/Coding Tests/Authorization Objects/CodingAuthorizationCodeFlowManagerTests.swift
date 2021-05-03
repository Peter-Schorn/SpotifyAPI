import Foundation
import XCTest
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities

/// Test encoding and decoding the authorization managers
/// to ensure no data is lost during the encoding and decoding.
final class CodingAuthorizationCodeFlowManagerTests: SpotifyAPITestCase {
    
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
    
    func testCodingAuthorizationCodeFlowManagerProxy() throws {
        
        let authManager = AuthorizationCodeFlowBackendManager(
            backend: AuthorizationCodeFlowProxyBackend(
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
                SpotifyAPI<AuthorizationCodeFlowBackendManager<AuthorizationCodeFlowProxyBackend>>.self,
                from: data
            )
            let data2 = try JSONEncoder().encode(decoded)
            _ = data2
        
        } catch {
            XCTFail("\(error)")
        }
        
        
    }
    
}
