import Foundation
import Combine
import XCTest
import SpotifyWebAPI
import _SpotifyAPITestUtilities
import SpotifyURIs

class SpotifyAPIPlayerTests: SpotifyAPIAuthorizationCodeFlowTests {
    
    static let allTests = [
        ("testPlayPause", testPlayPause)
    ]
    
    func testPlayPause() {
        
        let expectation = XCTestExpectation(description: "testPlayPause")
        
        func checkPlaybackContext(_ context: CurrentlyPlayingContext) {
            XCTAssertTrue(context.isPlaying)
            XCTAssertEqual(context.item?.name, "Any Colour You Like")
            if let progress = context.progressMS {
                XCTAssert((100_000...120_000).contains(progress))
            }
            else {
                XCTFail("context.progressMS should not be nil")
            }
            if case .track(let track) = context.item {
                XCTAssertEqual(track.artists?.first?.name, "Pink Floyd")
            }
            else {
                XCTFail("context.item should be track")
            }
        }
        
        let playbackRequest = PlaybackRequest(
            context: .uris([URIs.Tracks.anyColourYouLike]),
            offset: nil,
            positionMS: 100_000
        )
        
        encodeDecode(playbackRequest)
        
        Self.spotify.play(playbackRequest)
            // This test will fail if you don't have an active
            // device. Open a Spotify client (such as the iOS app)
            // and ensure it's logged in to the same account used to
            // authroize the access token. Then, run the tests again.
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                encodeDecode(context)
                checkPlaybackContext(context)
                return Self.spotify.pausePlayback()
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                encodeDecode(context)
                XCTAssertFalse(context.isPlaying)
                return Self.spotify.resumePlayback()
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { context in
                    encodeDecode(context)
                    checkPlaybackContext(context)
                }
            )
            .store(in: &Self.cancellables)
     
        wait(for: [expectation], timeout: 120)
        

    }

    func testShuffle() {
        
        let expectation = XCTestExpectation(
            description: "testShuffle"
        )
        
        Self.spotify.setShuffle(to: false)
            // This test will fail if you don't have an active
            // device. Open a Spotify client (such as the iOS app)
            // and ensure it's logged in to the same account used to
            // authroize the access token. Then, run the tests again.
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                XCTAssertFalse(context.shuffleIsOn)
                return Self.spotify.setShuffle(to: true)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                XCTAssertTrue(context.shuffleIsOn)
                return Self.spotify.setShuffle(to: false)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { context in
                    XCTAssertFalse(context.shuffleIsOn)
                }
            )
            .store(in: &Self.cancellables)
            
            wait(for: [expectation], timeout: 120)
        
    }
    
    func testRepeat() {
        
        let expectation = XCTestExpectation(
            description: "testRepeat"
        )
        
        Self.spotify.setRepeatMode(to: .track)
            // This test will fail if you don't have an active
            // device. Open a Spotify client (such as the iOS app)
            // and ensure it's logged in to the same account used to
            // authroize the access token. Then, run the tests again.
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                XCTAssertEqual(context.repeatState, .track)
                return Self.spotify.setRepeatMode(to: .context)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                XCTAssertEqual(context.repeatState, .context)
                return Self.spotify.setRepeatMode(to: .off)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                XCTAssertEqual(context.repeatState, .off)
                return Self.spotify.setRepeatMode(to: .track)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { context in
                    XCTAssertEqual(context.repeatState, .track)
                }
            )
            .store(in: &Self.cancellables)
            
            wait(for: [expectation], timeout: 120)
        
    }
    
}

