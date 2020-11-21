import Foundation
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
import XCTest
import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

protocol SpotifyAPIPlayerTests: SpotifyAPITests { }

extension SpotifyAPIPlayerTests where AuthorizationManager: SpotifyScopeAuthorizationManager {

    func playPause() {
        
        let expectation = XCTestExpectation(description: "testPlayPause")
        
        let playlist = URIs.Playlists.thisIsPinkFloyd
        
        let playbackRequest = PlaybackRequest(
            context: .contextURI(playlist),
            offset: .uri("spotify:track:1wGoqD0vrf7njGvxm8CEf5"),  // Any Colour You Like
            positionMS: 100_000  // 1 minute 40 seconds
        )
        
        encodeDecode(playbackRequest)
        
        func checkPlaybackContext(_ context: CurrentlyPlayingContext?) {
            encodeDecode(context)
            guard let context = context else {
                XCTFail("CurrentlyPlayingContext should not be nil")
                return
            }
            encodeDecode(context)
            
            let difference = Date().timeIntervalSince1970 -
                    context.timestamp.timeIntervalSince1970
            XCTAssert((0...20).contains(difference), "timestamp is incorrect")
            
            XCTAssertTrue(context.isPlaying)
            XCTAssertEqual(context.itemType, .track)
            if let currentItem = context.item {
                XCTAssert(
                    currentItem.name.starts(with: "Any Colour You Like"),
                    "\(currentItem.name) should start with " +
                        "'Any Colour You Like'"
                )
            }
            else {
                XCTFail("context.currentlyPlayingItem should not be nil")
            }
            
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
                XCTFail("context.currentlyPlayingItem should be track")
            }
        }
        
        let publisher: AnyPublisher<CurrentlyPlayingContext?, Error> =
            Self.spotify.play(playbackRequest)
            // This test will fail if you don't have an active
            // device. Open a Spotify client (such as the iOS app)
            // and ensure it's logged in to the same account used to
            // authroize the access token. Then, run the tests again.
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .flatMap { context -> AnyPublisher<Void, Error> in
                checkPlaybackContext(context)
                return Self.spotify.pausePlayback()
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()
            
        publisher
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
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: checkPlaybackContext(_:)
            )
            .store(in: &Self.cancellables)
            
