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
import SpotifyExampleContent
 
 
/**
 Test refreshing the tokens multiple times asynchronously to ensure
 that they only actually get refreshed once.
 
 These tests are also used in conjunction with the thread sanitizer
 to ensure there are no race conditions or other thread-safety issues.
 */
protocol SpotifyAPIRefreshTokensConcurrentTests: SpotifyAPITests { }

extension SpotifyAPIRefreshTokensConcurrentTests {
    
    func concurrentTokensRefresh() {
        self.continueAfterFailure = false
        for i in 0..<20 {
            SpotifyAPITestCase.selectNetworkAdaptor()
            Self.spotify.authorizationManager.setExpirationDate(to: Date())
            print("\n--- TOP LEVEL \(i) ---\n")
            self.concurrentTokensRefreshCore(topLevel: i)
            sleep(1)
        }
    }
    
    private func concurrentTokensRefreshCore(topLevel: Int) {
        
        var cancellables: Set<AnyCancellable> = []
        
        let internalQueue = DispatchQueue(
            label: "asyncTokensRefresh internalQueue"
        )
        
        var didChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            // .receiveOnMain()
            .print("Self.spotify.authorizationManagerDidChange print")
            .sink(receiveValue: {
//                Self.spotify.assertNotOnUpdateAuthInfoDispatchQueue()
//                print(
//                    "spotify.authorizationManagerDidChange.sink; " +
//                    "top level: \(topLevel)"
//                )
//
//                print("WILL print Self.spotify.authorizationManager")
//                print("\(Self.spotify.authorizationManager)")
//                print("DID print Self.spotify.authorizationManager")

                internalQueue.sync {
                    didChangeCount += 1
                }
//                print("after internalQueue.sync")
            })
            .store(in: &cancellables)

        var updatedAuthInfo: AuthorizationManager? = nil
         
        let iMax = 3
        let jMax = 3
        
        let expectations: [[XCTestExpectation]] = (0..<iMax).map { i in
            (0..<jMax).map { j in
                .init(description: "asyncTokensRefresh i: \(i); j: \(j)")
            }
        }
        
        let concurrentQueue = DispatchQueue(
            label: "asyncTokensRefresh concurrentQueue",
            attributes: .concurrent
        )
        
        concurrentQueue.sync {
            DispatchQueue.concurrentPerform(iterations: iMax) { i in
                Self.spotify.assertNotOnUpdateAuthInfoDispatchQueue()
              
//                print("begin i: \(i)")
                
                if i > 5 && Bool.random() {
                    // 0.001...0.01 seconds
                    usleep(UInt32.random(in: 1_000...10_000))
                }

                for j in 0..<jMax {

//                    print("begin i: \(i); j: \(j)")
                    
                    var sink: String? = nil
                    
                    // check for data races when accessing these properties.
//                    print("asyncTokensRefresh waiting to pour into sink")
                    sink = Self.spotify.authorizationManager.accessToken
                    sink = "\(Self.spotify.authorizationManager.scopes as Any)"
                    sink = "\(Self.spotify.authorizationManager.expirationDate as Any)"
//                    print("asyncTokensRefresh finished pouring into sink")
                    
                    let cancellable = Self.spotify.authorizationManager.refreshTokens(
                        onlyIfExpired: true, tolerance: 120
                    )
                    .handleEvents(receiveCancel: {
                        XCTFail(
                            "refreshTokens received cancel for i: \(i); j: \(j)"
                        )
                    })
                    .XCTAssertNoFailure()
                    .sink(
                        receiveCompletion: { _ in
                            Self.spotify.assertNotOnUpdateAuthInfoDispatchQueue()
//                            print("fulfilled expectation i: \(i); j: \(j)")
                            internalQueue.asyncAfter(deadline: .now() + 0.5) {
                                expectations[i][j].fulfill()
                            }
                        },
                        receiveValue: {
                            Self.spotify.assertNotOnUpdateAuthInfoDispatchQueue()
//                            print("finished refreshing tokens i: \(i); j: \(j)")
                            
                            // the access token, which lasts for an hour, should've
                            // just been refreshed
                            XCTAssertFalse(
                                Self.spotify.authorizationManager.accessTokenIsExpired(
                                    tolerance: 3_300  // 55 minutes
                                ),
                                "access token was expired after just refreshing it"
                            )
                            XCTAssert(
                                Self.spotify.authorizationManager.isAuthorized(for: []),
                                "`isAuthorized` returned false after access " +
                                "token was just refreshed"
                            )
                            internalQueue.sync {
                                Self.spotify.assertNotOnUpdateAuthInfoDispatchQueue()
                                if let updatedAuthInfo = updatedAuthInfo {
                                    XCTAssertEqual(
                                        Self.spotify.authorizationManager,
                                        updatedAuthInfo,
                                        "authorizationManager should only change once"
                                    )
//                                    print(
//                                        "ensured authorizationManager didn't change " +
//                                        "i: \(i); j: \(j)"
//                                    )
                                }
                                else {
                                    updatedAuthInfo = Self.spotify.authorizationManager
                                    print(
                                        "updatedAuthInfo = Self.spotify.authorizationManager" +
                                        "i: \(i); j: \(j)"
                                    )
                                }
                            }
                        }
                    )
                    
//                    print("after i: \(i); j: \(j)")
                    
                    // avoid datarace
                    internalQueue.sync {
                        _ = cancellables.insert(cancellable)
                    }
                    
                    // check for data races when accessing these properties.
//                    print("asyncTokensRefresh waiting after to pour into sink")
                    sink = Self.spotify.authorizationManager.accessToken
                    sink = "\(Self.spotify.authorizationManager.scopes as Any)"
                    sink = "\(Self.spotify.authorizationManager.expirationDate as Any)"
//                    print("asyncTokensRefresh finished after pouring into sink")
                    
                    _ = sink  // suppress warnings
                    
                }
                
//                print("after i: \(i)")
                
            }
        }
        
//        print("waiting for expectations; TOP LEVEL: \(topLevel)")
        self.wait(for: expectations.flatMap { $0 }, timeout: 60)
//        print("done waiting; TOP LEVEL: \(topLevel)")
        
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 1,
                "authorizationManagerDidChange should emit exactly once; " +
                "top level: \(topLevel)"
            )
        }

    }
    
    func concurrentRequestsWithExpiredToken() {

        Self.spotify.authorizationManager.setExpirationDate(to: Date())

        let internalQueue = DispatchQueue(
            label: "SpotifyAPIRefreshTokensConcurrentTests.internalQueue"
        )

        let incrementDidChangeCountExpectation = XCTestExpectation(
            description: "incrementDidChangeCountExpectation"
        )

        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange
            .sink(receiveValue: {
                internalQueue.async {
                    didChangeCount += 1
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        incrementDidChangeCountExpectation.fulfill()
                    }
                }
            })
            .store(in: &cancellables)

        var receivedTrack = false
        var receivedAlbum = false
        var receivedArtist = false
        
        let concurrentQueue1 = DispatchQueue(
            label: "concurrentRequestsWithExpiredToken.concurrentQueue1",
            attributes: .concurrent
        )
        let concurrentQueue2 = DispatchQueue(
            label: "concurrentRequestsWithExpiredToken.concurrentQueue2",
            attributes: .concurrent
        )
        let concurrentQueue3 = DispatchQueue(
            label: "concurrentRequestsWithExpiredToken.concurrentQueue3",
            attributes: .concurrent
        )

        let trackExpectation = XCTestExpectation(
            description: "track"
        )
        let albumExpectation = XCTestExpectation(
            description: "album"
        )
        let artistExpectation = XCTestExpectation(
            description: "artist"
        )

        concurrentQueue1.async {
            // MARK: track
            let cancellable = Self.spotify.track(URIs.Tracks.breathe)
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { completion in
                        print("track completion: \(completion)")
                        trackExpectation.fulfill()
                    },
                    receiveValue: { track in
                        print("received track: \(track.name)")
                        receivedTrack = true
                    }
                )
            internalQueue.async {
                Self.cancellables.insert(cancellable)
            }
        }

        concurrentQueue2.async {
            // MARK: album
            let cancellable = Self.spotify.album(URIs.Albums.darkSideOfTheMoon)
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { completion in
                        print("album completion: \(completion)")
                        albumExpectation.fulfill()
                    },
                    receiveValue: { album in
                        print("received album: \(album.name)")
                        receivedAlbum = true
                    }
                )
            internalQueue.async {
                Self.cancellables.insert(cancellable)
            }
        }

        concurrentQueue3.async {
            // MARK: artist
            let cancellable = Self.spotify.artist(URIs.Artists.crumb)
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { completion in
                        print("artist completion: \(completion)")
                        artistExpectation.fulfill()
                    },
                    receiveValue: { artist in
                        print("received artist: \(artist.name)")
                        receivedArtist = true
                    }
                )
            internalQueue.async {
                Self.cancellables.insert(cancellable)
            }
        }
        
        print("waiting for track, album, and artist")
        print("finished waiting")

        self.wait(
            for: [
                trackExpectation,
                albumExpectation,
                artistExpectation
            ],
            timeout: 120
        )
        self.wait(for: [incrementDidChangeCountExpectation], timeout: 10)

        internalQueue.sync {
            XCTAssertEqual(didChangeCount, 1)
            XCTAssertTrue(receivedTrack, "did not receive track")
            XCTAssertTrue(receivedAlbum, "did not receive album")
            XCTAssertTrue(receivedArtist, "did not receive artist")
        }

    }
  
    func _setUp() {
        self.continueAfterFailure = false
        Self.spotify.authorizationManager.waitUntilAuthorized()
    }

    func _tearDown() {
        Self.spotify.authorizationManager.deauthorize()
        self.continueAfterFailure = true
    }

 }

