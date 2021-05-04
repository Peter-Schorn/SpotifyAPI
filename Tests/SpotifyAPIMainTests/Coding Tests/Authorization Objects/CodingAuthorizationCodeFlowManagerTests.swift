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
        
        let authManager2 = AuthorizationCodeFlowManager(
            clientId: "", clientSecret: ""
        )
        authManager2.mockValues()

        encodeDecode(authManager, areEqual: ==)
        encodeDecode(authManager2, areEqual: ==)

        let copy = authManager.makeCopy()
        XCTAssertEqual(authManager, copy)
        XCTAssertNotEqual(authManager, authManager2)
        
        let spotifyAPI = SpotifyAPI(authorizationManager: authManager)
        let spotifyAPI2 = SpotifyAPI(authorizationManager: authManager2)

        do {
            let data = try JSONEncoder().encode(spotifyAPI)
            let decoded = try JSONDecoder().decode(
                SpotifyAPI<AuthorizationCodeFlowManager>.self,
                from: data
            )
            let reEncodedData = try JSONEncoder().encode(decoded)
            
            let data2 = try JSONEncoder().encode(spotifyAPI2)
            let decoded2 = try JSONDecoder().decode(
                SpotifyAPI<AuthorizationCodeFlowManager>.self,
                from: data2
            )
            
            let reEncodedData2 = try JSONEncoder().encode(decoded2)
            
            _ = (reEncodedData, reEncodedData2)
            
            XCTAssertNotEqual(
                decoded.authorizationManager,
                decoded2.authorizationManager
            )
        
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
        
        let authManager2 = AuthorizationCodeFlowBackendManager(
            backend: AuthorizationCodeFlowProxyBackend(
                clientId: "",
                tokensURL: localHostURL,
                tokenRefreshURL: localHostURL
            )
        )
        authManager2.mockValues()

        encodeDecode(authManager, areEqual: ==)
        encodeDecode(authManager2, areEqual: ==)

        let copy = authManager.makeCopy()
        XCTAssertEqual(authManager, copy)
        XCTAssertNotEqual(authManager, authManager2)
        
        let spotifyAPI = SpotifyAPI(authorizationManager: authManager)
        let spotifyAPI2 = SpotifyAPI(authorizationManager: authManager2)

        do {
            let data = try JSONEncoder().encode(spotifyAPI)
            let decoded = try JSONDecoder().decode(
                SpotifyAPI<AuthorizationCodeFlowBackendManager<AuthorizationCodeFlowProxyBackend>>.self,
                from: data
            )
            let reEncodedData = try JSONEncoder().encode(decoded)
            
            let data2 = try JSONEncoder().encode(spotifyAPI2)
            let decoded2 = try JSONDecoder().decode(
                SpotifyAPI<AuthorizationCodeFlowBackendManager<AuthorizationCodeFlowProxyBackend>>.self,
                from: data2
            )
            
            let reEncodedData2 = try JSONEncoder().encode(decoded2)
            
            _ = (reEncodedData, reEncodedData2)
            
            XCTAssertNotEqual(
                decoded.authorizationManager,
                decoded2.authorizationManager
            )
        
        } catch {
            XCTFail("\(error)")
        }
        
        
    }
    
}