        self.wait(for: [expectation], timeout: 120)
        

    }
    
    func playAndCurrentPlaybackForEpisode() {

        func checkContext(_ context: CurrentlyPlayingContext?) {
            encodeDecode(context)
            guard let context = context else {
                XCTFail("CurrentlyPlayingContext should not be nil")
                return
            }
            encodeDecode(context)

            XCTAssertTrue(context.isPlaying)
            XCTAssertEqual(context.itemType, .episode)

            let difference = Date().timeIntervalSince1970 -
                    context.timestamp.timeIntervalSince1970
            XCTAssert(
                (0...20).contains(difference),
                "timestamp is incorrect: \(context.timestamp)"
            )

            if let progress = context.progressMS {
                XCTAssert(
                    (2_000_000...2_020_000).contains(progress),
                    "\(progress)"
                )
            }
            else {
                XCTFail("context.progressMS should not be nil")
            }

            if let context = context.context {
                XCTAssertEqual(context.uri, URIs.Shows.samHarris.uri)
                XCTAssertEqual(context.type, .show)
                XCTAssertEqual(
                    context.href,
                    "https://api.spotify.com/v1/shows/5rgumWEx4FsqIY8e1wJNAk"
                )
                if let externalURLs = context.externalURLs {
                    XCTAssertEqual(
                        externalURLs["spotify"],
                        "https://open.spotify.com/show/5rgumWEx4FsqIY8e1wJNAk",
                        "\(externalURLs)"
                    )
                }
                else {
                    XCTFail("externalURLs should not be nil")
                }
            }

            if let playlistItem = context.item {
                XCTAssertEqual(
                    playlistItem.name, "#217 — The New Religion of Anti-Racism"
                )
                XCTAssertEqual(
                    playlistItem.uri, "spotify:episode:7nsYz7tSJryO5vVYtkKiot"
                )

                if case .episode(let episode) = playlistItem {
                    XCTAssertEqual(
                        episode.name, "#217 — The New Religion of Anti-Racism"
                    )
                    XCTAssertEqual(
                        episode.uri, "spotify:episode:7nsYz7tSJryO5vVYtkKiot"
                    )
                    XCTAssertEqual(
                        episode.type, .episode
                    )

                    XCTAssertEqual(
                        episode.description,
                        """
                        In this episode of the podcast, Sam Harris speaks with \
                        John McWhorter about race, racism, and “anti-racism” in \
                        America. They discuss how conceptions of racism have \
                        changed, the ubiquitous threat of being branded a \
                        “racist,” the contradictions within identity politics, \
                        recent echoes of the OJ verdict, willingness among \
                        progressives to lose the 2020 election, racism as the \
                        all-purpose explanation of racial disparities in the \
                        U.S., double standards for the black community, the war \
                        on drugs, the lure of identity politics, police violence, \
                        the enduring riddle of affirmative action, the politics of \
                        “black face,” and other topics. SUBSCRIBE to gain access \
                        to all content on samharris.org/subscribe
                        """.strip()
                    )

                    if let releaseDate = episode.releaseDate {
                        XCTAssertEqual(
                            releaseDate.timeIntervalSince1970,
                            1600300800,
                            accuracy: 43_200  // 12 hours
                        )
                    }
                    else {
                        XCTFail("release date should not be nil")
                    }
                    XCTAssertEqual(episode.releaseDatePrecision, "day")

                    if let show = episode.show {
                        XCTAssertEqual(
                            show.description,
                            """
                            Join neuroscientist, philosopher, and best-selling author \
                            Sam Harris as he explores important and controversial \
                            questions about the human mind, society, and current \
                            events.  Sam Harris is the author of The End of Faith, \
                            Letter to a Christian Nation, The Moral Landscape, \
                            Free Will, Lying, Waking Up, and Islam and the Future \
                            of Tolerance (with Maajid Nawaz). The End of Faith won \
                            the 2005 PEN Award for Nonfiction. His writing has been \
                            published in more than 20 languages. Mr. Harris and \
                            his work have been discussed in The New York Times, \
                            Time, Scientific American, Nature, Newsweek, Rolling \
                            Stone, and many other journals. His writing has appeared \
                            in The New York Times, The Los Angeles Times, The \
                            Economist, Newsweek, The Times (London), The Boston \
                            Globe, The Atlantic, The Annals of Neurology, and \
                            elsewhere.  Mr. Harris received a degree in philosophy \
                            from Stanford University and a Ph.D. in neuroscience \
                            from UCLA.
                            """.strip()
                        )

                    }
                    else {
                        XCTFail("episode should contain show")
                    }
                }
                else {
                    XCTFail("PlaylistItem should be episode")
                }

            }
            else {
                XCTFail("context.currentlyPlayingItem should not be nil")
            }


        }

        func checkEpisode(_ episode: Episode) {
            if let resumePoint = episode.resumePoint {
                XCTAssertFalse(resumePoint.fullyPlayed)
                let resumePosition = resumePoint.resumePositionMS
                XCTAssert(
                    (2_000_000...2_020_000).contains(resumePosition),
                    "\(resumePosition)"
                )
            }
            else {
                XCTFail("resume point should not be nil")
            }
            XCTAssertEqual(episode.uri, "spotify:episode:7nsYz7tSJryO5vVYtkKiot")
            XCTAssertEqual(episode.id, "7nsYz7tSJryO5vVYtkKiot")
            XCTAssertEqual(episode.name, "#217 — The New Religion of Anti-Racism")
        }

        let expectation = XCTestExpectation(
            description: "testPlayCurrentPlaybackForEpisode"
        )

        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Shows.samHarris),
            offset: .uri(URIs.Episodes.samHarris217),
            positionMS: 2_000_000  // 33:20
        )

        encodeDecode(playbackRequest)

        Self.spotify.play(playbackRequest)
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback(market: "US")
            }
            .XCTAssertNoFailure()
            .flatMap { playback -> AnyPublisher<Episode, Error> in
                checkContext(playback)
                return Self.spotify.episode(
                    URIs.Episodes.samHarris217,
                    market: "US"
                )
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: checkEpisode(_:)
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 120)

    }

    /// Play an album, skip to the next track, then skip to the
    /// previous track.
    func playSkipToNextAndPrevious() {

        let spotifyAPILogLevel = Self.spotify.logger.logLevel
        let authorizationCodeFlowManagerLogLevel =
                AuthorizationCodeFlowManager.logger.logLevel
        let authorizationCodeFlowPKCEManagerLogLevel =
                AuthorizationCodeFlowPKCEManager.logger.logLevel

        Self.spotify.logger.logLevel = .warning
        AuthorizationCodeFlowPKCEManager.logger.logLevel = .warning
        AuthorizationCodeFlowManager.logger.logLevel = .warning

        // setup repeat and shuffle
        do {
            let repeatExpectation = XCTestExpectation(
                description: "testPlayNextPrevious: repeat"
            )

            let shuffleExpectation = XCTestExpectation(
                description: "testPlayNextPrevious: shuffle"
            )
            let skipExpectation = XCTestExpectation(
                description: "testPlayNextPrevious: skip"
            )

            // Ensure that repeat mode is set to the current context
            // and shuffle is off so that skipping to the previous and
            // next tracks has predictable behavior.
            Self.spotify.setRepeatMode(to: .context)
                .XCTAssertNoFailure()
                .sink(receiveCompletion: { _ in
                    repeatExpectation.fulfill()
                })
                .store(in: &Self.cancellables)

            Self.spotify.setShuffle(to: false)
                .XCTAssertNoFailure()
                .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
                .sink(receiveCompletion: { _ in
                    shuffleExpectation.fulfill()
                })
                .store(in: &Self.cancellables)

            Self.spotify.skipToNext()
                .XCTAssertNoFailure()
                .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
                .flatMap { Self.spotify.skipToNext() }
                .XCTAssertNoFailure()
                .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
                .sink(receiveCompletion: { _ in
                    skipExpectation.fulfill()
                })
                .store(in: &Self.cancellables)

            self.wait(
                for: [repeatExpectation, shuffleExpectation, skipExpectation],
                timeout: 120
            )
        }

        /*
         The Dark Side of the Moon - spotify:album:4LH4d3cOWNNsVw41Gqt2kv

         0. Speak to Me
         1. Breathe (In the Air)
         2. On the Run
         3. Time
         4. The Great Gig in the Sky
         5. Money
         6. Us and Them
         7. Any Colour You Like
         8. Brain Damage
         9. Eclipse
         */

        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Albums.darkSideOfTheMoon),
            offset: .position(5)  // Money
        )

        let playbackExpectation = XCTestExpectation(
            description: "testPlayNextPrevious"
        )

        var didSkipToPrevious = false
        var didSkipToNext = false

        let publisher: AnyPublisher<CurrentlyPlayingContext?, Error> =
            Self.spotify.play(playbackRequest)
            .XCTAssertNoFailure()
            .delay(for: 2, scheduler: DispatchQueue.OCombine(.main))
            .flatMap(maxPublishers: .max(1)) {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .flatMap(maxPublishers: .max(1)) { playback -> AnyPublisher<Void, Error> in
                guard let playback = playback else {
                    return SpotifyLocalError.other("playback was nil")
                        .anyFailingPublisher()
                }
                encodeDecode(playback)
                let difference = Date().timeIntervalSince1970 -
                        playback.timestamp.timeIntervalSince1970
                XCTAssert(
                    (0...20).contains(difference),
                    "timestamp is incorrect: \(playback)"
                )
                XCTAssertFalse(playback.shuffleIsOn)
                XCTAssertEqual(playback.repeatState, .context)
                XCTAssertTrue(playback.isPlaying)
                XCTAssertEqual(
                    playback.itemType, .track,
                    "\(playback)"
                )
                XCTAssertEqual(
                    playback.item?.uri,
                    URIs.Tracks.money.uri,
                    "\(playback)"
                )
                XCTAssert(
                    playback.allowedActions.contains(.skipToNext),
                    "not allowed to skip to next track: " +
                    "\(playback.allowedActions)"
                )
                didSkipToNext = true
                return Self.spotify.skipToNext()
            }
            .XCTAssertNoFailure()
            .delay(for: 2, scheduler: DispatchQueue.OCombine(.main))
            .flatMap(maxPublishers: .max(1))  {
                Self.spotify.currentPlayback()
            }
            .delay(for: 2, scheduler: DispatchQueue.OCombine(.main))
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()

        let publisher2: AnyPublisher<Void, Error> = publisher
            .flatMap(maxPublishers: .max(1)) { playback -> AnyPublisher<Void, Error> in
                print("FLATMAP Received Playback: \(playback as Any)")
                guard let playback = playback else {
                    return SpotifyLocalError.other("playback was nil")
                        .anyFailingPublisher()
                }
                encodeDecode(playback)
                let difference = Date().timeIntervalSince1970 -
                        playback.timestamp.timeIntervalSince1970
                XCTAssert((0...20).contains(difference), "timestamp is incorrect")
                XCTAssertFalse(playback.shuffleIsOn)
                XCTAssertEqual(playback.repeatState, .context)
                XCTAssertTrue(playback.isPlaying)
                XCTAssertEqual(playback.itemType, .track)
                XCTAssertEqual(
                    playback.item?.uri,
                    URIs.Tracks.usAndThem.uri
                )
                XCTAssert(
                    playback.allowedActions.contains(.skipToPrevious),
                    "not allowed to skip to previous track"
                )
                // MARK: - Skip To Previous -
                print("\nWILL SKIP TO PREVIOUS\n")
                didSkipToPrevious = true
                return Self.spotify.skipToPrevious()
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()

        publisher2
            .delay(for: 2, scheduler: DispatchQueue.OCombine(.main))
            .flatMap(maxPublishers: .max(1))  {
                Self.spotify.currentPlayback()
            }
            .sink(
                receiveCompletion: { completion in
                    XCTAssertFinishedNormally(completion)
                    print(
                        "testPlaySkipToNextAndPrevious: completion: " +
                        "\(completion)"
                    )
                    playbackExpectation.fulfill()
                },
                receiveValue: { playback in
                    guard let playback = playback else {
                        XCTFail("playback was nil")
                        return
                    }
                    encodeDecode(playback)
                    let difference = Date().timeIntervalSince1970 -
                            playback.timestamp.timeIntervalSince1970
                    XCTAssert((0...20).contains(difference), "timestamp is incorrect")
                    XCTAssertFalse(playback.shuffleIsOn)
                    XCTAssertEqual(playback.repeatState, .context)
                    XCTAssertTrue(playback.isPlaying)
                    XCTAssertEqual(playback.itemType, .track)
                    XCTAssertEqual(
                        playback.item?.uri,
                        URIs.Tracks.money.uri
                    )

                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [playbackExpectation], timeout: 300)
        XCTAssertTrue(didSkipToNext)
        XCTAssertTrue(didSkipToPrevious)

        Self.spotify.logger.logLevel = spotifyAPILogLevel
        AuthorizationCodeFlowManager.logger.logLevel =
                authorizationCodeFlowManagerLogLevel
        AuthorizationCodeFlowPKCEManager.logger.logLevel =
                authorizationCodeFlowPKCEManagerLogLevel


    }

    func playSeekToPositionAndSetVolume() {

        let repeatExpectation = XCTestExpectation(
            description: "testPlayNextPrevious: repeat"
        )

        let shuffleExpectation = XCTestExpectation(
            description: "testPlayNextPrevious: shuffle"
        )

        // Ensure that repeat mode is set to the current context
        // and shuffle is off so that skipping to the previous and
        // next tracks has predictable behavior.
        Self.spotify.setRepeatMode(to: .context)
            .XCTAssertNoFailure()
            .sink(receiveCompletion: { _ in
                repeatExpectation.fulfill()
            })
            .store(in: &Self.cancellables)

        Self.spotify.setShuffle(to: false)
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .sink(receiveCompletion: { _ in
                shuffleExpectation.fulfill()
            })
            .store(in: &Self.cancellables)

        self.wait(for: [repeatExpectation, shuffleExpectation], timeout: 120)


        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Albums.inRainbows),
            offset: nil
        )

        let newVolume = Int.random(in: 0...100)
        var trackDuration: Int? = nil
        var newPosition: Int? = nil

        let expectation = XCTestExpectation(
            description: "testPlaySeekToPositionAndSetVolume"
        )

        let publisher: AnyPublisher<Void, Error> = Self.spotify.play(playbackRequest)
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .flatMap { playback -> AnyPublisher<Void, Error> in
                guard let playback = playback else {
                    return SpotifyLocalError.other("playback was nil")
                        .anyFailingPublisher()
                }
                encodeDecode(playback)
                let difference = Date().timeIntervalSince1970 -
                        playback.timestamp.timeIntervalSince1970
                XCTAssert((0...20).contains(difference), "timestamp is incorrect")
                XCTAssertTrue(playback.isPlaying)
                XCTAssertEqual(
                    playback.itemType, .track,
                    "\(playback)"
                )
                XCTAssertEqual(
                    playback.context?.uri,
                    URIs.Albums.inRainbows.uri
                )

                if case .track(let track) = playback.item {
                    XCTAssertEqual(
                        track.artists?.first?.name,
                        "Radiohead"
                    )
                    XCTAssertEqual(
                        track.artists?.first?.uri,
                        "spotify:artist:4Z8W4fKeB5YxbusRsdQVPb"
                    )
                    XCTAssertEqual(track.album?.name, "In Rainbows")

                }
                else {
                    XCTFail("current playback should be track")
                }

                trackDuration = playback.item?.durationMS

                print(
                    "setting volume for \(playback.device.name) " +
                    "to \(newVolume)"
                )
                return Self.spotify.setVolume(to: newVolume)
            }
            .catch { error -> AnyPublisher<Void, Error> in
                if let spotifyPlayerError = error as? SpotifyPlayerError {
                    XCTAssertEqual(
                        spotifyPlayerError.reason, .volumeControlDisallow,
                        "\(spotifyPlayerError)"
                    )
                }
                else {
                    XCTFail("unexpected error: \(error)")
                }
                return Result.OCombine.Publisher(()).eraseToAnyPublisher()
            }
            .XCTAssertNoFailure()

        publisher
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap { () -> AnyPublisher<Void, Error> in
                guard let trackDuration = trackDuration else {
                    return SpotifyLocalError.other(
                        "couldn't track duration"
                    )
                    .anyFailingPublisher()
                }

                newPosition = Int.random(
                    in: 20_000...(trackDuration - 20_000)
                )

                return Self.spotify.seekToPosition(newPosition!)
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { playback in
                    guard let playback = playback else {
                        XCTFail("playback was nil")
                        return
                    }
                    encodeDecode(playback)
                    let difference = Date().timeIntervalSince1970 -
                            playback.timestamp.timeIntervalSince1970
                    XCTAssert((0...20).contains(difference), "timestamp is incorrect")
                    XCTAssertTrue(playback.isPlaying)
                    XCTAssertEqual(
                        playback.itemType, .track,
                        "\(playback)"
                    )
                    XCTAssertEqual(
                        playback.context?.uri,
                        URIs.Albums.inRainbows.uri
                    )

                    guard let newPosition = newPosition else {
                        XCTFail("couldn't get new track position")
                        return
                    }

                    let expectedRange = newPosition...(newPosition + 20_000)
                    guard let progress = playback.progressMS else {
                        XCTFail("progress for track was nil")
                        return
                    }
                    XCTAssert(
                        expectedRange.contains(progress),
                        "After seeking to \(newPosition), progress" +
                        "should be in the range \(expectedRange)"
                    )
                }

            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)

    }
    
    /// Play content using a specific device id.
    func playback() {

        let items = URIs.Tracks.array(
            .partIII, .plants, .jinx, .illWind, .nuclearFusion
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
            let difference = Date().timeIntervalSince1970 -
                    context.timestamp.timeIntervalSince1970
            XCTAssert((0...20).contains(difference), "timestamp is incorrect")
            XCTAssertTrue(context.isPlaying)
            XCTAssertEqual(context.itemType, .track)
            XCTAssertEqual(context.device.id, activeDeviceId)
            XCTAssertEqual(context.item?.uri, selectedItem)
            if let progress = context.progressMS {
                XCTAssert((150_000...170_000).contains(progress))
            }
            else {
                XCTFail("context.progressMS should not be nil")
            }

        }

        let expectation = XCTestExpectation(description: "testPlayback")

        Self.spotify.availableDevices()
            .XCTAssertNoFailure()
            .flatMap { devices -> AnyPublisher<Void, Error> in
                encodeDecode(devices)
                guard let activeDevice = devices.first(where: { device in
                    device.isActive
                }) else {
                    return SpotifyLocalError.other("no active device")
                        .anyFailingPublisher()
                }
                activeDeviceId = activeDevice.id
                return Self.spotify.play(
                    playbackRequest, deviceId: activeDeviceId
                )
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: checkPlaybackContext(_:)
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 60)

    }

    func singleTrackPlayback() {

        let track = URIs.Tracks.allCases.randomElement()!

        let playbackRequest = PlaybackRequest(track)

        encodeDecode(playbackRequest)

        var activeDeviceId: String? = nil

        func checkPlaybackContext(_ context: CurrentlyPlayingContext?) {
            encodeDecode(context)
            guard let context = context else {
                XCTFail("CurrentlyPlayingContext should not be nil")
                return
            }
            encodeDecode(context)
            let difference = Date().timeIntervalSince1970 -
                    context.timestamp.timeIntervalSince1970
            XCTAssert((0...20).contains(difference), "timestamp is incorrect")
            XCTAssertTrue(context.isPlaying)
            XCTAssertEqual(context.itemType, .track)
            XCTAssertEqual(context.device.id, activeDeviceId)
            XCTAssertEqual(context.item?.uri, track.uri)
        }

        let expectation = XCTestExpectation(description: "testPlayPause")

        Self.spotify.availableDevices()
            .XCTAssertNoFailure()
            .flatMap { devices -> AnyPublisher<Void, Error> in
                encodeDecode(devices)
                guard let activeDevice = devices.first(where: { device in
                    device.isActive
                }) else {
                    return SpotifyLocalError.other("no active device")
                        .anyFailingPublisher()
                }
                activeDeviceId = activeDevice.id
                return Self.spotify.play(
                    playbackRequest, deviceId: activeDeviceId
                )
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: checkPlaybackContext(_:)
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 60)

    }

    func playHistory() {

        let expectationCurrentDate = XCTestExpectation(
            description: "testInvalidDatePlayHistory: current date"
        )

        let expectationDistantPast = XCTestExpectation(
            description: "testInvalidDatePlayHistory: distant past"
        )

        Self.spotify.recentlyPlayed(.before(Date()))
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in
                    expectationCurrentDate.fulfill()
                },
                receiveValue: { recentlyPlayed in
                    encodeDecode(recentlyPlayed)
                }
            )
            .store(in: &Self.cancellables)

        let distantPast = Date().addingTimeInterval(-500_000_000)

        Self.spotify.recentlyPlayed(.before(distantPast))
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in
                    expectationDistantPast.fulfill()
                },
                receiveValue: { recentlyPlayed in
                    encodeDecode(recentlyPlayed)
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectationCurrentDate, expectationDistantPast], timeout: 120)

    }

    func addToQueue() {

        let queueItems: [SpotifyURIConvertible] = [
            URIs.Tracks.because,
            URIs.Episodes.samHarris213
        ]

        for (i, queueItem) in queueItems.enumerated() {

            let expectation = XCTestExpectation(
                description: "testAddToQueue \(i)"
            )

            Self.spotify.addToQueue(queueItem)
                .XCTAssertNoFailure()
                // .breakpoint(receiveOutput: { _ in true })
                .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
                .flatMap { Self.spotify.skipToNext() }
                .XCTAssertNoFailure()
                .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
                // .breakpoint(receiveOutput: { _ in true })
                .flatMap { Self.spotify.skipToNext() }
                .XCTAssertNoFailure()
                // .breakpoint(receiveOutput: { _ in true })
                .sink(
                    receiveCompletion: { _ in expectation.fulfill() },
                    receiveValue: { }
                )
                .store(in: &Self.cancellables)

            self.wait(for: [expectation], timeout: 60)

        }

        for (i, queueItem) in queueItems.enumerated() {

            let expectation = XCTestExpectation(
                description: "testAddToQueue \(i)"
            )

            Self.spotify.availableDevices()
                .XCTAssertNoFailure()
                .flatMap { devices -> AnyPublisher<Void, Error> in
                    encodeDecode(devices)
                    if let activeDevice = devices.first(
                        where: { $0.isActive }
                    ) {
                        return Self.spotify.addToQueue(
                            queueItem, deviceId: activeDevice.id
                        )
                    }
                    return SpotifyLocalError.other("no active device found")
                        .anyFailingPublisher()
                }
                .XCTAssertNoFailure()
                .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
                // .breakpoint(receiveOutput: { _ in true })
                .flatMap { Self.spotify.skipToNext() }
                .XCTAssertNoFailure()
                .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
                // .breakpoint(receiveOutput: { _ in true })
                .flatMap { Self.spotify.skipToNext() }
                .XCTAssertNoFailure()
                .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
                // .breakpoint(receiveOutput: { _ in true })
                .sink(
                    receiveCompletion: { _ in expectation.fulfill() },
                    receiveValue: { }
                )
                .store(in: &Self.cancellables)

            self.wait(for: [expectation], timeout: 60)

        }


    }

    func shuffle() {

        let expectation = XCTestExpectation(
            description: "testShuffle"
        )

        let publisher: AnyPublisher<CurrentlyPlayingContext?, Error> =
            Self.spotify.setShuffle(to: false)
            // This test will fail if you don't have an active
            // device. Open a Spotify client (such as the iOS app)
            // and ensure it's logged in to the same account used to
            // authroize the access token. Then, run the tests again.
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
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
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()

        publisher
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
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
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

            self.wait(for: [expectation], timeout: 120)

    }

    func repeatMode() {

        let expectation = XCTestExpectation(
            description: "testRepeat"
        )

        let publisher: AnyPublisher<CurrentlyPlayingContext?, Error> =
            Self.spotify.setRepeatMode(to: .track)
            // This test will fail if you don't have an active
            // device. Open a Spotify client (such as the iOS app)
            // and ensure it's logged in to the same account used to
            // authroize the access token. Then, run the tests again.
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
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
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()

        let publisher2: AnyPublisher<CurrentlyPlayingContext?, Error> = publisher
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
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()

        publisher2
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
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
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

            self.wait(for: [expectation], timeout: 120)

    }

    func transferPlayback() {

        Self.spotify.authorizationManager.setExpirationDate(to: Date())
        var authChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            .sink(receiveValue: {
                authChangeCount += 1
            })
            .store(in: &Self.cancellables)

        let expectation = XCTestExpectation(
            description: "testTransferPlayback"
        )

        // the device to transfer the playback to
        var transferDevice: Device? = nil

        let playbackRequest = PlaybackRequest(
            context: .contextURI(URIs.Artists.theBeatles),
            offset: nil
        )

        let publisher: AnyPublisher<Void, Error> = Self.spotify.play(playbackRequest)
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap(Self.spotify.availableDevices)
            .XCTAssertNoFailure()
            .flatMap { devices -> AnyPublisher<Void, Error> in

                guard let activeDevice = devices.first(
                    where: { $0.isActive }
                ) else {
                    return SpotifyLocalError.other("no active device to use")
                        .anyFailingPublisher()
                }

                // the device to transfer the playback to
                transferDevice = devices.first(where: { device in
                    device.id != activeDevice.id && !device.isActive &&
                            device.id != nil
                })
                if transferDevice == nil {
                    return SpotifyLocalError.other(
                        "couldn't find another available device to " +
                            "transfer playback to"
                    )
                    .anyFailingPublisher()
                }
                print(
                    """
                    -----------------------------------------------------
                    transfering playback from \(activeDevice.name) \
                    to \(transferDevice!.name)
                    -----------------------------------------------------
                    """
                )
                return Self.spotify.transferPlayback(
                    to: transferDevice!.id!, play: false
                )
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()

        publisher
            .delay(for: 1, scheduler: DispatchQueue.OCombine(.main))
            .flatMap {
                Self.spotify.currentPlayback()
            }
            .delay(for: 4, scheduler: DispatchQueue.OCombine(.main))
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { playback in
                    guard let playback = playback else {
                        XCTFail("playback was nil")
                        return
                    }
                    XCTAssertNotNil(playback.device.id)
                    XCTAssertNotNil(transferDevice?.id)
                    XCTAssertEqual(
                        playback.device.id,
                        transferDevice?.id
                    )
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 120)
        XCTAssertEqual(
            authChangeCount, 1,
            "authorizationManagerDidChange should emit exactly once"
        )


    }
    
}

