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
@testable import SpotifyWebAPI

final class SpotifyAPIClientCredentialsFlowAuthorizationTests:
    SpotifyAPIClientCredentialsFlowTests
{
    
    static var allTests = [
        ("testDeauthorizeReauthorize", testDeauthorizeReauthorize),
        ("testCodingSpotifyAPI", testCodingSpotifyAPI),
        ("testReassigningAuthorizationManager", testReassigningAuthorizationManager),
        ("testConvenienceInitializer", testConvenienceInitializer)
    ]
    
    func testDeauthorizeReauthorize() {
        
        encodeDecode(Self.spotify.authorizationManager, areEqual: ==)
        
        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)

        var didDeauthorizeCount = 0
        Self.spotify.authorizationManagerDidDeauthorize
            .sink(receiveValue: {
                didDeauthorizeCount += 1
            })
            .store(in: &cancellables)
        
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
            didChangeCount, 1,
            "authorizationManagerDidChange should only emit once"
        )
        XCTAssertEqual(
            didDeauthorizeCount, 1,
            "authorizationManagerDidDeauthorize should only emit once"
        )
        
        encodeDecode(Self.spotify.authorizationManager, areEqual: ==)
        
    }
    
    func testCodingSpotifyAPI() throws {
        
        let spotifyAPIData = try JSONEncoder().encode(Self.spotify)
        
        let decodedSpotifyAPI = try JSONDecoder().decode(
            SpotifyAPI<ClientCredentialsFlowManager>.self,
            from: spotifyAPIData
        )
        
        Self.spotify = decodedSpotifyAPI
        
        self.testDeauthorizeReauthorize()
        
    }
    
    func testReassigningAuthorizationManager() {
        
        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)
        
        var didDeauthorizeCount = 0
        Self.spotify.authorizationManagerDidDeauthorize
            .sink(receiveValue: {
                didDeauthorizeCount += 1
            })
            .store(in: &cancellables)
        
        let currentAuthManager = Self.spotify.authorizationManager
        
        Self.spotify.authorizationManager = .init(
            clientId: "client id",
            clientSecret: "client secret"
        )

        Self.spotify.authorizationManager = currentAuthManager
        
        XCTAssertEqual(didChangeCount, 2)
        XCTAssertEqual(didDeauthorizeCount, 0)
        
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
    
    override class func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }
    
}