// MARK: - Client -

final class SpotifyAPIClientCredentialsFlowRefreshTokensConcurrentTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIRefreshTokensConcurrentTests
{
    
    static let allCases = [
        ("testConcurrentTokensRefresh", testConcurrentTokensRefresh),
        ("testConcurrentRequestsWithExpiredToken", testConcurrentRequestsWithExpiredToken)
    ]
    
    func testConcurrentTokensRefresh() {
        self.concurrentTokensRefresh()
    }
    
    func testConcurrentRequestsWithExpiredToken() {
        self.concurrentRequestsWithExpiredToken()
    }

    override func setUp() {
        self._setUp()
    }

    override func tearDown() {
        self._tearDown()
    }
    
}

 
final class SpotifyAPIAuthorizationCodeFlowRefreshTokensConcurrentTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIRefreshTokensConcurrentTests
{
    
    static let allCases = [
        ("testConcurrentTokensRefresh", testConcurrentTokensRefresh),
        ("testConcurrentRequestsWithExpiredToken", testConcurrentRequestsWithExpiredToken)
    ]
    
    func testConcurrentTokensRefresh() {
        self.concurrentTokensRefresh()
    }
    
    func testConcurrentRequestsWithExpiredToken() {
        self.concurrentRequestsWithExpiredToken()
    }
    
