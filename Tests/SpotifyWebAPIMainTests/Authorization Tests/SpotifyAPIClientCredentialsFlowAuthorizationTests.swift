import Foundation
import XCTest
import Combine
import SpotifyAPITestUtilities
@testable import SpotifyWebAPI

final class SpotifyAPIClientCredentialsFlowAuthorizationTests:
    SpotifyAPIClientCredentialsFlowTests
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

        XCTAssertTrue(Self.spotify.authorizationManager.isAuthorized())
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(
                        for: [Scope.allCases.randomElement()!]
            )
        )
        
        Self.spotify.authorizationManager.deauthorize()
        
        XCTAssertFalse(Self.spotify.authorizationManager.isAuthorized())
        
        let expectation = XCTestExpectation(
            description: "testDeauthorizeReauthorize"
        )
        
        Self.spotify.authorizationManager.authorize()
            .XCTAssertNoFailure()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &Self.cancellables)
     
        wait(for: [expectation], timeout: 60)
        
        XCTAssertTrue(Self.spotify.authorizationManager.isAuthorized())
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(
                        for: [Scope.allCases.randomElement()!]
            )
        )

        XCTAssertEqual(
            didChangeCount, 2,
            "authorizationManagerDidChange should emit once when " +
            "deauthorizing and once when authorizing"
        )
        
    }
    
    
}
