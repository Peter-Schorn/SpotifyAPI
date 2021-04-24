import Foundation
import XCTest
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

protocol BackendAuthorizeTests: SpotifyAPITests { }

extension BackendAuthorizeTests {
    
    func _setUpWithError() throws {
        Self.spotify.authorizationManager.deauthorize()
        XCTAssertEqual(
            Self.spotify.authorizationManager.scopes ?? [], []
        )
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(for: [])
        )
        let randomScope = Scope.allCases.randomElement()!
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(
                for: [randomScope]
            )
        )
        
        // ensure that the lambda server is running before each
        // test method
        try pingLambdaServer(url: spotifyBackendTokenURL)
        try pingLambdaServer(url: spotifyBackendTokenRefreshURL)
        
    }

    func makeRequests() {
        
        // MARK: Make API Request

        let expectation1 = XCTestExpectation(
            description: "testAuthorizeAndRefresh first request"
        )
        
        let album = URIs.Albums.darkSideOfTheMoon
        Self.spotify.album(album)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation1.fulfill() },
                receiveValue: { album in
                    XCTAssertEqual(album.name, "The Dark Side of the Moon")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation1], timeout: 120)

        // MARK: Make access token expired
        
        Self.spotify.authorizationManager.setExpirationDate(to: Date())
        
        // ensure `authorizationManagerDidChange` emits
        // after the tokens get refreshed in the request below.
        var authChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            authChangeCount += 1
        })
        .store(in: &cancellables)
        
        // MARK: Make another request

        let expectation2 = XCTestExpectation(
            description: "testAuthorizeAndRefresh request with expired token"
        )
        
        let artist = URIs.Artists.crumb
        Self.spotify.artist(artist)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation2.fulfill() },
                receiveValue: { artist in
                    XCTAssertEqual(artist.name, "Crumb")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation2], timeout: 120)
        
        XCTAssertEqual(
            authChangeCount, 1,
            "authorizationManagerDidChange should emit exactly once"
        )

    }

    
}

final class SpotifyAPIAuthorizationCodeFlowProxyBackendAuthorizeTests:
    SpotifyAPIAuthorizationCodeFlowProxyTests, BackendAuthorizeTests
{

    static let allTests = [
        ("testMakeRequests", testMakeRequests)
    ]
    
    override class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases, showDialog: Bool = false
    ) {
      // we authorize before each instance method instead
    }

    override func setUpWithError() throws {
        try self._setUpWithError()
        Self.spotify.authorizationManager.authorizeAndWaitForTokens()
    }
    
    func testMakeRequests() {
        makeRequests()
    }

}

final class SpotifyAPIAuthorizationCodePKCEFlowProxyBackendAuthorizeTests:
    SpotifyAPIAuthorizationCodeFlowPKCEProxyTests, BackendAuthorizeTests
{

    static let allTests = [
        ("testMakeRequests", testMakeRequests)
    ]

    override class func setupAuthorization(scopes: Set<Scope> = Scope.allCases) {
        // we authorize before each instance method instead
    }
    
    override func setUpWithError() throws {
        try self._setUpWithError()
        Self.spotify.authorizationManager.authorizeAndWaitForTokens()
    }
    
    func testMakeRequests() {
        makeRequests()
    }

}

