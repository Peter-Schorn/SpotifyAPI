import Foundation
import Combine
import XCTest
import SpotifyWebAPI
import SpotifyContent


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
        
        Self.spotify.resumePlayback(playbackRequest)
            // this test will fail if you don't have an active
            // device. Open a Spotify client (such as the iOS app)
            // and ensure it's logged in to the same account used to
            // authroize the access token.
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                encodeDecode(context)
                checkPlaybackContext(context)
                return Self.spotify.pausePlayback()
            }
            .delay(for: 1, scheduler: DispatchQueue.global())
            .XCTAssertNoFailure()
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                encodeDecode(context)
                XCTAssertFalse(context.isPlaying)
                return Self.spotify.resumePlayback(nil)
            }
            .delay(for: 1, scheduler: DispatchQueue.global())
            .XCTAssertNoFailure()
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
     
        wait(for: [expectation], timeout: 60)
        

    }

}
