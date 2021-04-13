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

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// Ensure that `SpotifyError` and `SpotifyPlayerError` are correctly
// decoded from Spotify web API requests. Produce a `RateLimited` error.

protocol SpotifyAPIErrorTests: SpotifyAPITests { }

extension SpotifyAPIErrorTests {
    
    func autoRetryOnRateLimitedErrorConcurrent() {
        
        Self.spotify.networkAdaptor = URLSession.shared
            .noCacheNetworkAdaptor(request:)
        
        let queue = DispatchQueue(label: "autoRetryOnRateLimitedErrorConcurrent")

        var didReceiveRateLimitedError = false
        var receivedValues = 0
        var successfulCompletions = 0
        var receivedErrors = 0

        #if DEBUG
        DebugHooks.receiveRateLimitedError
            .receive(on: queue)
            .sink { error in
                encodeDecode(error, areEqual: ==)
                XCTAssertNotNil(error.retryAfter)
                didReceiveRateLimitedError = true
            }
            .store(in: &Self.cancellables)
        #else
        XCTFail("cannot test \(#function) in RELEASE MODE")
        return
        #endif

        var expectations: [XCTestExpectation] = []

        for i in 0..<200 {
            
            queue.sync {
                let expectation = XCTestExpectation(
                    description: "autoRetryOnRateLimitedErrorConcurrent \(i)"
                )
                expectations.append(expectation)
            }

            let artist = URIs.Artists.allCases.randomElement()!
            
            print("$ making request for \(i)")
            Self.spotify.artist(artist)
                .receive(on: queue)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                            case .failure(let error):
                                XCTFail("\(i): unexpected error: \(error)")
                                receivedErrors += 1
                            case .finished:
                                successfulCompletions += 1
                        }
                        print("$ finished request for \(i)")
                        expectations[i].fulfill()
                    },
                    receiveValue: { _ in
                        receivedValues += 1
                    }
                )
                .store(in: &Self.cancellables)
            
        }
        self.wait(for: expectations, timeout: 500)
        
        queue.sync {
            XCTAssertTrue(didReceiveRateLimitedError)
            XCTAssertTrue(didReceiveRateLimitedError)
            XCTAssertEqual(receivedValues, 200)
            XCTAssertEqual(successfulCompletions, 200)
            XCTAssertEqual(receivedErrors, 0)
        }
        
        Self.spotify.networkAdaptor = URLSession.shared
            .defaultNetworkAdaptor(request:)
        
    }
    
    /// Makes serial requests until a rate limited error is received.
    func autoRetryOnRateLimitedErrorSerial() {
        
        let spotifyDecodeLogLevel = spotifyDecodeLogger.logLevel
        spotifyDecodeLogger.logLevel = .error

        Self.spotify.networkAdaptor = URLSession.shared
            .noCacheNetworkAdaptor(request:)
        
        let queue = DispatchQueue(label: "autoRetryOnRateLimitedErrorSerial")
        
        var didReceiveRateLimitedError = false
        var receivedValues = 0
        var successfulCompletions = 0
        var receivedErrors = 0

        #if DEBUG
        DebugHooks.receiveRateLimitedError
            .receive(on: queue)
            .sink { error in
                encodeDecode(error, areEqual: ==)
                XCTAssertNotNil(error.retryAfter)
                didReceiveRateLimitedError = true
            }
            .store(in: &Self.cancellables)
        #else
        XCTFail("cannot test \(#function) in RELEASE MODE")
        return
        #endif

        let dispatchGroup = DispatchGroup()

        for i in 1...500 {
            
            let artist = URIs.Artists.allCases.randomElement()!
            
            print("$ making request for \(i)")
            dispatchGroup.enter()
            Self.spotify.artist(artist)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                            case .failure(let error):
                                XCTFail("\(i): unexpected error: \(error)")
                                receivedErrors += 1
                            case .finished:
                                successfulCompletions += 1
                        }
                        print("$ finished request for \(i)")
                        dispatchGroup.leave()
                    },
                    receiveValue: { _ in
                        receivedValues += 1
                    }
                )
                .store(in: &Self.cancellables)
            dispatchGroup.wait()
            
        }
        
        XCTAssertTrue(didReceiveRateLimitedError)
        XCTAssertEqual(receivedValues, 500)
        XCTAssertEqual(successfulCompletions, 500)
        XCTAssertEqual(receivedErrors, 0)
        
        Self.spotify.networkAdaptor = URLSession.shared
            .defaultNetworkAdaptor(request:)
        
        spotifyDecodeLogger.logLevel = spotifyDecodeLogLevel

    }

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
                    encodeDecode(spotifyError, areEqual: ==)
                    
                },
                receiveValue: { album in
                    XCTFail("should not receive value: \(album)")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

    func retryOnSpotifyErrors() {
        
//      retryableStatusCodes = [500, 502, 503, 504]

        // MARK: SpotifyError

        let spotifyErrorExpectation = XCTestExpectation(
            description: "otherErrors: SpotifyError"
        )

        let spotifyError = SpotifyError(
            message: "Service Unavailable",
            statusCode: 503
        )
        encodeDecode(spotifyError, areEqual: ==)
        
        var receivedValue = false

        Self.spotify.mockThrowError(spotifyError, times: 3)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { completion in
                    print("completion: \(completion)")
                    spotifyErrorExpectation.fulfill()
                },
                receiveValue: { _ in
                    receivedValue = true
                }
            )
            .store(in: &Self.cancellables)
        
        
        // MARK: SpotifyPlayerError

        let spotifyPlayerErrorExpectation = XCTestExpectation(
            description: "otherErrors: SpotifyPlayerError"
        )

        let playerError = SpotifyPlayerError(
            message: "Service Unavailable",
            reason: .unknown,
            statusCode: 500
        )
        encodeDecode(playerError, areEqual: ==)

        var receivedValue2 = false

        Self.spotify.mockThrowError(playerError, times: 2)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { completion in
                    print("completion: \(completion)")
                    spotifyPlayerErrorExpectation.fulfill()
                },
                receiveValue: { _ in
                    receivedValue2 = true
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(
            for: [spotifyErrorExpectation, spotifyPlayerErrorExpectation],
            timeout: 30
        )
        XCTAssertTrue(receivedValue)
        XCTAssertTrue(receivedValue2)

    }

    /// Ensure the request is only retried up to 3 times.
    func exceedRetryLimit() {
        
        let expectation = XCTestExpectation(
            description: "exceededRetryLimit"
        )
        
        let error = SpotifyError(
            message: "Bad Gateway",
            statusCode: 502
        )
        encodeDecode(error, areEqual: ==)
        
        print("\n\n")
        
        // the request should only be retried 3 times
        Self.spotify.mockThrowError(error, times: 4)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            XCTFail("should not finish normally")
                        case .failure(let receivedError):
                            if let spotifyError = receivedError
                                    as? SpotifyError {
                                XCTAssertEqual(spotifyError, error)
                                encodeDecode(spotifyError, areEqual: ==)
                            }
                            else {
                                XCTFail("unexpected error: \(receivedError)")
                            }
                    }
                    expectation.fulfill()
                },
                receiveValue: { value in
                    XCTFail("should not receive value: \(value)")
                }
            )
            .store(in: &Self.cancellables)
        

        self.wait(for: [expectation], timeout: 30)
        
        print("\n\n")

    }

    /// Ensure that non-retryable errors are not retried.
    func nonRetryableErrors() {
        
        let expectation = XCTestExpectation(
            description: "nonRetryableErrors"
        )
        
        let error = SpotifyError(
            message: "invalid id",
            statusCode: 400
        )
        encodeDecode(error, areEqual: ==)
        
        // Only throw the error once. If this request was
        // retried even a single time, then it would return
        // a successful result. But a request that throws this
        // error shouldn't be retried
        Self.spotify.mockThrowError(error, times: 1)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            XCTFail("should not finish normally")
                        case .failure(let receivedError):
                            if let spotifyError = receivedError
                                    as? SpotifyError {
                                XCTAssertEqual(spotifyError, error)
                                encodeDecode(spotifyError, areEqual: ==)
                            }
                            else {
                                XCTFail("unexpected error: \(receivedError)")
                            }
                    }
                    expectation.fulfill()
                },
                receiveValue: { value in
                    XCTFail("should not receive value: \(value)")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 30)

    }
    
}

