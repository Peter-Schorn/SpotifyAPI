import Foundation
import XCTest
import Combine
import SpotifyAPITestUtilities
@testable import SpotifyWebAPI

final class SpotifyAPIAuthorizationCodeFlowAuthorizationTests:
    SpotifyAPIAuthorizationCodeFlowTests
{
    
    static var allTests = [
        ("testDeauthorizeReauthorize", testDeauthorizeReauthorize)
    ]
    
    func testDeauthorizeReauthorize() {
        
        var didChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            .sink(receiveValue: {
                didChangeCount += 1
            })
            .store(in: &Self.cancellables)
        
        let currentScopes = Self.spotify.authorizationManager.scopes ?? []
        
        Self.spotify.authorizationManager.deauthorize()
        
        Self.spotify.authorizeAndWaitForTokens(
            scopes: currentScopes, showDialog: false
        )
        
        XCTAssertEqual(
            didChangeCount, 2,
            "authorizationManagerDidChange should emit once when " +
            "deauthorizing and once when authorizing"
        )
        
    }
    
    
}
