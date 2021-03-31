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
 Test refreshing the tokens multiple times asyncronously to ensure
 that they only actually get refreshed once.
 
 These tests are also used in conjunction with the thread sanitizer
 to ensure there are no race conditions or other thread-safety issues.
 */
protocol SpotifyAPIRefreshTokensConcurrentTests: SpotifyAPITests { }

extension SpotifyAPIRefreshTokensConcurrentTests where AuthorizationManager: Equatable {
    
    func concurrentTokensRefresh(topLevel: Int) {
        
        var cancellables: Set<AnyCancellable> = []
        
        let internalQueue = DispatchQueue(
            label: "asyncTokensRefresh internalQueue"
        )
        
        var didChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            // .receiveOnMain()
            .print("Self.spotify.authorizationManagerDidChange print")
            .sink(receiveValue: {
                Self.spotify.assertNotOnUpdateAuthInfoDispatchQueue()
                print(
                    "spotify.authorizationManagerDidChange.sink; " +
                    "top level: \(topLevel)"
                )

                print("WILL print Self.spotify.authorizationManager")
                print("\(Self.spotify.authorizationManager)")
                print("DID print Self.spotify.authorizationManager")

                internalQueue.sync {
                    didChangeCount += 1
                }
                print("after internalQueue.sync")
            })
            .store(in: &cancellables)

        var updatedAuthInfo: AuthorizationManager? = nil
        
        let iMax = 10
        let jMax = 10
        
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
              
                if i > 5 && Bool.random() {
                    usleep(UInt32.random(in: 1_000...10_000))
                }

                print("begin i: \(i)")
                

                for j in 0..<jMax {

                    print("begin i: \(i); j: \(j)")
                    
                    var sink: String? = nil
                    
                    // check for data races when accessing these properties.
                    print("asyncTokensRefresh waiting to pour into sink")
                    sink = Self.spotify.authorizationManager.accessToken
                    sink = "\(Self.spotify.authorizationManager.scopes as Any)"
                    sink = "\(Self.spotify.authorizationManager.expirationDate as Any)"
                    print("asyncTokensRefresh finished pouring into sink")
                    
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
                            print("fulfilled expectation i: \(i); j: \(j)")
                            expectations[i][j].fulfill()
                        },
                        receiveValue: {
                            Self.spotify.assertNotOnUpdateAuthInfoDispatchQueue()
                            print("finished refreshing tokens i: \(i); j: \(j)")
                            XCTAssertFalse(
                                Self.spotify.authorizationManager.accessTokenIsExpired(
                                    tolerance: 120
                                )
                            )
                            internalQueue.async {
                                Self.spotify.assertNotOnUpdateAuthInfoDispatchQueue()
                                if let updatedAuthInfo = updatedAuthInfo {
                                    XCTAssertEqual(
                                        Self.spotify.authorizationManager,
                                        updatedAuthInfo,
                                        "authorizationManager should only change once"
                                    )
                                    print(
                                        "ensured authorizationManager didn't change " +
                                        "i: \(i); j: \(j)"
                                    )
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
                    
                    print("after i: \(i); j: \(j)")
                    
                    // avoid datarace
                    internalQueue.async {
                        cancellables.insert(cancellable)
                    }
                    
                    // check for data races when accessing these properties.
                    print("asyncTokensRefresh waiting after to pour into sink")
                    sink = Self.spotify.authorizationManager.accessToken
                    sink = "\(Self.spotify.authorizationManager.scopes as Any)"
                    sink = "\(Self.spotify.authorizationManager.expirationDate as Any)"
                    print("asyncTokensRefresh finished after pouring into sink")
                    
                    _ = sink  // supress warnings
                    
                }
                
                print("after i: \(i)")
                
            }
        }
        
        print("waiting for expectations; TOP LEVEL: \(topLevel)")
        self.wait(for: expectations.flatMap { $0 }, timeout: 10)
        print("done waiting; TOP LEVEL: \(topLevel)")
        
        XCTAssertEqual(
            didChangeCount, 1,
            "authorizationManagerDidChange should emit exactly once; " +
            "top level: \(topLevel)"
        )
        
    }
    