final class SpotifyAPIAuthorizationCodeFlowPlayerTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIPlayerTests
{

    static let allTests = [
        ("testPlayPause", testPlayPause),
        ("testPlayAndCurrentPlaybackForEpisode", testPlayAndCurrentPlaybackForEpisode),
        ("testPlaySkipToNextAndPrevious", testPlaySkipToNextAndPrevious),
        ("testPlaySeekToPositionAndSetVolume", testPlaySeekToPositionAndSetVolume),
        ("testPlayback", testPlayback),
        ("testSingleTrackPlayback", testSingleTrackPlayback),
        ("testShuffle", testShuffle),
        ("testRepeatMode", testRepeatMode),
        ("testPlayHistory", testPlayHistory),
        ("testAddToQueue", testAddToQueue),
        ("testTransferPlayback", testTransferPlayback)
    ]

    override class func setUp() {
        super.setUp()
        spotifyDecodeLogger.logLevel = .trace
    }

    override class func tearDown() {
        spotifyDecodeLogger.logLevel = .warning
    }

    func testPlayPause() { playPause() }
    func testPlayAndCurrentPlaybackForEpisode() {
        playAndCurrentPlaybackForEpisode()
    }
    func testPlaySkipToNextAndPrevious() {
        // let max = 5
        // for i in 1...max {
            // print("\n--- Toplevel \(i) ---\n")
            playSkipToNextAndPrevious()
            // if i != max { sleep(5) }
        // }
    }
    func testPlaySeekToPositionAndSetVolume() {
        playSeekToPositionAndSetVolume()
    }
    func testPlayback() { playback() }
    func testSingleTrackPlayback() { singleTrackPlayback() }
    func testPlayHistory() { playHistory() }
    func testAddToQueue() { addToQueue() }
    func testShuffle() { shuffle() }
    func testRepeatMode() { repeatMode() }
    func testTransferPlayback() { transferPlayback() }

}

