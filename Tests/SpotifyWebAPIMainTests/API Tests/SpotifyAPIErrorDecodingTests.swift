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

// Ensure that `SpotifyError` and `SpotifyPlayerError` are correctly
// decoded from Spotify web API requests

protocol SpotifyAPIErrorDecodingTests: SpotifyAPITests { }

extension SpotifyAPIErrorDecodingTests {
    
    func decodeSpotifyErrorFromInvalidAlbumURI() {

        let expectation = XCTestExpectation(
            description: "invalid album URI"
        )
        
        let invalidAlbumURI = "spotify:album:invalid"

        Self.spotify.album(invalidAlbumURI)
            .sink(
                receiveCompletion: { completion in

                    defer { expectation.fulfill() }

                    guard case .failure(let error) = completion else {
                        XCTFail("should not finish normally")
                        return
                    }
                    guard let spotifyError = error as? SpotifyError else {
                        XCTFail("should receive `SpotifyError`: \(error)")
                        return
                    }
                    XCTAssertEqual(spotifyError.message, "invalid id")
                    XCTAssertEqual(spotifyError.statusCode, 400)
                    
                },
                receiveValue: { album in
                    XCTFail("should not receive value: \(album)")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
}

extension SpotifyAPIErrorDecodingTests where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{
    
    func decodeSpotifyPlayerError() {
        
        let expectation = XCTestExpectation(
            description: "play"
        )

        Self.spotify.play(.init(URIs.Tracks.because))
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 2)
            .flatMap { () -> AnyPublisher<Void, Error> in
                Self.spotify.pausePlayback()
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 2)
            .flatMap { () -> AnyPublisher<Void, Error> in
                // trying to pause playback a second time after
                // it's already paused should generate a
                // `SpotifyPlayerError`
                Self.spotify.pausePlayback()
            }
            .sink(
                receiveCompletion: { completion in
                    
                    defer { expectation.fulfill() }

                    guard case .failure(let error) = completion else {
                        XCTFail("should not finish normally")
                        return
                    }
                    guard let playerError =
                            error as? SpotifyPlayerError else {
                        XCTFail(
                            "should receive `SpotifyPlayerError`: \(error)"
                        )
                        return
                    }
                    XCTAssert(
                        playerError.message.starts(with: "Player command failed:"),
                        playerError.message
                    )
                    let possibleReasons: [SpotifyPlayerError.ErrorReason] = [
                        .unknown,
                        .alreadyPaused
                    ]
                    XCTAssert(
                        possibleReasons.contains(playerError.reason),
                        "\(playerError.reason)"
                    )
                    XCTAssertEqual(playerError.statusCode, 403)
                    
                },
                receiveValue: {
                    XCTFail("should not receive value")
                }
            )
            .store(in: &Self.cancellables)
            
        self.wait(for: [expectation], timeout: 240)

    }
    
}

class SpotifyAPIClientCredentialsFlowErrorDecodingTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIErrorDecodingTests
{

    static let allTests = [
        (
            "testDecodeSpotifyErrorFromInvalidAlbumURI",
            testDecodeSpotifyErrorFromInvalidAlbumURI
        )
    ]

    func testDecodeSpotifyErrorFromInvalidAlbumURI() {
        decodeSpotifyErrorFromInvalidAlbumURI()
    }
    
}

class SpotifyAPIAuthorizationCodeFlowErrorDecodingTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIErrorDecodingTests
{

    static let allTests = [
        (
            "testDecodeSpotifyErrorFromInvalidAlbumURI",
            testDecodeSpotifyErrorFromInvalidAlbumURI
        ),
        ("testDecodeSpotifyPlayerError", testDecodeSpotifyPlayerError)
    ]

    func testDecodeSpotifyErrorFromInvalidAlbumURI() {
        decodeSpotifyErrorFromInvalidAlbumURI()
    }
    func testDecodeSpotifyPlayerError() {
        decodeSpotifyPlayerError()
    }
    
}

class SpotifyAPIAuthorizationCodeFlowPKCEErrorDecodingTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIErrorDecodingTests
{

    static let allTests = [
        (
            "testDecodeSpotifyErrorFromInvalidAlbumURI",
            testDecodeSpotifyErrorFromInvalidAlbumURI
        ),
        ("testDecodeSpotifyPlayerError", testDecodeSpotifyPlayerError)
    ]

    func testDecodeSpotifyErrorFromInvalidAlbumURI() {
        decodeSpotifyErrorFromInvalidAlbumURI()
    }
    func testDecodeSpotifyPlayerError() {
        decodeSpotifyPlayerError()
    }
    
}
