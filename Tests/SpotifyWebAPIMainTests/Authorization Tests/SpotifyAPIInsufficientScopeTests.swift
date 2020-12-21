import Foundation
import XCTest
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import SpotifyAPITestUtilities
import SpotifyExampleContent
@testable import SpotifyWebAPI


protocol SpotifyAPIInsufficientScopeTests: SpotifyAPITests { }

extension SpotifyAPIInsufficientScopeTests where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{

    func insufficientScope() {

        var didChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            .sink(receiveValue: {
                didChangeCount += 1
            })
            .store(in: &Self.cancellables)
        
        var didDeauthorizeCount = 0
        Self.spotify.authorizationManagerDidDeauthorize
            .sink(receiveValue: {
                didDeauthorizeCount += 1
            })
            .store(in: &Self.cancellables)
        
        let previousScopes = Self.spotify.authorizationManager.scopes ?? []
        
        let scopes: Set<Scope> = [
            .userFollowModify, .userLibraryModify, .userFollowRead,
            .userReadEmail, .userTopRead, .playlistModifyPrivate
        ]
        
        Self.spotify.authorizationManager.deauthorize()

        XCTAssertEqual(didDeauthorizeCount, 1)

        Self.authorizeAndWaitForTokens(scopes: scopes)
        
        XCTAssertEqual(didChangeCount, 1)
        
        let expectation = XCTestExpectation(description: "testInsufficientScope")
        
        Self.spotify.play(.init(URIs.Tracks.breathe))
            .sink(
                receiveCompletion: { completion in
                    defer { expectation.fulfill() }
                    guard case .failure(let error) = completion else {
                        XCTFail("should've finished with error")
                        return
                    }
                    guard let localError = error as? SpotifyLocalError else {
                        XCTFail("should've received SpotifyLocalError: \(error)")
                        return
                    }
                    switch localError {
                        case .insufficientScope(let requiredScopes, let authorizedScopes):
                            XCTAssertEqual(requiredScopes, [.userModifyPlaybackState])
                            XCTAssertEqual(authorizedScopes, scopes)
                        default:
                            XCTFail("unexpected error: \(localError)")
                    }
                },
                receiveValue: {
                    XCTFail("should not receive value")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
        Self.authorizeAndWaitForTokens(scopes: previousScopes)
        
        XCTAssertEqual(didChangeCount, 2)
        
    }
    

}

final class SpotifyAPIAuthorizationCodeFlowInsufficientScopeTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIInsufficientScopeTests
{

    static let allTests = [
        ("testInsufficientScope", testInsufficientScope)
    ]
    
    func testInsufficientScope() { insufficientScope() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEInsufficientScopeTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIInsufficientScopeTests
{

    static let allTests = [
        ("testInsufficientScope", testInsufficientScope)
    ]
    
    func testInsufficientScope() { insufficientScope() }
    
}