final class SpotifyAPIAuthorizationCodeFlowPKCEPlayerTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIPlayerTests
{

    static let allTests = [
        ("testPlayPause", testPlayPause),
        ("testPlayAndCurrentPlaybackForEpisode", testPlayAndCurrentPlaybackForEpisode),
        ("testPlaySkipToNextAndPrevious", testPlaySkipToNextAndPrevious),
        ("testPlaySeekToPositionAndSetVolume", testPlaySeekToPositionAndSetVolume),
        ("testPlayback", testPlayback),
        ("testSingleTrackPlayback", testSingleTrackPlayback),
        ("testShuffle", testShuffle),
        ("testRepeatMode", testRepeatMode),
        ("testPlayHistory", testPlayHistory),
        ("testAddToQueue", testAddToQueue),
        ("testTransferPlayback", testTransferPlayback)
    ]

    override class func setUp() {
        super.setUp()
        spotifyDecodeLogger.logLevel = .trace
    }

    override class func tearDown() {
        spotifyDecodeLogger.logLevel = .warning
    }

    func testPlayPause() { playPause() }
    func testPlayAndCurrentPlaybackForEpisode() {
        playAndCurrentPlaybackForEpisode()
    }
    func testPlaySkipToNextAndPrevious() {
        // let max = 5
        // for i in 1...max {
            // print("\n--- Toplevel \(i) ---\n")
            playSkipToNextAndPrevious()
            // if i != max { sleep(5) }
        // }
    }
    func testPlaySeekToPositionAndSetVolume() {
        playSeekToPositionAndSetVolume()
    }
    func testPlayback() { playback() }
    func testSingleTrackPlayback() { singleTrackPlayback() }
    func testPlayHistory() { playHistory() }
    func testAddToQueue() { addToQueue() }
    func testShuffle() { shuffle() }
    func testRepeatMode() { repeatMode() }
    func testTransferPlayback() { transferPlayback() }


}
