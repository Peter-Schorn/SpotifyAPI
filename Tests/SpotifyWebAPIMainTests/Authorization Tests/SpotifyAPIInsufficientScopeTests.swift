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
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager
{
    
    func makeRequestWithoutAuthorization() {

        func receiveCompletion(
            _ completion: Subscribers.Completion<Error>
        ) {
            guard case .failure(let error) = completion else {
                XCTFail("should've finished with error")
                return
            }
            guard let spotifyLocalError = error as? SpotifyLocalError else {
                XCTFail("should've received SpotifyLocalError: \(error)")
                return
            }
            switch spotifyLocalError {
                case .unauthorized(_):
                    break
                default:
                    XCTFail(
                        "should've received unauthorized error: " +
                        "\(spotifyLocalError)"
                    )
            }
        }

        let previousScopes = Self.spotify.authorizationManager.scopes ?? []
        
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
        
        let expectation = XCTestExpectation(
            description: "requestWithoutAuthorization"
        )
        
        Self.spotify.show(URIs.Shows.samHarris)
            .sink(
                receiveCompletion: { completion in
                    receiveCompletion(completion)
                    expectation.fulfill()
                },
                receiveValue: { show in
                    XCTFail("should not receive value: \(show)")
                }

            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: previousScopes,
            showDialog: false
        )

    }

    /// Make a request to a method that will fail before
    /// any network request is made because the required
    /// scopes are known in advance.
    func insufficientScopeLocal() {

        func receiveCompletion(
            _ completion: Subscribers.Completion<Error>
        ) {
            guard case .failure(let error) = completion else {
                XCTFail("should've finished with error")
                return
            }
            guard let localError = error as? SpotifyLocalError else {
                XCTFail("should've received SpotifyLocalError: \(error)")
                return
            }
            switch localError {
                case .insufficientScope(
                    let requiredScopes, let authorizedScopes
                ):
                    XCTAssertEqual(
                        requiredScopes, [.userModifyPlaybackState]
                    )
                    XCTAssertEqual(authorizedScopes, insufficientScopes)
                default:
                    XCTFail("unexpected error: \(localError)")
            }
        }

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
        
        let previousScopes = Self.spotify.authorizationManager.scopes ?? []
        
        let insufficientScopes: Set<Scope> = [
            .userFollowModify, .userLibraryModify, .userFollowRead,
            .userReadEmail, .userTopRead, .playlistModifyPrivate
        ]
        
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

        XCTAssertEqual(didDeauthorizeCount, 1)
        XCTAssertEqual(didChangeCount, 0)

        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: insufficientScopes, showDialog: false
        )
        
        XCTAssertEqual(didChangeCount, 1)
        
        let expectation = XCTestExpectation(
            description: "testInsufficientScope play track"
        )
        
        Self.spotify.play(.init(URIs.Tracks.breathe))
            .sink(
                receiveCompletion: { completion in
                    receiveCompletion(completion)
                    expectation.fulfill()
                },
                receiveValue: {
                    XCTFail("should not receive value")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: previousScopes, showDialog: false
        )
        
        XCTAssertEqual(didDeauthorizeCount, 1)
        XCTAssertEqual(didChangeCount, 2)
        
    }
    
    
    func insufficientScope2() {
        
        func receiveCompletion(
            _ completion: Subscribers.Completion<Error>
        ) {
            guard case .failure(let error) = completion else {
                XCTFail("should've finished with error")
                return
            }
            guard let spotifyError = error as? SpotifyError else {
                XCTFail("should've received SpotifyError: \(error)")
                return
            }
            XCTAssertEqual(
                spotifyError.message,
                "Insufficient client scope"
            )
            XCTAssertEqual(spotifyError.statusCode, 403)
        }
        
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
        
        let previousScopes = Self.spotify.authorizationManager.scopes ?? []

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

        XCTAssertEqual(didDeauthorizeCount, 1)
        XCTAssertEqual(didChangeCount, 0)

        /// Every scope except the one we need: `playlistModifyPrivate`.
        let insufficientScopes = Scope.allCases.subtracting(
            [.playlistModifyPrivate]
        )

        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: insufficientScopes, showDialog: false
        )
        
        XCTAssertEqual(didChangeCount, 1)
        
        /*
         Creating a public playlist for a user requires authorization
         of the playlistModifyPublic scope; creating a private playlist
         requires the playlistModifyPrivate scope.
         */
        let playlistDetails = PlaylistDetails(
            name: "My private playlist",
            isPublic: false,
            isCollaborative: false,
            description: Date().description(with: .current)
        )
        
        let expectation = XCTestExpectation(
            description: "insufficientScope2 create playlist"
        )

        Self.spotify.currentUserProfile()
            .XCTAssertNoFailure()
            .flatMap { user -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                return Self.spotify.createPlaylist(
                    for: user.uri,
                    playlistDetails
                )
            }
            .sink(
                receiveCompletion: { completion in
                    receiveCompletion(completion)
                    expectation.fulfill()
                },
                receiveValue: { playlist in
                    XCTFail("shouldn't receive value: \(playlist)")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: previousScopes, showDialog: false
        )
        
        XCTAssertEqual(didDeauthorizeCount, 1)
        XCTAssertEqual(didChangeCount, 2)

    }
    
}

