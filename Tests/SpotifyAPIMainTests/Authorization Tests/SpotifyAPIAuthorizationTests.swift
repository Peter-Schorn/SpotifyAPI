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

// authorization tests that are common to all authorization managers
protocol SpotifyAPIAuthorizationTests: SpotifyAPITests {
    
    /// Makes an authorization manager with fake values.
    func makeFakeAuthManager() -> AuthorizationManager
    
    func deauthorizeReauthorize()
    

}

extension SpotifyAPIAuthorizationTests {
    
    func reassigningAuthorizationManager() {
        
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
        
        Self.spotify.authorizationManager = self.makeFakeAuthManager()
        XCTAssertEqual(didChangeCount, 1)
        XCTAssertEqual(didDeauthorizeCount, 0)

        Self.spotify.authorizationManager = currentAuthManager
        
        XCTAssertEqual(didChangeCount, 2)
        XCTAssertEqual(didDeauthorizeCount, 0)
        
        self.deauthorizeReauthorize()
        
    }

    func refreshTokens() {
        
        Self.spotify.authorizationManager.waitUntilAuthorized()

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 3))

        let authorizationManagerDidChangeExpectation = XCTestExpectation(
            description: "authorizationManagerDidChange"
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
            })
            .store(in: &cancellables)

        Self.spotify.authorizationManager.setExpirationDate(to: Date())
        XCTAssertTrue(
            Self.spotify.authorizationManager.accessTokenIsExpired(tolerance: 1),
            "access token should be expired after manually setting " +
            "expiration date: \(Self.spotify.authorizationManager)"
        )
        
        let refreshTokensExpectation = XCTestExpectation(
            description: "refreshTokens"
        )

        Self.spotify.authorizationManager.refreshTokens(
            onlyIfExpired: true,
            tolerance: 1
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in refreshTokensExpectation.fulfill() },
            receiveValue: {
                XCTAssertFalse(
                    Self.spotify.authorizationManager.accessTokenIsExpired(
                        tolerance: 3_480  // 58 minutes
                    ),
                    "access token should not be expired after just refreshing it " +
                    "\(Self.spotify.authorizationManager)"
                )
            }
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [refreshTokensExpectation], timeout: 60)
        
        self.wait(
            for: [authorizationManagerDidChangeExpectation],
            timeout: 10
        )
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 1,
                "authorizationManagerDidChange should only emit once"
            )
            XCTAssertEqual(
                didDeauthorizeCount, 0,
                "authorizationManagerDidDeauthorize should not emit "
                
            )
        }

        let retrieveTrackExpectation = XCTestExpectation(
            description: "retrieveTrack"
        )

        let track = URIs.Tracks.fearless
        
        Self.spotify.track(track)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in retrieveTrackExpectation.fulfill() },
                receiveValue: { track in
                    XCTAssertEqual(track.name, "Fearless")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [retrieveTrackExpectation], timeout: 60)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 3))
        
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 1,
                "authorizationManagerDidChange should only emit once"
            )
            XCTAssertEqual(
                didDeauthorizeCount, 0,
                "authorizationManagerDidDeauthorize should not emit "
                
            )
        }
    }

}

extension SpotifyAPIAuthorizationTests where
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager
{
    
    func deauthorizeReauthorize() {
        
        encodeDecode(Self.spotify.authorizationManager, areEqual: ==)
        
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
        
        let currentScopes = Self.spotify.authorizationManager.scopes
        
        Self.spotify.authorizationManager.deauthorize()
        
        self.wait(
            for: [
                authorizationManagerDidDeauthorizeExpectation
            ],
            timeout: 10
        )
        
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 0,
                "authorizationManagerDidChange should not emit"
            )
            XCTAssertEqual(
                didDeauthorizeCount, 1,
                "authorizationManagerDidDeauthorize should only emit once"
                
            )
        }
        
        XCTAssertEqual(Self.spotify.authorizationManager.scopes, [])
        XCTAssertFalse(Self.spotify.authorizationManager.isAuthorized(for: []))
        
        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: currentScopes, showDialog: false
        )
        
        XCTAssertTrue(
            Self.spotify.authorizationManager.isAuthorized(for: currentScopes),
            "\(Self.spotify.authorizationManager.scopes)"
        )
        XCTAssertEqual(Self.spotify.authorizationManager.scopes, currentScopes)
        XCTAssertFalse(
            Self.spotify.authorizationManager.accessTokenIsExpired(
                tolerance: 3_300  // 55 minutes
            ),
            "access token was expired after just re-authorizing it"
        )
        
        self.wait(
            for: [
                authorizationManagerDidChangeExpectation
            ],
            timeout: 10
        )
        
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 1,
                "authorizationManagerDidChange should only emit once"
            )
            XCTAssertEqual(
                didDeauthorizeCount, 1,
                "authorizationManagerDidDeauthorize should only emit once"
                
            )
        }
        
        encodeDecode(Self.spotify.authorizationManager, areEqual: ==)
        
    }
    
    
}