    func concurrentRequestsWithExpiredToken() {

        Self.spotify.authorizationManager.setExpirationDate(to: Date())

        let internalQueue = DispatchQueue(
            label: "SpotifyAPIRefreshTokensConcurrentTests.internalQueue"
        )

        let dispatchGroup = DispatchGroup()

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
        
        DispatchQueue.global().async {
            // MARK: track
            dispatchGroup.enter()
            let cancellable = Self.spotify.track(URIs.Tracks.breathe)
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { completion in
                        print("track completion: \(completion)")
                        dispatchGroup.leave()
                    },
                    receiveValue: { track in
                        print("received track: \(track.name)")
                        receivedTrack = true
                    }
                )
            dispatchGroup.enter()
            internalQueue.async {
                Self.cancellables.insert(cancellable)
                dispatchGroup.leave()
            }
        }

        DispatchQueue.global().async {
            // MARK: album
            dispatchGroup.enter()
            let cancellable = Self.spotify.album(URIs.Albums.darkSideOfTheMoon)
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { completion in
                        print("album completion: \(completion)")
                        dispatchGroup.leave()
                    },
                    receiveValue: { album in
                        print("received album: \(album.name)")
                        receivedAlbum = true
                    }
                )
            dispatchGroup.enter()
            internalQueue.async {
                Self.cancellables.insert(cancellable)
                dispatchGroup.leave()
            }
        }

        DispatchQueue.global().async {
            // MARK: artist
            dispatchGroup.enter()
            let cancellable = Self.spotify.artist(URIs.Artists.crumb)
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { completion in
                        print("artist completion: \(completion)")
                        dispatchGroup.leave()
                    },
                    receiveValue: { artist in
                        print("received artist: \(artist.name)")
                        receivedArtist = true
                    }
                )
            dispatchGroup.enter()
            internalQueue.async {
                Self.cancellables.insert(cancellable)
                dispatchGroup.leave()
            }
        }
        
        print("waiting for track, album, and artist")
        dispatchGroup.wait()
        print("finished waiting")

        self.wait(for: [incrementDidChangeCountExpectation], timeout: 30)

        XCTAssertEqual(didChangeCount, 1)
        XCTAssertTrue(receivedTrack)
        XCTAssertTrue(receivedAlbum)
        XCTAssertTrue(receivedArtist)

    }
  
 }



final class SpotifyAPIClientCredentialsFlowRefreshTokensConcurrentTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIRefreshTokensConcurrentTests
{
    
    static let allCases = [
        ("testConcurrentTokensRefresh", testConcurrentTokensRefresh),
        ("testConcurrentRequestsWithExpiredToken", testConcurrentRequestsWithExpiredToken)
    ]
    
    func testConcurrentTokensRefresh() {
        for i in 0..<20 {
            print("\n--- TOP LEVEL \(i) ---\n")
            Self.spotify.authorizationManager.setExpirationDate(to: Date())
            self.concurrentTokensRefresh(topLevel: i)
        }
    }
    
    func testConcurrentRequestsWithExpiredToken() {
        Self.spotify.authorizationManager.deauthorize()
        Self.spotify.waitUntilAuthorized()
        self.concurrentRequestsWithExpiredToken()
    }
    
    override func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }
    
    override func setUp() {
        Self.setupAuthorization()
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
        for i in 0..<20 {
            print("\n--- TOP LEVEL \(i) ---\n")
            Self.spotify.authorizationManager.setExpirationDate(to: Date())
            self.concurrentTokensRefresh(topLevel: i)
        }
    }
    
    func testConcurrentRequestsWithExpiredToken() {
        self.concurrentRequestsWithExpiredToken()
    }
    
    override func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }
    
    override func setUp() {
        Self.setupAuthorization()
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
        for i in 0..<20 {
            print("\n--- TOP LEVEL \(i) ---\n")
            Self.spotify.authorizationManager.setExpirationDate(to: Date())
            self.concurrentTokensRefresh(topLevel: i)
        }
    }
    
    func testConcurrentRequestsWithExpiredToken() {
        self.concurrentRequestsWithExpiredToken()
    }
    
    override func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }
    
    override func setUp() {
        Self.setupAuthorization()
    }
    

}