// MARK: - Client -

final class SpotifyAPIAuthorizationCodeFlowInsufficientScopeTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIInsufficientScopeTests
{

    static let allTests = [
        ("testMakeRequestWithoutAuthorization", testMakeRequestWithoutAuthorization),
        ("testInsufficientScopeLocal", testInsufficientScopeLocal),
        ("testInsufficientScope2", testInsufficientScope2)
    ]

    func testMakeRequestWithoutAuthorization() { makeRequestWithoutAuthorization() }
    func testInsufficientScopeLocal() { insufficientScopeLocal() }
    func testInsufficientScope2() { insufficientScope2() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEInsufficientScopeTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIInsufficientScopeTests
{

    static let allTests = [
        ("testMakeRequestWithoutAuthorization", testMakeRequestWithoutAuthorization),
        ("testInsufficientScopeLocal", testInsufficientScopeLocal),
        ("testInsufficientScope2", testInsufficientScope2)
    ]

    func testMakeRequestWithoutAuthorization() { makeRequestWithoutAuthorization() }
    func testInsufficientScopeLocal() { insufficientScopeLocal() }
    func testInsufficientScope2() { insufficientScope2() }
    
}

// MARK: - Proxy -

final class SpotifyAPIAuthorizationCodeFlowProxyInsufficientScopeTests:
    SpotifyAPIAuthorizationCodeFlowProxyTests, SpotifyAPIInsufficientScopeTests
{

    static let allTests = [
        ("testMakeRequestWithoutAuthorization", testMakeRequestWithoutAuthorization),
        ("testInsufficientScopeLocal", testInsufficientScopeLocal),
        ("testInsufficientScope2", testInsufficientScope2)
    ]

    func testMakeRequestWithoutAuthorization() { makeRequestWithoutAuthorization() }
    func testInsufficientScopeLocal() { insufficientScopeLocal() }
    func testInsufficientScope2() { insufficientScope2() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEProxyInsufficientScopeTests:
    SpotifyAPIAuthorizationCodeFlowPKCEProxyTests, SpotifyAPIInsufficientScopeTests
{

    static let allTests = [
        ("testMakeRequestWithoutAuthorization", testMakeRequestWithoutAuthorization),
        ("testInsufficientScopeLocal", testInsufficientScopeLocal),
        ("testInsufficientScope2", testInsufficientScope2)
    ]

    func testMakeRequestWithoutAuthorization() { makeRequestWithoutAuthorization() }
    func testInsufficientScopeLocal() { insufficientScopeLocal() }
    func testInsufficientScope2() { insufficientScope2() }
    
}