    override func setUp() {
        self._setUp()
    }
    
    override func tearDown() {
        self._tearDown()
    }

}

final class SpotifyAPIAuthorizationCodeFlowPKCERefreshTokensConcurrentTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIRefreshTokensConcurrentTests
{
    
    static let allCases = [
        ("testConcurrentTokensRefresh", testConcurrentTokensRefresh),
        ("testConcurrentRequestsWithExpiredToken", testConcurrentRequestsWithExpiredToken)
    ]
    
    func testConcurrentTokensRefresh() {
        self.concurrentTokensRefresh()
    }
    
    func testConcurrentRequestsWithExpiredToken() {
        self.concurrentRequestsWithExpiredToken()
    }
    
    override func setUp() {
        self._setUp()
    }
    
    override func tearDown() {
        self._tearDown()
    }

    
}

// MARK: - Proxy -

final class SpotifyAPIClientCredentialsFlowProxyRefreshTokensConcurrentTests:
    SpotifyAPIClientCredentialsFlowProxyTests, SpotifyAPIRefreshTokensConcurrentTests
{
    
    static let allCases = [
        ("testConcurrentTokensRefresh", testConcurrentTokensRefresh),
        ("testConcurrentRequestsWithExpiredToken", testConcurrentRequestsWithExpiredToken)
    ]
    
    func testConcurrentTokensRefresh() {
        self.concurrentTokensRefresh()
    }
    
    func testConcurrentRequestsWithExpiredToken() {
        self.concurrentRequestsWithExpiredToken()
    }
    
    override func setUp() {
        self._setUp()
    }
    
    override func tearDown() {
        self._tearDown()
    }

}


final class SpotifyAPIAuthorizationCodeFlowProxyRefreshTokensConcurrentTests:
    SpotifyAPIAuthorizationCodeFlowProxyTests, SpotifyAPIRefreshTokensConcurrentTests
{
    
    static let allCases = [
        ("testConcurrentTokensRefresh", testConcurrentTokensRefresh),
        ("testConcurrentRequestsWithExpiredToken", testConcurrentRequestsWithExpiredToken)
    ]
    
    func testConcurrentTokensRefresh() {
        self.concurrentTokensRefresh()
    }
    
    func testConcurrentRequestsWithExpiredToken() {
        self.concurrentRequestsWithExpiredToken()
    }
    
    override func setUp() {
        self._setUp()
    }
    
    override func tearDown() {
        self._tearDown()
    }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEProxyRefreshTokensConcurrentTests:
    SpotifyAPIAuthorizationCodeFlowPKCEProxyTests, SpotifyAPIRefreshTokensConcurrentTests
{
    
    static let allCases = [
        ("testConcurrentTokensRefresh", testConcurrentTokensRefresh),
        ("testConcurrentRequestsWithExpiredToken", testConcurrentRequestsWithExpiredToken)
    ]
    
    func testConcurrentTokensRefresh() {
        self.concurrentTokensRefresh()
    }
    
    func testConcurrentRequestsWithExpiredToken() {
        self.concurrentRequestsWithExpiredToken()
    }
    
    override func setUp() {
        self._setUp()
    }
    
    override func tearDown() {
        self._tearDown()
    }

}
