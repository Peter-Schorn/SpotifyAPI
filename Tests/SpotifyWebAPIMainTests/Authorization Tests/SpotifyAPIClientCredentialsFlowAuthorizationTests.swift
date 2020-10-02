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
        
        Self.spotify.authorizationManager.deauthorize()
        
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
        XCTAssertEqual(
            didChangeCount, 2,
            "authorizationManagerDidChange should emit once when " +
            "deauthorizing and once when authorizing"
        )
        
    }
    
    
}
