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


protocol SpotifyAPIInsufficientScopeTests: SpotifyAPITests where
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager { }

extension SpotifyAPIInsufficientScopeTests {
    
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
            guard let localError = error as? SpotifyGeneralError else {
                XCTFail("should've received SpotifyGeneralError: \(error)")
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
                    XCTFail(
                        "should've received SpotifyGeneralError.insufficientScope: \(error)"
                    )
            }
        }

        let authorizationManagerDidChangeExpectation = XCTestExpectation(
            description: "authorizationManagerDidChange"
        )
        
        let authorizationManagerDidDeauthorizeExpectation = XCTestExpectation(
            description: "authorizationManagerDidDeauthorize"
        )

        let internalQueue = DispatchQueue(label: "internal")
        var cancellables: Set<AnyCancellable> = []
        
        var didChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didChangeCount += 1
                internalQueue.asyncAfter(deadline: .now() + 2) {
                    authorizationManagerDidChangeExpectation.fulfill()
                }
            })
            .store(in: &cancellables)
        
        var didDeauthorizeCount = 0
        Self.spotify.authorizationManagerDidDeauthorize
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didDeauthorizeCount += 1
                internalQueue.asyncAfter(deadline: .now() + 2) {
                    authorizationManagerDidDeauthorizeExpectation.fulfill()
                }
            })
            .store(in: &cancellables)
        
        let insufficientScopes: Set<Scope> = [
            .userFollowModify, .userLibraryModify, .userFollowRead,
            .userReadEmail, .userTopRead, .playlistModifyPrivate
        ]
        
        Self.spotify.authorizationManager.deauthorize()
        XCTAssertEqual(
            Self.spotify.authorizationManager.scopes , []
        )
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(for: [])
        )
        let randomScope = Scope.allCases.randomElement()!
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(
                for: [randomScope]
            ),
            "should not be authorized for \(randomScope.rawValue): " +
            "\(Self.spotify.authorizationManager)"
        )

        self.wait(
            for: [
                authorizationManagerDidDeauthorizeExpectation
            ],
            timeout: 10
        )

        internalQueue.sync {
            XCTAssertEqual(didDeauthorizeCount, 1)
            XCTAssertEqual(didChangeCount, 0)
        }

        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: insufficientScopes, showDialog: false
        )
        
        self.wait(
            for: [
                authorizationManagerDidChangeExpectation
            ],
            timeout: 10
        )
        internalQueue.sync {
            XCTAssertEqual(didChangeCount, 1)
        }
        
        let expectation = XCTestExpectation(
            description: "testInsufficientScope play track"
        )
        
        DistributedLock.player.lock()
        defer {
            DistributedLock.player.unlock()
        }

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
        
        
        internalQueue.sync {
            XCTAssertEqual(didDeauthorizeCount, 1)
            XCTAssertEqual(didChangeCount, 1)
        }
        
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
        
        let authorizationManagerDidChangeExpectation = XCTestExpectation(
            description: "authorizationManagerDidChange"
        )
        
        let authorizationManagerDidDeauthorizeExpectation = XCTestExpectation(
            description: "authorizationManagerDidDeauthorize"
        )

        let internalQueue = DispatchQueue(label: "internal")
        var cancellables: Set<AnyCancellable> = []
        
        var didChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didChangeCount += 1
                internalQueue.asyncAfter(deadline: .now() + 2) {
                    authorizationManagerDidChangeExpectation.fulfill()
                }
            })
            .store(in: &cancellables)
        
        var didDeauthorizeCount = 0
        Self.spotify.authorizationManagerDidDeauthorize
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didDeauthorizeCount += 1
                internalQueue.asyncAfter(deadline: .now() + 2) {
                    authorizationManagerDidDeauthorizeExpectation.fulfill()
                }
            })
            .store(in: &cancellables)

        
        Self.spotify.authorizationManager.deauthorize()
        XCTAssertEqual(
            Self.spotify.authorizationManager.scopes , []
        )
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(for: [])
        )
        let randomScope = Scope.allCases.randomElement()!
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(
                for: [randomScope]
            ),
            "should not be authorized for \(randomScope.rawValue): " +
            "\(Self.spotify.authorizationManager)"
        )

        self.wait(
            for: [
                authorizationManagerDidDeauthorizeExpectation
            ],
            timeout: 10
        )

        internalQueue.sync {
            XCTAssertEqual(didDeauthorizeCount, 1)
            XCTAssertEqual(didChangeCount, 0)
        }

        /// Every scope except the one we need: `playlistModifyPrivate`.
        let insufficientScopes = Scope.allCases.subtracting(
            [.playlistModifyPrivate]
        )

        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: insufficientScopes, showDialog: false
        )
        
        self.wait(
            for: [
                authorizationManagerDidChangeExpectation
            ],
            timeout: 10
        )
        internalQueue.sync {
            XCTAssertEqual(didChangeCount, 1)
        }
        
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

        internalQueue.sync {
            XCTAssertEqual(didDeauthorizeCount, 1)
            XCTAssertEqual(didChangeCount, 1)
        }

    }
    
}

// MARK: - Client -

final class SpotifyAPIAuthorizationCodeFlowInsufficientScopeTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIInsufficientScopeTests
{

    static let allTests = [
        ("testInsufficientScopeLocal", testInsufficientScopeLocal),
        ("testInsufficientScope2", testInsufficientScope2)
    ]

    func testInsufficientScopeLocal() { insufficientScopeLocal() }
    func testInsufficientScope2() { insufficientScope2() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEInsufficientScopeTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIInsufficientScopeTests
{

    static let allTests = [
        ("testInsufficientScopeLocal", testInsufficientScopeLocal),
        ("testInsufficientScope2", testInsufficientScope2)
    ]
    
    func testInsufficientScopeLocal() { insufficientScopeLocal() }
    func testInsufficientScope2() { insufficientScope2() }
    
}

// MARK: - Proxy -

final class SpotifyAPIAuthorizationCodeFlowProxyInsufficientScopeTests:
    SpotifyAPIAuthorizationCodeFlowProxyTests, SpotifyAPIInsufficientScopeTests
{

    static let allTests = [
        ("testInsufficientScopeLocal", testInsufficientScopeLocal),
        ("testInsufficientScope2", testInsufficientScope2)
    ]
    
    func testInsufficientScopeLocal() { insufficientScopeLocal() }
    func testInsufficientScope2() { insufficientScope2() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEProxyInsufficientScopeTests:
    SpotifyAPIAuthorizationCodeFlowPKCEProxyTests, SpotifyAPIInsufficientScopeTests
{

    static let allTests = [
        ("testInsufficientScopeLocal", testInsufficientScopeLocal),
        ("testInsufficientScope2", testInsufficientScope2)
    ]
    
    func testInsufficientScopeLocal() { insufficientScopeLocal() }
    func testInsufficientScope2() { insufficientScope2() }
    
}
