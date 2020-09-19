import Foundation
import Combine
import XCTest
import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyURIs

class SpotifyAPIPlayerTests: SpotifyAPIAuthorizationCodeFlowTests {
    
    static let allTests = [
        ("testPlayPause", testPlayPause)
    ]
    
    func testPlayPause() {
        
        let expectation = XCTestExpectation(description: "testPlayPause")
        
        let playlist = URIs.Playlists.thisIsPinkFloyd
        
        let playbackRequest = PlaybackRequest(
            context: .contextURI(playlist),
            offset: .position(21),  // Any Colour You Like
            positionMS: 100_000
        )
        
        encodeDecode(playbackRequest)
        
        func checkPlaybackContext(_ context: CurrentlyPlayingContext?) {
            encodeDecode(context)
            guard let context = context else {
                XCTFail("CurrentlyPlayingContext should not be nil")
                return
            }
            encodeDecode(context)
            
            XCTAssertTrue(context.isPlaying)
            XCTAssert(
                context.item?.name.starts(with: "Any Colour You Like") ?? false,
                "\(context.item?.name ?? "nil") should start with " +
                    "'Any Colour You Like'"
            )
            
            XCTAssertEqual(context.context?.uri, playlist.uri)
            if let progress = context.progressMS {
                XCTAssert((100_000...120_000).contains(progress))
            }
            else {
                XCTFail("context.progressMS should not be nil")
            }
            if case .track(let track) = context.item {
                XCTAssertEqual(track.artists?.first?.name, "Pink Floyd")
                XCTAssert(
                    track.album?.name.starts(with: "The Dark Side Of The Moon") ?? false,
                    "\(track.album?.name ?? "nil") should start with " +
                        "'The Dark Side Of The Moon'"
                )
            }
            else {
                XCTFail("context.item should be track")
            }
        }
        
        do {
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
                    checkPlaybackContext(context)
                    return Self.spotify.pausePlayback()
                }
                .XCTAssertNoFailure()
                .delay(for: 1, scheduler: DispatchQueue.global())
                .flatMap(Self.spotify.currentPlayback)
                .XCTAssertNoFailure()
                .flatMap { context -> AnyPublisher<Void, Error> in
                    encodeDecode(context)
                    if let context = context {
                        XCTAssertFalse(context.isPlaying)
                    }
                    else {
                        XCTFail("CurrentlyPlayingContext should not be nil")
                    }
                    return Self.spotify.resumePlayback()
                }
                .XCTAssertNoFailure()
                .delay(for: 1, scheduler: DispatchQueue.global())
                .flatMap(Self.spotify.currentPlayback)
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { _ in expectation.fulfill() },
                    receiveValue: checkPlaybackContext(_:)
                )
                .store(in: &Self.cancellables)
            
        }
     
        wait(for: [expectation], timeout: 120)
        

    }
    
    func testPlayback() {
        
        let items = URIs.Tracks.array(
            .partIII, .plants, .jinx, .illWind, .nuclearFusion
        ) + URIs.Episodes.array(
            .samHarris212, .joeRogan1531
        )
        
        let selectedItem = items.randomElement()!
        
        let playbackRequest = PlaybackRequest(
            context: .uris(items),
            offset: .uri(selectedItem),
            positionMS: 150_000
        )

        encodeDecode(playbackRequest)
        
        var activeDeviceId: String? = nil
        
        func checkPlaybackContext(_ context: CurrentlyPlayingContext?) {
            encodeDecode(context)
            guard let context = context else {
                XCTFail("CurrentlyPlayingContext should not be nil")
                return
            }
            encodeDecode(context)
            
            XCTAssertTrue(context.isPlaying)
            XCTAssertEqual(context.device.id, activeDeviceId)
            XCTAssertEqual(context.item?.uri, selectedItem)
            if let progress = context.progressMS {
                XCTAssert((150_000...170_000).contains(progress))
            }
            else {
                XCTFail("context.progressMS should not be nil")
            }
            
        }
        
        let expectation = XCTestExpectation(description: "testPlayPause")
        
        Self.spotify.availableDevices()
            .flatMap { devices -> AnyPublisher<Void, Error> in
                encodeDecode(devices)
                guard let activeDevice = devices.first(where: { device in
                    device.isActive
                }) else {
                    return SpotifyLocalError.other("no active device")
                        .anyFailingPublisher(Void.self)
                }
                activeDeviceId = activeDevice.id
                return Self.spotify.play(
                    playbackRequest, deviceId: activeDeviceId
                )
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: checkPlaybackContext(_:)
            )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 60)
        
    }
    
    func testSingleTrackPlayback() {
        
        let track = URIs.Tracks.allCases.randomElement()!
        
        let playbackRequest = PlaybackRequest(
            context: .uris([track]),
            offset: nil
        )

        encodeDecode(playbackRequest)
        
        var activeDeviceId: String? = nil
        
        func checkPlaybackContext(_ context: CurrentlyPlayingContext?) {
            encodeDecode(context)
            guard let context = context else {
                XCTFail("CurrentlyPlayingContext should not be nil")
                return
            }
            encodeDecode(context)
            
            XCTAssertTrue(context.isPlaying)
            XCTAssertEqual(context.device.id, activeDeviceId)
            XCTAssertEqual(context.item?.uri, track.uri)
        }
        
        let expectation = XCTestExpectation(description: "testPlayPause")
        
        Self.spotify.availableDevices()
            .flatMap { devices -> AnyPublisher<Void, Error> in
                encodeDecode(devices)
                guard let activeDevice = devices.first(where: { device in
                    device.isActive
                }) else {
                    return SpotifyLocalError.other("no active device")
                        .anyFailingPublisher(Void.self)
                }
                activeDeviceId = activeDevice.id
                return Self.spotify.play(
                    playbackRequest, deviceId: activeDeviceId
                )
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: checkPlaybackContext(_:)
            )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 60)
        
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
                if let context = context {
                    XCTAssertFalse(context.shuffleIsOn)
                }
                else {
                    XCTFail("CurrentlyPlayingContext should not be nil")
                }
                return Self.spotify.setShuffle(to: true)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                if let context = context {
                    XCTAssertTrue(context.shuffleIsOn)
                }
                else {
                    XCTFail("CurrentlyPlayingContext should not be nil")
                }
                return Self.spotify.setShuffle(to: false)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { context in
                    if let context = context {
                        XCTAssertFalse(context.shuffleIsOn)
                    }
                    else {
                        XCTFail("CurrentlyPlayingContext should not be nil")
                    }
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
                if let context = context {
                    XCTAssertEqual(context.repeatState, .track)
                }
                else {
                    XCTFail("CurrentlyPlayingContext should not be nil")
                }
                return Self.spotify.setRepeatMode(to: .context)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                if let context = context {
                    XCTAssertEqual(context.repeatState, .context)
                }
                else {
                    XCTFail("CurrentlyPlayingContext should not be nil")
                }
                return Self.spotify.setRepeatMode(to: .off)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                if let context = context {
                    XCTAssertEqual(context.repeatState, .off)
                }
                else {
                    XCTFail("CurrentlyPlayingContext should not be nil")
                }
                return Self.spotify.setRepeatMode(to: .track)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.global())
            .flatMap(Self.spotify.currentPlayback)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { context in
                    if let context = context {
                        XCTAssertEqual(context.repeatState, .track)
                    }
                    else {
                        XCTFail("CurrentlyPlayingContext should not be nil")
                    }
                }
            )
            .store(in: &Self.cancellables)
            
            wait(for: [expectation], timeout: 120)
        
    }
    
}

