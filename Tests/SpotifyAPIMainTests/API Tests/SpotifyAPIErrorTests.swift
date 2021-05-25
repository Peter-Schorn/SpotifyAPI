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

protocol SpotifyAPIErrorTests: SpotifyAPITests { }

extension SpotifyAPIErrorTests {
    
    /// Make a request without authorizing beforehand.
    func makeRequestWithoutAuthorization() {
        
        func receiveCompletion(
            _ completion: Subscribers.Completion<Error>
        ) {
            guard case .failure(let error) = completion else {
                XCTFail("should've finished with error")
                return
            }
            guard let spotifyLocalError = error as? SpotifyGeneralError else {
                XCTFail("should've received SpotifyGeneralError: \(error)")
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
        
        Self.spotify.authorizationManager.waitUntilAuthorized()

    }
    
    /// Make a request with an invalid access token.
    func makeRequestWithInvalidAccessToken() {
        
        let accessToken = Self.spotify.authorizationManager._accessToken
        defer {
            Self.spotify.authorizationManager._accessToken = accessToken
        }
        
        Self.spotify.authorizationManager._accessToken = "invalidToken"
        
        let expectation = XCTestExpectation(
            description: "makeRequestWithInvalidAccessToken"
        )
        
        let artist = URIs.Artists.crumb
        
        Self.spotify.networkAdaptor =
                URLSession.shared.noCacheNetworkAdaptor(request:)

        Self.spotify.artist(artist)
            .sink(
                receiveCompletion: { completion in
                    defer { expectation.fulfill() }
                    guard case .failure(let error) = completion else {
                        XCTFail("should not finished normally")
                        return
                    }
                    guard let spotifyError = error as? SpotifyError else {
                        XCTFail("should've received SpotifyError: \(error)")
                        return
                    }
                    XCTAssertEqual(spotifyError.message, "Invalid access token")
                    XCTAssertEqual(spotifyError.statusCode, 401)
                },
                receiveValue: { artist in
                    XCTFail(
                        """
                        Should not receive value after making a request with \
                        an invalid access token.
                        value: \(artist)
                        authorizationManager: \(Self.spotify.authorizationManager)
                        """
                    )
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

        Self.spotify.networkAdaptor = URLSession.defaultNetworkAdaptor(request:)

    }
    
    func autoRetryOnRateLimitedErrorConcurrent() {
        
        DistributedLock.rateLimitedError.lock()
        defer {
            DistributedLock.rateLimitedError.unlock()
            
        }

        Self.spotify.networkAdaptor = URLSession.shared
            .noCacheNetworkAdaptor(request:)
        
        let queue = DispatchQueue(
            label: "autoRetryOnRateLimitedErrorConcurrent"
        )

        var didReceiveRateLimitedError = false
        var receivedValues = 0
        var successfulCompletions = 0
        var receivedErrors = 0

        #if DEBUG
        var cancellables: Set<AnyCancellable> = []
        DebugHooks.receiveRateLimitedError
            .receive(on: queue)
            .sink { error in
                encodeDecode(error, areEqual: ==)
                XCTAssertNotNil(error.retryAfter)
                didReceiveRateLimitedError = true
            }
            .store(in: &cancellables)
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
                                XCTFail("\(i): should not receive error: \(error)")
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
        
        Self.spotify.networkAdaptor = URLSession.defaultNetworkAdaptor(request:)
        
    }
    
    /// Makes serial requests until a rate limited error is received.
    func autoRetryOnRateLimitedErrorSerial() {
        
        DistributedLock.rateLimitedError.lock()
        defer {
            DistributedLock.rateLimitedError.unlock()
        }

        let spotifyDecodeLogLevel = spotifyDecodeLogger.logLevel
        spotifyDecodeLogger.logLevel = .error

        Self.spotify.networkAdaptor = URLSession.shared
            .noCacheNetworkAdaptor(request:)
        
        let queue = DispatchQueue(
            label: "autoRetryOnRateLimitedErrorSerial"
        )
        
        var didReceiveRateLimitedError = false
        var receivedValues = 0
        var successfulCompletions = 0
        var receivedErrors = 0

        #if DEBUG
        var cancellables: Set<AnyCancellable> = []
        DebugHooks.receiveRateLimitedError
            .receive(on: queue)
            .sink { error in
                encodeDecode(error, areEqual: ==)
                XCTAssertNotNil(error.retryAfter)
                didReceiveRateLimitedError = true
            }
            .store(in: &cancellables)
        #else
        XCTFail("cannot test \(#function) in RELEASE MODE")
        return
        #endif

        let dispatchGroup = DispatchGroup()

        for i in 1...250 {
            
            DispatchQueue.concurrentPerform(iterations: 2) { j in
                
                let artist = URIs.Artists.allCases.randomElement()!
                
                print("making request for i:\(i); j:\(j)")
                dispatchGroup.enter()
                let cancellable = Self.spotify.artist(artist)
                    .receive(on: queue)
                    .sink(
                        receiveCompletion: { completion in
                            switch completion {
                                case .failure(let error):
                                    XCTFail("\(i): should not receive error: \(error)")
                                    receivedErrors += 1
                                case .finished:
                                    successfulCompletions += 1
                            }
                            print("finished request for i:\(i); j:\(j)")
                            dispatchGroup.leave()
                        },
                        receiveValue: { _ in
                            receivedValues += 1
                        }
                    )
                queue.async {
                    Self.cancellables.insert(cancellable)
                }
                dispatchGroup.wait()
                
            }
            
        }
        
        XCTAssertTrue(
            didReceiveRateLimitedError,
            "didn't receive rate limited error"
        )
        XCTAssertEqual(receivedValues, 500)
        XCTAssertEqual(successfulCompletions, 500)
        XCTAssertEqual(receivedErrors, 0)
        
        Self.spotify.networkAdaptor = URLSession.defaultNetworkAdaptor(request:)
        
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
            description: "SpotifyError"
        )

        let spotifyError = SpotifyError(
            message: "Service Unavailable",
            statusCode: 503
        )
        encodeDecode(spotifyError, areEqual: ==)
        
        var receivedValue1 = false

        Self.spotify.mockThrowError(spotifyError, times: 3)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { completion in
                    print("completion: \(completion)")
                    spotifyErrorExpectation.fulfill()
                },
                receiveValue: { _ in
                    receivedValue1 = true
                }
            )
            .store(in: &Self.cancellables)
        
        
        // MARK: SpotifyPlayerError

        let spotifyPlayerErrorExpectation = XCTestExpectation(
            description: "SpotifyPlayerError"
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
        
        // MARK: SpotifyGeneralError.httpError

        let spotifyLocalErrorExpectation = XCTestExpectation(
            description: "SpotifyGeneralError"
        )
        
        let data = """
            upstream connect error or disconnect/reset before headers. \
            reset reason: connection termination
            """.data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://accounts.spotify.com/api/token")!,
            statusCode: 503,
            httpVersion: nil,
            headerFields: nil
        )!
        let httpError = SpotifyGeneralError.httpError(data, response)
        
        var receivedValue3 = false

        Self.spotify.mockThrowError(httpError, times: 2)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { completion in
                    print("completion: \(completion)")
                    spotifyLocalErrorExpectation.fulfill()
                },
                receiveValue: { _ in
                    receivedValue3 = true
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(
            for: [
                spotifyErrorExpectation,
                spotifyPlayerErrorExpectation,
                spotifyLocalErrorExpectation
            ],
            timeout: 30
        )
        XCTAssertTrue(receivedValue1)
        XCTAssertTrue(receivedValue2)
        XCTAssertTrue(receivedValue3)

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
                                XCTFail("should've received SpotifyError: \(receivedError)")
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
                                XCTFail("should've received SpotifyError: \(receivedError)")
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
    
    func decodeOptionalSpotifyObject() {
        
        let expectationEmptySuccess = XCTestExpectation(
            description: "decodeOptionalSpotifyObject empty success"
        )

        // MARK: Empty data; successful status code

        Self.spotify.mockDecodeOptionalSpotifyObject(
            statusCode: 200,
            data: Data(),
            responseType: Track.self
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectationEmptySuccess.fulfill() },
            receiveValue: { track in
                XCTAssertNil(track)
            }
        )
        .store(in: &Self.cancellables)
        
        // MARK: Empty data; error status code
        
        let expectationEmptyError = XCTestExpectation(
            description: "decodeOptionalSpotifyObject empty error"
        )

        Self.spotify.mockDecodeOptionalSpotifyObject(
            statusCode: 400,
            data: Data(),
            responseType: Track.self
        )
        .sink(
            receiveCompletion: { completion in
                defer { expectationEmptyError.fulfill() }
                guard case .failure(let error) = completion else {
                    XCTFail("should not finished normally")
                    return
                }
                guard case .httpError(let data, let response) =
                        error as? SpotifyGeneralError else {
                    XCTFail(
                        "should've received SpotifyGeneralError.httpError: \(error)"
                    )
                    return
                }
                XCTAssertEqual(response.statusCode, 400)
                XCTAssert(data.isEmpty)
                
            },
            receiveValue: { track in
                XCTFail("should not receive value")
            }
        )
        .store(in: &Self.cancellables)

        // MARK: Error Data; error status code
        
        let sentError = SpotifyError(
            message: "Permissions Missing",
            statusCode: 401
        )
        encodeDecode(sentError, areEqual: ==)
        let errorData = try! JSONEncoder().encode(sentError)
        
        let expectationErrorData = XCTestExpectation(
            description: "decodeOptionalSpotifyObject data error"
        )

        Self.spotify.mockDecodeOptionalSpotifyObject(
            statusCode: 400,
            data: errorData,
            responseType: Track.self
        )
        .sink(
            receiveCompletion: { completion in
                defer { expectationErrorData.fulfill() }
                guard case .failure(let error) = completion else {
                    XCTFail("should not finished normally")
                    return
                }
                guard let spotifyError = error as? SpotifyError else {
                    XCTFail("should've received SpotifyError: \(error)")
                    return
                }
                XCTAssertEqual(spotifyError, sentError)
            },
            receiveValue: { track in
                XCTFail("should not receive value")
            }
        )
        .store(in: &Self.cancellables)

        self.wait(
            for: [
                expectationEmptySuccess,
                expectationEmptyError,
                expectationErrorData
            ],
            timeout: 30
        )
        
    }
    
}

extension SpotifyAPIErrorTests where
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager
{
    
    func decodeSpotifyPlayerError() {

        DistributedLock.player.lock()
        defer {
            DistributedLock.player.unlock()
        }

        let expectation = XCTestExpectation(
            description: "decodeSpotifyPlayerError"
        )
        
        Self.spotify.play(.init(URIs.Tracks.because))
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 2)
            .flatMap { () -> AnyPublisher<Void, Error> in
                // pause playback the first time
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

        let resumePlaybackExpectation = XCTestExpectation(
            description: "resumePlayback"
        )
        
        Self.spotify.play(.init(URIs.Tracks.because))
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in
                    resumePlaybackExpectation.fulfill()
                },
                receiveValue: { }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [resumePlaybackExpectation], timeout: 60)

    }
    
    func uploadTooLargePlaylistImage() {
        
        func receiveUploadImageCompletion(
            _ completion: Subscribers.Completion<Error>
        ) {
            guard case .failure(let error) = completion else {
                XCTFail("should not complete normally")
                return
            }
            guard let spotifyLocalError = error as? SpotifyGeneralError else {
                XCTFail("should've received SpotifyGeneralError: \(error)")
                return
            }
            let expectedDescriptions = [
                "payload too large",
                "request too large"
            ]
            let description = spotifyLocalError.localizedDescription.lowercased()
            XCTAssert(
                expectedDescriptions.contains(description),
                "unexpected description: \(description)"
            )
            guard case .httpError(_, let response) = spotifyLocalError else {
                XCTFail(
                    "should've received SpotifyGeneralError.httpError: " +
                    "\(spotifyLocalError)"
                )
                return
            }
            XCTAssertEqual(response.statusCode, 413)

        }
        
        let spotifyDecodeLogLevel = spotifyDecodeLogger.logLevel
        spotifyDecodeLogger.logLevel = .warning
        let apiRequestLogLevel = Self.spotify.apiRequestLogger.logLevel
        Self.spotify.apiRequestLogger.logLevel = .warning

        let expectation = XCTestExpectation(
            description: "uploadTooLargePlaylistImage"
        )
        
        var createdPlaylistURI: String? = nil

        Self.spotify.currentUserProfile()
            .XCTAssertNoFailure()
            .flatMap { user -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                // MARK: Create Playlist
                let playlistDetails = PlaylistDetails(
                    name: "upload too large image test",
                    isPublic: true,
                    isCollaborative: nil,
                    description: Date().description(with: .current)
                )
                return Self.spotify.createPlaylist(
                    for: user.uri,
                    playlistDetails
                )
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 2)
            .flatMap { playlist -> AnyPublisher<Void, Error> in
                // MARK: Upload Image
                createdPlaylistURI = playlist.uri

                let imageData = SpotifyExampleImages.annabelleTooLarge
                let encodedData = imageData.base64EncodedData()

                print("encoded data count: ", encodedData.count)
                
                return Self.spotify.uploadPlaylistImage(
                    playlist,
                    imageData: encodedData
                )
            }
            .sink(
                receiveCompletion: { completion in
                    receiveUploadImageCompletion(completion)
                    expectation.fulfill()
                },
                receiveValue: {
                    XCTFail("should not receive value")
                }
            )
            .store(in: &Self.cancellables)
            
        self.wait(for: [expectation], timeout: 300)
        
        // MARK: Unfollow Playlist
        
        guard let playlist = createdPlaylistURI else {
            XCTFail("couldn't get created playlist")
            return
        }
        
        let unfollowExpectation = XCTestExpectation(
            description: "unfollow playlist"
        )
    
        Self.spotify.unfollowPlaylistForCurrentUser(playlist)
            .XCTAssertNoFailure()
            .sink(receiveCompletion: { _ in
                unfollowExpectation.fulfill()
            })
            .store(in: &Self.cancellables)
        
        self.wait(for: [unfollowExpectation], timeout: 60)
        
        spotifyDecodeLogger.logLevel = spotifyDecodeLogLevel
        Self.spotify.apiRequestLogger.logLevel = apiRequestLogLevel
            
    }
}

// MARK: - Client -

final class SpotifyAPIClientCredentialsFlowErrorTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIErrorTests
{

