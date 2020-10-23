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
        
        encodeDecode(Self.spotify.authorizationManager)
        
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
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            })
            .store(in: &Self.cancellables)
     
        self.wait(for: [expectation], timeout: 60)
        
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
        
        encodeDecode(Self.spotify.authorizationManager)
        
    }
    
    func testConvenienceInitializer() throws {
        
        let authManagerData = try JSONEncoder().encode(
            Self.spotify.authorizationManager
        )
        
        let decodedAuthManager = try JSONDecoder().decode(
            ClientCredentialsFlowManager.self,
            from: authManagerData
        )
        
        guard
            let accessToken = decodedAuthManager.accessToken,
            let expirationDate = decodedAuthManager.expirationDate
        else {
            XCTFail("none of the properties should be nil: \(decodedAuthManager)")
            return
        }
        
        let newAuthorizationManager = ClientCredentialsFlowManager(
            clientId: decodedAuthManager.clientId,
            clientSecret: decodedAuthManager.clientSecret,
            accessToken: accessToken,
            expirationDate: expirationDate
        )
        
        XCTAssertEqual(Self.spotify.authorizationManager, newAuthorizationManager)

    }
    
    
}