extension SpotifyAPIErrorTests where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{
    
    func decodeSpotifyPlayerError() {
        
        let expectation = XCTestExpectation(
            description: "decodeSpotifyPlayerError"
        )

        Self.spotify.play(.init(URIs.Tracks.because))
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 2)
            .flatMap { () -> AnyPublisher<Void, Error> in
                // pause playbackk the first time
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

final class SpotifyAPIClientCredentialsFlowErrorTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIErrorTests
{

    static let allTests = [
        (
            "testAutoRetryOnRateLimitedErrorConcurrent",
            testAutoRetryOnRateLimitedErrorConcurrent
        ),
        (
            "testAutoRetryOnRateLimitedErrorSerial",
            testAutoRetryOnRateLimitedErrorSerial
        ),
        (
            "testDecodeSpotifyErrorFromInvalidAlbumURI",
            testDecodeSpotifyErrorFromInvalidAlbumURI
        ),
        ("testRetryOnSpotifyErrors", testRetryOnSpotifyErrors),
        ("testExceedRetryLimit", testExceedRetryLimit),
        ("testNonRetryableErrors", testNonRetryableErrors)
        
    ]

    func testAutoRetryOnRateLimitedErrorConcurrent() {
        autoRetryOnRateLimitedErrorConcurrent()
    }
    func testAutoRetryOnRateLimitedErrorSerial() {
//        for i in 1...100 {
//            print("top level: \(i)")
            autoRetryOnRateLimitedErrorSerial()
//        }
    }
    func testDecodeSpotifyErrorFromInvalidAlbumURI() {
        decodeSpotifyErrorFromInvalidAlbumURI()
    }
    func testRetryOnSpotifyErrors() { retryOnSpotifyErrors() }
    func testExceedRetryLimit() { exceedRetryLimit() }
    func testNonRetryableErrors() { nonRetryableErrors() }
    
}

final class SpotifyAPIAuthorizationCodeFlowErrorTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIErrorTests
{

    static let allTests = [
        (
            "testAutoRetryOnRateLimitedErrorConcurrent",
            testAutoRetryOnRateLimitedErrorConcurrent
        ),
        (
            "testAutoRetryOnRateLimitedErrorSerial",
            testAutoRetryOnRateLimitedErrorSerial
        ),
        (
            "testDecodeSpotifyErrorFromInvalidAlbumURI",
            testDecodeSpotifyErrorFromInvalidAlbumURI
        ),
        ("testDecodeSpotifyPlayerError", testDecodeSpotifyPlayerError),
        ("testRetryOnSpotifyErrors", testRetryOnSpotifyErrors),
        ("testExceedRetryLimit", testExceedRetryLimit),
        ("testNonRetryableErrors", testNonRetryableErrors)
    ]

    func testAutoRetryOnRateLimitedErrorConcurrent() {
        autoRetryOnRateLimitedErrorConcurrent()
    }
    func testAutoRetryOnRateLimitedErrorSerial() { autoRetryOnRateLimitedErrorSerial() }
    func testDecodeSpotifyErrorFromInvalidAlbumURI() {
        decodeSpotifyErrorFromInvalidAlbumURI()
    }
    func testDecodeSpotifyPlayerError() {
        decodeSpotifyPlayerError()
    }
    func testRetryOnSpotifyErrors() { retryOnSpotifyErrors() }
    func testExceedRetryLimit() { exceedRetryLimit() }
    func testNonRetryableErrors() { nonRetryableErrors() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEErrorTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIErrorTests
{

    static let allTests = [
        (
            "testAutoRetryOnRateLimitedErrorConcurrent",
            testAutoRetryOnRateLimitedErrorConcurrent
        ),
        (
            "testAutoRetryOnRateLimitedErrorSerial",
            testAutoRetryOnRateLimitedErrorSerial
        ),
        (
            "testDecodeSpotifyErrorFromInvalidAlbumURI",
            testDecodeSpotifyErrorFromInvalidAlbumURI
        ),
        ("testDecodeSpotifyPlayerError", testDecodeSpotifyPlayerError),
        ("testRetryOnSpotifyErrors", testRetryOnSpotifyErrors),
        ("testExceedRetryLimit", testExceedRetryLimit),
        ("testNonRetryableErrors", testNonRetryableErrors)
    ]

    func testAutoRetryOnRateLimitedErrorConcurrent() {
        autoRetryOnRateLimitedErrorConcurrent()
    }
    func testAutoRetryOnRateLimitedErrorSerial() { autoRetryOnRateLimitedErrorSerial() }
    func testDecodeSpotifyErrorFromInvalidAlbumURI() {
        decodeSpotifyErrorFromInvalidAlbumURI()
    }
    func testDecodeSpotifyPlayerError() {
        decodeSpotifyPlayerError()
    }
    func testRetryOnSpotifyErrors() { retryOnSpotifyErrors() }
    func testExceedRetryLimit() { exceedRetryLimit() }
    func testNonRetryableErrors() { nonRetryableErrors() }
    
}