    static let allTests = [
        (
            "testMakeRequestWithoutAuthorization",
            testMakeRequestWithoutAuthorization
        ),
        (
            "makeRequestWithInvalidAccessToken",
            makeRequestWithInvalidAccessToken
        ),
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
        ("testNonRetryableErrors", testNonRetryableErrors),
        ("testDecodeOptionalSpotifyObject", testDecodeOptionalSpotifyObject)
        
    ]

    func testMakeRequestWithoutAuthorization() {
        makeRequestWithoutAuthorization()
    }
    func testMakeRequestWithInvalidAccessToken() {
        makeRequestWithInvalidAccessToken()
    }
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
    func testDecodeOptionalSpotifyObject() {
        decodeOptionalSpotifyObject()
    }
    
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
        ("testRetryOnSpotifyErrors", testRetryOnSpotifyErrors),
        ("testExceedRetryLimit", testExceedRetryLimit),
        ("testNonRetryableErrors", testNonRetryableErrors),
        ("testDecodeOptionalSpotifyObject", testDecodeOptionalSpotifyObject),
        ("testDecodeSpotifyPlayerError", testDecodeSpotifyPlayerError),
        ("testUploadTooLargePlaylistImage", testUploadTooLargePlaylistImage)
    ]

    
    func testMakeRequestWithoutAuthorization() {
        makeRequestWithoutAuthorization()
    }
    func testMakeRequestWithInvalidAccessToken() {
        makeRequestWithInvalidAccessToken()
    }
    func testAutoRetryOnRateLimitedErrorConcurrent() {
        autoRetryOnRateLimitedErrorConcurrent()
    }
    func testAutoRetryOnRateLimitedErrorSerial() { autoRetryOnRateLimitedErrorSerial() }
    func testDecodeSpotifyErrorFromInvalidAlbumURI() {
        decodeSpotifyErrorFromInvalidAlbumURI()
    }
    func testRetryOnSpotifyErrors() { retryOnSpotifyErrors() }
    func testExceedRetryLimit() { exceedRetryLimit() }
    func testNonRetryableErrors() { nonRetryableErrors() }
    func testDecodeOptionalSpotifyObject() {
        decodeOptionalSpotifyObject()
    }
    func testDecodeSpotifyPlayerError() {
        decodeSpotifyPlayerError()
    }
    func testUploadTooLargePlaylistImage() {
        uploadTooLargePlaylistImage()
    }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEProxyErrorTests:
    SpotifyAPIAuthorizationCodeFlowPKCEProxyTests, SpotifyAPIErrorTests
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
        ("testNonRetryableErrors", testNonRetryableErrors),
        ("testDecodeOptionalSpotifyObject", testDecodeOptionalSpotifyObject),
        ("testDecodeSpotifyPlayerError", testDecodeSpotifyPlayerError),
        ("testUploadTooLargePlaylistImage", testUploadTooLargePlaylistImage)
    ]

    func testMakeRequestWithoutAuthorization() {
        makeRequestWithoutAuthorization()
    }
    func testMakeRequestWithInvalidAccessToken() {
        makeRequestWithInvalidAccessToken()
    }
    func testAutoRetryOnRateLimitedErrorConcurrent() {
        autoRetryOnRateLimitedErrorConcurrent()
    }
    func testAutoRetryOnRateLimitedErrorSerial() { autoRetryOnRateLimitedErrorSerial() }
    func testDecodeSpotifyErrorFromInvalidAlbumURI() {
        decodeSpotifyErrorFromInvalidAlbumURI()
    }
    func testRetryOnSpotifyErrors() { retryOnSpotifyErrors() }
    func testExceedRetryLimit() { exceedRetryLimit() }
    func testNonRetryableErrors() { nonRetryableErrors() }
    func testDecodeOptionalSpotifyObject() {
        decodeOptionalSpotifyObject()
    }
    func testDecodeSpotifyPlayerError() {
        decodeSpotifyPlayerError()
    }
    func testUploadTooLargePlaylistImage() {
        uploadTooLargePlaylistImage()
    }
    
 }
