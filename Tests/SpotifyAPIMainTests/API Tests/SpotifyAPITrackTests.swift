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

protocol SpotifyAPITrackTests: SpotifyAPITests { }

extension SpotifyAPITrackTests {
    
    /// Because the sky is blue, it turns me on.
    func receiveBecause(_ track: Track) {
        
        print("\ncheckTrack: \(track.name)\n")
        
        encodeDecode(track)
        XCTAssertEqual(track.name, "Because - Remastered 2009")
        XCTAssertEqual(track.uri, "spotify:track:1rxoyGj1QuPoVi8fOft1Kt")
        XCTAssertEqual(track.id, "1rxoyGj1QuPoVi8fOft1Kt")
        XCTAssertEqual(
            track.href,
            URL(string: "https://api.spotify.com/v1/tracks/1rxoyGj1QuPoVi8fOft1Kt")!
        )
        XCTAssertFalse(track.isLocal)
        XCTAssertEqual(track.durationMS, 165666)
        XCTAssertFalse(track.isExplicit)
        XCTAssertEqual(track.isPlayable, true)
        
        // XCTAssertNotNil(track.availableMarkets)
        
        // if !(Self.spotify.authorizationManager is ClientCredentialsFlowManager) {
        //     XCTAssertNotNil(
        //         track.previewURL,
        //         "PREVIEW URL WAS NIL \(Self.self): authorization manager: " +
        //         "\(type(of: Self.spotify.authorizationManager))"
        //     )
        // }
        
        XCTAssertEqual(track.discNumber, 1)
        XCTAssertEqual(track.trackNumber, 8)
        XCTAssertEqual(track.type, .track)
        if let popularity = track.popularity {
            XCTAssert((0...100).contains(popularity), "\(popularity)")
        }
        else {
            XCTFail("popularity was nil")
        }
        
        if let externalIds = track.externalIds {
            XCTAssertEqual(
                externalIds["isrc"], "GBAYE0601697",
                "\(externalIds)"
            )
        }
        else {
            XCTFail("externalIds should not be nil")
        }
        
        if let externalURLs = track.externalURLs {
            XCTAssertEqual(
                externalURLs["spotify"],
                URL(string: "https://open.spotify.com/track/1rxoyGj1QuPoVi8fOft1Kt")!,
                "\(externalURLs)"
            )
        }
        else {
            XCTFail("externalURLs should not be nil")
        }
        
        // MARK: Check Album
        if let album = track.album {
            XCTAssertEqual(album.name, "Abbey Road (Remastered)")
            XCTAssertEqual(album.uri, "spotify:album:0ETFjACtuP2ADo6LFhL6HN")
            XCTAssertEqual(album.id, "0ETFjACtuP2ADo6LFhL6HN")
            XCTAssertEqual(album.albumType, .album)
            XCTAssertEqual(album.type, .album)
            
            if let releaseDate = album.releaseDate {
                XCTAssertEqual(
                    releaseDate.timeIntervalSince1970,
                    -8380800,
                    accuracy: 43_200
                )
            }
            else {
                XCTFail("release date should not be nil")
            }
            
            XCTAssertEqual(album.releaseDatePrecision, "day")

            XCTAssertImagesExist(album.images, assertSizeNotNil: true)
            
        }
        else {
            XCTFail("album should not be nil")
        }
        
        // MARK: Check Artist
        if let artist = track.artists?.first {
            XCTAssertEqual(artist.name, "The Beatles")
            XCTAssertEqual(artist.uri, "spotify:artist:3WrFJ7ztbogyGnTHbHJFl2")
            XCTAssertEqual(artist.id, "3WrFJ7ztbogyGnTHbHJFl2")
            XCTAssertEqual(artist.type, .artist)
            
        }
        else {
            XCTFail("no artists for track")
        }
     
        print("\nend check track\n")
    }
    
    func track() {
        
        let decodeLogLevel = spotifyDecodeLogger.logLevel
        spotifyDecodeLogger.logLevel = .trace
        
        let expectation = XCTestExpectation(description: "testTrack")
        
        Self.spotify.track(URIs.Tracks.because, market: "US")
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: receiveBecause(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        spotifyDecodeLogger.logLevel = decodeLogLevel
    }
    
    func trackLink() {
        
        func receiveTrack(_ track: Track) {
            XCTAssertEqual(track.uri, "spotify:track:6ozxplTAjWO0BlUxN8ia0A")
            XCTAssertEqual(track.name, "Heaven and Hell")
            
            guard let linkedTrack = track.linkedFrom else {
                XCTFail("linkedFrom should not be nil")
                return
            }
            
            XCTAssertEqual(
                linkedTrack.href,
                URL(string: "https://api.spotify.com/v1/tracks/6kLCHFM39wkFjOuyPGLGeQ")!
            )
            XCTAssertEqual(linkedTrack.id, "6kLCHFM39wkFjOuyPGLGeQ")
            XCTAssertEqual(linkedTrack.type, .track)
            XCTAssertEqual(linkedTrack.uri, "spotify:track:6kLCHFM39wkFjOuyPGLGeQ")
            
            if let externalURLs = linkedTrack.externalURLs {
                XCTAssertEqual(
                    externalURLs["spotify"],
                    URL(string: "https://open.spotify.com/track/6kLCHFM39wkFjOuyPGLGeQ")!,
                    "\(externalURLs)"
                )
            }
            else {
                XCTFail("externalURLs should not be nil")
            }
            
        }
        
        // https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
        
        let expectation = XCTestExpectation(description: "testTrackLink")
        
        Self.spotify.track(URIs.Tracks.heavenAndHell, market: "US")
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveTrack(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func tracks() {
        
        func receiveTracks(_ tracks: [Track?]) {
            encodeDecode(tracks)
            if let because = tracks[1] {
                receiveBecause(because)
            }
            else {
                XCTFail("second track should be 'because'")
            }
            
            if let onTheRun = tracks[0] {
                XCTAssertEqual(onTheRun.name, "On the Run")
                XCTAssertEqual(onTheRun.uri, "spotify:track:73OIUNKRi2y24Cu9cOLrzM")
                XCTAssertEqual(onTheRun.id, "73OIUNKRi2y24Cu9cOLrzM")
                XCTAssertEqual(onTheRun.discNumber, 1)
                XCTAssertEqual(onTheRun.durationMS, 225384)
                XCTAssertEqual(onTheRun.type, .track)
                XCTAssertFalse(onTheRun.isLocal)
                XCTAssertEqual(onTheRun.trackNumber, 3)
                XCTAssertEqual(onTheRun.isExplicit, false)
                XCTAssertEqual(onTheRun.artists?.first?.name, "Pink Floyd")
                XCTAssertEqual(
                    onTheRun.artists?.first?.uri,
                    "spotify:artist:0k17h0D3J5VfsdmQ1iZtE9"
                )
                XCTAssertEqual(onTheRun.album?.name, "The Dark Side of the Moon")
                XCTAssertEqual(
                    onTheRun.album?.uri,
                    "spotify:album:4LH4d3cOWNNsVw41Gqt2kv"
                )
                // XCTAssertEqual(
                //     onTheRun.album?.availableMarkets?.contains("US"),
                //     true
                // )
                if let releaseDate = onTheRun.album?.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        99792000,
                        accuracy: 43_200  // 12 hours
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
                XCTAssertEqual(onTheRun.album?.releaseDatePrecision, "day")
                
                XCTAssertEqual(
                    onTheRun.href,
                    URL(string: "https://api.spotify.com/v1/tracks/73OIUNKRi2y24Cu9cOLrzM")!
                )
                
                if let popularity = onTheRun.popularity {
                    XCTAssert((0...100).contains(popularity))
                }
                else {
                    XCTFail("popularity should not be nil")
                }
                
            }
            else {
                XCTFail("first track should not be nil")
            }
            
            if let reckoner = tracks[3] {
                XCTAssertEqual(reckoner.name, "Reckoner")
                XCTAssertEqual(reckoner.uri, "spotify:track:02ppMPbg1OtEdHgoPqoqju")
                XCTAssertEqual(reckoner.id, "02ppMPbg1OtEdHgoPqoqju")
                XCTAssertEqual(reckoner.discNumber, 1)
                XCTAssertEqual(reckoner.durationMS, 290213)
                XCTAssertEqual(reckoner.type, .track)
                XCTAssertFalse(reckoner.isLocal)
                XCTAssertEqual(reckoner.trackNumber, 7)
                XCTAssertEqual(reckoner.isExplicit, false)
                XCTAssertEqual(reckoner.artists?.first?.name, "Radiohead")
                XCTAssertEqual(
                    reckoner.artists?.first?.uri,
                    "spotify:artist:4Z8W4fKeB5YxbusRsdQVPb"
                )
                XCTAssertEqual(reckoner.album?.name, "In Rainbows")
                XCTAssertEqual(
                    reckoner.album?.uri,
                    "spotify:album:5vkqYmiPBYLaalcmjujWxK"
                )
                
                if let releaseDate = reckoner.album?.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        1198800000,
                        accuracy: 43_200  // 12 hours
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
                XCTAssertEqual(reckoner.album?.releaseDatePrecision, "day")
                
                XCTAssertEqual(
                    reckoner.href,
                    URL(string: "https://api.spotify.com/v1/tracks/02ppMPbg1OtEdHgoPqoqju")!
                )
                
                if let popularity = reckoner.popularity {
                    XCTAssert((0...100).contains(popularity))
                }
                else {
                    XCTFail("popularity should not be nil")
                }
                
            }
            else {
                XCTFail("first track should not be nil")
            }
            
        }
        
        let expectation = XCTestExpectation(
            description: "testTracks"
        )
        
        let tracks: [SpotifyURIConvertible] = [
            URIs.Tracks.onTheRun,
            URIs.Tracks.because,
            "spotify:track:invalidURI",
            URIs.Tracks.reckoner
        ]
        
        Self.spotify.tracks(tracks, market: "US")
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveTracks(_:)
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 120)

    }
    
    func invalidIdCategories() {
        
        func validateError(_ error: Error) {
            print("\n\n\(error)\n\n")
            guard let localError = error as? SpotifyGeneralError else {
                XCTFail("should've received SpotifyGeneralError: \(error)")
                return
            }
            
            if case .invalidIdCategory(let expected, let received) = localError {
                XCTAssertEqual(expected, [.track])
                XCTAssertEqual(received, [.album, .artist, .show, .track])
            }
            else {
                XCTFail("should've received invalid id category error: \(localError)")
            }
        }
        
        let expectation = XCTestExpectation(
            description: "testInvalidIdCategories"
        )
        
        let items: [SpotifyURIConvertible] = [
            URIs.Albums.darkSideOfTheMoon,
            URIs.Albums.housesOfTheHoly,
            URIs.Artists.aTribeCalledQuest,
            URIs.Artists.crumb,
            URIs.Shows.samHarris,
            URIs.Tracks.because,
            URIs.Tracks.comeTogether
        ]
        
        Self.spotify.tracks(items)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            XCTFail("publisher should not complete normally")
                        case .failure(let error):
                            validateError(error)
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("should not receive value")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 10)
                  
    }
    
    func trackAudioAnalysis() {
        
        func receiveAudioAnalysis(_ track: AudioAnalysis) {
            
            encodeDecode(track)
            
            // MARK: Bars
            if track.bars.count >= 86 {
                let bar0 = track.bars[0]
                XCTAssertEqual(bar0.start, 2.48709, accuracy: 0.001)
                XCTAssertEqual(bar0.duration, 2.47456, accuracy: 0.001)
                XCTAssertEqual(bar0.confidence, 0.225, accuracy: 0.001)
                
                let bar19 = track.bars[19]
                XCTAssertEqual(bar19.start, 49.49652, accuracy: 0.001)
                XCTAssertEqual(bar19.duration, 2.48147, accuracy: 0.001)
                XCTAssertEqual(bar19.confidence, 0.264, accuracy: 0.001)
                
                let bar53 = track.bars[53]
                XCTAssertEqual(bar53.start, 133.63358, accuracy: 0.001)
                XCTAssertEqual(bar53.duration, 2.4638, accuracy: 0.001)
                XCTAssertEqual(bar53.confidence, 0.695, accuracy: 0.001)
                
                let bar85 = track.bars[85]
                XCTAssertEqual(bar85.start, 212.79747, accuracy: 0.001)
                XCTAssertEqual(bar85.duration, 3.70989, accuracy: 0.001)
                XCTAssertEqual(bar85.confidence, 0.833, accuracy: 0.001)
            }
            else {
                XCTFail("should be at least 86 bars: \(track.bars.count)")
            }
            
            // MARK: Beats
            if track.beats.count >= 351 {
                let beat0 = track.beats[0]
                XCTAssertEqual(beat0.start, 0.63363, accuracy: 0.001)
                XCTAssertEqual(beat0.duration, 0.61385, accuracy: 0.001)
                XCTAssertEqual(beat0.confidence, 0.685, accuracy: 0.001)
                
                let beat29 = track.beats[29]
                XCTAssertEqual(beat29.start, 18.57344, accuracy: 0.001)
                XCTAssertEqual(beat29.duration, 0.61995, accuracy: 0.001)
                XCTAssertEqual(beat29.confidence, 0.743, accuracy: 0.001)
                
                let beat350 = track.beats[350]
                XCTAssertEqual(beat350.start, 217.12808, accuracy: 0.001)
                XCTAssertEqual(beat350.duration, 0.62073, accuracy: 0.001)
                XCTAssertEqual(beat350.confidence, 0.401, accuracy: 0.001)
            }
            else {
                XCTFail("should be at least 351 beats: \(track.beats.count)")
            }
            
            // MARK: Tatums
            if track.tatums.count >= 702 {
                let tatum0 = track.tatums[0]
                XCTAssertEqual(tatum0.start, 0.63363, accuracy: 0.001)
                XCTAssertEqual(tatum0.duration, 0.30692, accuracy: 0.001)
                XCTAssertEqual(tatum0.confidence, 0.685, accuracy: 0.001)
                
                let tatum262 = track.tatums[262]
                XCTAssertEqual(tatum262.start, 81.66474, accuracy: 0.001)
                XCTAssertEqual(tatum262.duration, 0.30914, accuracy: 0.001)
                XCTAssertEqual(tatum262.confidence, 0.398, accuracy: 0.001)
                
                let tatum701 = track.tatums[701]
                XCTAssertEqual(tatum701.start, 217.43845, accuracy: 0.001)
                XCTAssertEqual(tatum701.duration, 0.31036, accuracy: 0.001)
                XCTAssertEqual(tatum701.confidence, 0.401, accuracy: 0.001)
            }
            else {
                XCTFail("should be at least 702 tatums: \(track.tatums.count)")
            }
            
            // MARK: Sections
            if track.sections.count >= 8 {
                let section0 = track.sections[0]
                XCTAssertEqual(section0.start, 0)
                XCTAssertEqual(section0.duration, 18.57344, accuracy: 0.001)
                XCTAssertEqual(section0.confidence, 1)
                XCTAssertEqual(section0.loudness, -11.227, accuracy: 0.001)
                XCTAssertEqual(section0.tempo, 96.952, accuracy: 0.001)
                XCTAssertEqual(section0.tempoConfidence, 0.735, accuracy: 0.001)
                XCTAssertEqual(section0.key, 0)
                XCTAssertEqual(section0.keyConfidence, 0.248, accuracy: 0.001)
                XCTAssertEqual(section0.mode, 1)
                XCTAssertEqual(section0.modeConfidence, 0.376, accuracy: 0.001)
                XCTAssertEqual(section0.timeSignature, 4)
                XCTAssertEqual(section0.timeSignatureConfidence, 1, accuracy: 0.001)
                
                let section5 = track.sections[5]
                XCTAssertEqual(section5.start, 121.88161)
                XCTAssertEqual(section5.duration, 11.75196, accuracy: 0.001)
                XCTAssertEqual(section5.confidence, 0.584)
                XCTAssertEqual(section5.loudness, -7.97, accuracy: 0.001)
                XCTAssertEqual(section5.tempo, 97.146, accuracy: 0.001)
                XCTAssertEqual(section5.tempoConfidence, 0.661, accuracy: 0.001)
                XCTAssertEqual(section5.key, 9)
                XCTAssertEqual(section5.keyConfidence, 0, accuracy: 0.001)
                XCTAssertEqual(section5.mode, 0)
                XCTAssertEqual(section5.modeConfidence, 0, accuracy: 0.001)
                XCTAssertEqual(section5.timeSignature, 4)
                XCTAssertEqual(section5.timeSignatureConfidence, 1, accuracy: 0.001)
                
                let section7 = track.sections[7]
                XCTAssertEqual(section7.start, 194.83823)
                XCTAssertEqual(section7.duration, 23.37249, accuracy: 0.001)
                XCTAssertEqual(section7.confidence, 0.598)
                XCTAssertEqual(section7.loudness, -8.4, accuracy: 0.001)
                XCTAssertEqual(section7.tempo, 97.1, accuracy: 0.001)
                XCTAssertEqual(section7.tempoConfidence, 0.58, accuracy: 0.001)
                XCTAssertEqual(section7.key, 2)
                XCTAssertEqual(section7.keyConfidence, 0.393, accuracy: 0.001)
                XCTAssertEqual(section7.mode, 0)
                XCTAssertEqual(section7.modeConfidence, 0.395, accuracy: 0.001)
                XCTAssertEqual(section7.timeSignature, 4)
                XCTAssertEqual(section7.timeSignatureConfidence, 1, accuracy: 0.001)
            }
            else {
                XCTFail("should be at least 8 sections: \(track.sections.count)")
            }
            
            // MARK: Segments
            if track.segments.count >= 809 {
                
                // MARK: Segment 0
                let segment0 = track.segments[0]
                XCTAssertEqual(segment0.start, 0, accuracy: 0.001)
                XCTAssertEqual(segment0.duration, 0.09764, accuracy: 0.001)
                XCTAssertEqual(segment0.confidence, 0, accuracy: 0.001)
                XCTAssertEqual(segment0.loudnessStart, -17.429, accuracy: 0.001)
                XCTAssertEqual(segment0.loudnessMaxTime, 0.01546, accuracy: 0.001)
                XCTAssertEqual(segment0.loudnessMax, -13.933, accuracy: 0.001)
                XCTAssertEqual(segment0.loudnessEnd, 0, accuracy: 0.001)
                if segment0.pitches.count >= 12 {
                    let pitches = segment0.pitches
                    XCTAssertEqual(pitches[0], 0.639, accuracy: 0.001)
                    XCTAssertEqual(pitches[1], 0.414, accuracy: 0.001)
                    XCTAssertEqual(pitches[2], 0.08, accuracy: 0.001)
                    XCTAssertEqual(pitches[3], 0.201, accuracy: 0.001)
                    XCTAssertEqual(pitches[4], 0.451, accuracy: 0.001)
                    XCTAssertEqual(pitches[5], 0.375, accuracy: 0.001)
                    XCTAssertEqual(pitches[6], 0.596, accuracy: 0.001)
                    XCTAssertEqual(pitches[7], 0.592, accuracy: 0.001)
                    XCTAssertEqual(pitches[8], 0.921, accuracy: 0.001)
                    XCTAssertEqual(pitches[9], 1, accuracy: 0.001)
                    XCTAssertEqual(pitches[10], 0.952, accuracy: 0.001)
                    XCTAssertEqual(pitches[11], 0.032, accuracy: 0.001)
                }
                else {
                    XCTFail(
                        "should be at least 12 pitches: \(segment0.pitches.count)"
                    )
                }
                if segment0.timbre.count >= 12 {
                    let timbre = segment0.timbre
                    XCTAssertEqual(timbre[0], 44.657, accuracy: 0.001)
                    XCTAssertEqual(timbre[1], -71.859, accuracy: 0.001)
                    XCTAssertEqual(timbre[2], -77.829, accuracy: 0.001)
                    XCTAssertEqual(timbre[3], -59.174, accuracy: 0.001)
                    XCTAssertEqual(timbre[4], -14.262, accuracy: 0.001)
                    XCTAssertEqual(timbre[5], -43.922, accuracy: 0.001)
                    XCTAssertEqual(timbre[6], -12.169, accuracy: 0.001)
                    XCTAssertEqual(timbre[7], 1.677, accuracy: 0.001)
                    XCTAssertEqual(timbre[8], -24.255, accuracy: 0.001)
                    XCTAssertEqual(timbre[9], 6.786, accuracy: 0.001)
                    XCTAssertEqual(timbre[10], 7.32, accuracy: 0.001)
                    XCTAssertEqual(timbre[11], -11.612, accuracy: 0.001)
                }
                else {
                    XCTFail(
                        "should be at least 12 timbers: \(segment0.timbre.count)"
                    )
                }
                
                // MARK: Segment 96
                let segment96 = track.segments[96]
                XCTAssertEqual(segment96.start, 24.29465, accuracy: 0.001)
                XCTAssertEqual(segment96.duration, 0.10934, accuracy: 0.001)
                XCTAssertEqual(segment96.confidence, 0.033, accuracy: 0.001)
                XCTAssertEqual(segment96.loudnessStart, -23.076, accuracy: 0.001)
                XCTAssertEqual(segment96.loudnessMaxTime, 0.05434, accuracy: 0.001)
                XCTAssertEqual(segment96.loudnessMax, -19.555, accuracy: 0.001)
                XCTAssertEqual(segment96.loudnessEnd, 0, accuracy: 0.001)
                if segment96.pitches.count >= 12 {
                    let pitches = segment96.pitches
                    XCTAssertEqual(pitches[0], 1, accuracy: 0.001)
                    XCTAssertEqual(pitches[1], 0.802, accuracy: 0.001)
                    XCTAssertEqual(pitches[2], 0.017, accuracy: 0.001)
                    XCTAssertEqual(pitches[3], 0.025, accuracy: 0.001)
                    XCTAssertEqual(pitches[4], 0.067, accuracy: 0.001)
                    XCTAssertEqual(pitches[5], 0.028, accuracy: 0.001)
                    XCTAssertEqual(pitches[6], 0.026, accuracy: 0.001)
                    XCTAssertEqual(pitches[7], 0.074, accuracy: 0.001)
                    XCTAssertEqual(pitches[8], 0.646, accuracy: 0.001)
                    XCTAssertEqual(pitches[9], 0.981, accuracy: 0.001)
                    XCTAssertEqual(pitches[10], 0.934, accuracy: 0.001)
                    XCTAssertEqual(pitches[11], 0.029, accuracy: 0.001)
                }
                else {
                    XCTFail(
                        "should be at least 12 pitches: \(segment96.pitches.count)"
                    )
                }
                if segment96.timbre.count >= 12 {
                    let timbre = segment96.timbre
                    XCTAssertEqual(timbre[0], 38.669, accuracy: 0.001)
                    XCTAssertEqual(timbre[1], -32.641, accuracy: 0.001)
                    XCTAssertEqual(timbre[2], -47.326, accuracy: 0.001)
                    XCTAssertEqual(timbre[3], -33.544, accuracy: 0.001)
                    XCTAssertEqual(timbre[4], 14.173, accuracy: 0.001)
                    XCTAssertEqual(timbre[5], -38.575, accuracy: 0.001)
                    XCTAssertEqual(timbre[6], -13.833, accuracy: 0.001)
                    XCTAssertEqual(timbre[7], 6.241, accuracy: 0.001)
                    XCTAssertEqual(timbre[8], -26.976, accuracy: 0.001)
                    XCTAssertEqual(timbre[9], -2.145, accuracy: 0.001)
                    XCTAssertEqual(timbre[10], -15.028, accuracy: 0.001)
                    XCTAssertEqual(timbre[11], 13.425, accuracy: 0.001)
                }
                else {
                    XCTFail(
                        "should be at least 12 timbers: \(segment96.timbre.count)"
                    )
                }
                
                // MARK: Segment 808
                let segment808 = track.segments[808]
                XCTAssertEqual(segment808.start, 217.41864, accuracy: 0.001)
                XCTAssertEqual(segment808.duration, 0.79206, accuracy: 0.001)
                XCTAssertEqual(segment808.confidence, 0.695, accuracy: 0.001)
                XCTAssertEqual(segment808.loudnessStart, -17.715, accuracy: 0.001)
                XCTAssertEqual(segment808.loudnessMaxTime, 0.0154, accuracy: 0.001)
                XCTAssertEqual(segment808.loudnessMax, -7.635, accuracy: 0.001)
                XCTAssertEqual(segment808.loudnessEnd, -34.869, accuracy: 0.001)
                if segment808.pitches.count >= 12 {
                    let pitches = segment808.pitches
                    XCTAssertEqual(pitches[0], 0.294, accuracy: 0.001)
                    XCTAssertEqual(pitches[1], 0.193, accuracy: 0.001)
                    XCTAssertEqual(pitches[2], 1, accuracy: 0.001)
                    XCTAssertEqual(pitches[3], 0.186, accuracy: 0.001)
                    XCTAssertEqual(pitches[4], 0.061, accuracy: 0.001)
                    XCTAssertEqual(pitches[5], 0.16, accuracy: 0.001)
                    XCTAssertEqual(pitches[6], 0.051, accuracy: 0.001)
                    XCTAssertEqual(pitches[7], 0.052, accuracy: 0.001)
                    XCTAssertEqual(pitches[8], 0.084, accuracy: 0.001)
                    XCTAssertEqual(pitches[9], 0.617, accuracy: 0.001)
                    XCTAssertEqual(pitches[10], 0.085, accuracy: 0.001)
                    XCTAssertEqual(pitches[11], 0.061, accuracy: 0.001)
                }
                else {
                    XCTFail(
                        "should be at least 12 pitches: \(segment808.pitches.count)"
                    )
                }
                if segment808.timbre.count >= 12 {
                    let timbre = segment808.timbre
                    XCTAssertEqual(timbre[0], 43.69, accuracy: 0.001)
                    XCTAssertEqual(timbre[1], -56.717, accuracy: 0.001)
                    XCTAssertEqual(timbre[2], -136.045, accuracy: 0.001)
                    XCTAssertEqual(timbre[3], 109.34, accuracy: 0.001)
                    XCTAssertEqual(timbre[4], 45.092, accuracy: 0.001)
                    XCTAssertEqual(timbre[5], -50.271, accuracy: 0.001)
                    XCTAssertEqual(timbre[6], -33.248, accuracy: 0.001)
                    XCTAssertEqual(timbre[7], -13.619, accuracy: 0.001)
                    XCTAssertEqual(timbre[8], 2.161, accuracy: 0.001)
                    XCTAssertEqual(timbre[9], -24.457, accuracy: 0.001)
                    XCTAssertEqual(timbre[10], -47.499, accuracy: 0.001)
                    XCTAssertEqual(timbre[11], 19.684, accuracy: 0.001)
                }
                else {
                    XCTFail(
                        "should be at least 12 timbers: \(segment808.timbre.count)"
                    )
                }
                
            }
            else {
                XCTFail(
                    "should be at least 809 segments: \(track.segments.count)"
                )
            }
            
        }
        
        let expectation = XCTestExpectation(
            description: "testTrackAudioAnalysis"
        )
        
        Self.spotify.trackAudioAnalysis(URIs.Tracks.lauren)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveAudioAnalysis(_:)
            )
            .store(in: &Self.cancellables)
            
        self.wait(for: [expectation], timeout: 120)
        
        
    }
    
    func trackAudioFeatures() {
     
        func receiveTrack(_ track: AudioFeatures) {
            
            encodeDecode(track)
            
            XCTAssertEqual(track.danceability, 0.274, accuracy: 0.001)
            XCTAssertEqual(track.energy, 0.217, accuracy: 0.001)
            XCTAssertEqual(track.key, 5)
            XCTAssertEqual(track.loudness, -13.814, accuracy: 0.001)
            XCTAssertEqual(track.mode, 1)
            XCTAssertEqual(track.speechiness, 0.0345, accuracy: 0.001)
            XCTAssertEqual(track.acousticness, 0.767, accuracy: 0.001)
            XCTAssertEqual(track.instrumentalness, 0.896, accuracy: 0.001)
            XCTAssertEqual(track.liveness, 0.0832, accuracy: 0.001)
            XCTAssertEqual(track.valence, 0.181, accuracy: 0.001)
            XCTAssertEqual(track.tempo, 116.334, accuracy: 0.001)
            XCTAssertEqual(track.type, "audio_features")
            XCTAssertEqual(track.id, "2TjdnqlpwOjhijHCwHCP2d")
            XCTAssertEqual(track.uri, "spotify:track:2TjdnqlpwOjhijHCwHCP2d")
            XCTAssertEqual(
                track.trackHref,
                "https://api.spotify.com/v1/tracks/2TjdnqlpwOjhijHCwHCP2d"
            )
            XCTAssertEqual(
                track.analysisURL,
                URL(string: "https://api.spotify.com/v1/audio-analysis/2TjdnqlpwOjhijHCwHCP2d")!
            )
            XCTAssertEqual(track.durationMS, 283872)
            XCTAssertEqual(track.timeSignature, 4)
        }
        
        let expectation = XCTestExpectation(
            description: "testTrackAudioFeatures"
        )

        let failureExpectation = XCTestExpectation(
            description: "testTrackAudioFeatures invalid URI"
        )
        
        Self.spotify.trackAudioFeatures("spotify:track:invaliduri")
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            XCTFail(
                                "publisher should not finish normally " +
                                "for invalid uri"
                            )
                        case .failure(let error):
                            XCTAssert(error is SpotifyError, "\(error)")
                    }
                    failureExpectation.fulfill()
                },
                receiveValue: { track in
                    XCTFail(
                        "should not receive value for invalid URI: \(track)"
                    )
                }
            )
            .store(in: &Self.cancellables)
        
        Self.spotify.trackAudioFeatures(URIs.Tracks.theGreatGigInTheSky)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveTrack(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation, failureExpectation], timeout: 120)

    }
    
    func tracksAudioFeatures() {
        
        func receiveTracks(_ tracks: [AudioFeatures?]) {
            
            encodeDecode(tracks)

            guard tracks.count == 4 else {
                XCTFail("should've received 4 tracks: \(tracks.count)")
                return
            }

            XCTAssertNil(tracks[2], "third URI is invalid")
            
            if let track = tracks[0] {
                XCTAssertEqual(track.danceability, 0.359, accuracy: 0.001)
                XCTAssertEqual(track.energy, 0.577, accuracy: 0.001)
                XCTAssertEqual(track.key, 10)
                XCTAssertEqual(track.loudness, -10.804, accuracy: 0.001)
                XCTAssertEqual(track.mode, 1)
                XCTAssertEqual(track.speechiness, 0.0406, accuracy: 0.001)
                XCTAssertEqual(track.acousticness, 0.0591, accuracy: 0.001)
                XCTAssertEqual(track.instrumentalness, 0.751, accuracy: 0.001)
                XCTAssertEqual(track.liveness, 0.0686, accuracy: 0.001)
                XCTAssertEqual(track.valence, 0.141, accuracy: 0.001)
                XCTAssertEqual(track.tempo, 68.064, accuracy: 0.001)
                XCTAssertEqual(track.type, "audio_features")
                XCTAssertEqual(track.id, "1tDWVeCR9oWGX8d5J9rswk")
                XCTAssertEqual(track.uri, "spotify:track:1tDWVeCR9oWGX8d5J9rswk")
                XCTAssertEqual(
                    track.trackHref,
                    "https://api.spotify.com/v1/tracks/1tDWVeCR9oWGX8d5J9rswk"
                )
                XCTAssertEqual(
                    track.analysisURL,
                    URL(string: "https://api.spotify.com/v1/audio-analysis/1tDWVeCR9oWGX8d5J9rswk")!
                )
                XCTAssertEqual(track.durationMS, 130429)
                XCTAssertEqual(track.timeSignature, 4)
            }
            else {
                XCTFail("first track should not be nil")
            }
            
            if let track = tracks[1] {
                XCTAssertEqual(track.danceability, 0.324, accuracy: 0.001)
                XCTAssertEqual(track.energy, 0.265, accuracy: 0.001)
                XCTAssertEqual(track.key, 2)
                XCTAssertEqual(track.loudness, -13.398, accuracy: 0.001)
                XCTAssertEqual(track.mode, 1)
                XCTAssertEqual(track.speechiness, 0.0302, accuracy: 0.001)
                XCTAssertEqual(track.acousticness, 0.0726, accuracy: 0.001)
                XCTAssertEqual(track.instrumentalness, 0.341, accuracy: 0.001)
                XCTAssertEqual(track.liveness, 0.366, accuracy: 0.001)
                XCTAssertEqual(track.valence, 0.208, accuracy: 0.001)
                XCTAssertEqual(track.tempo, 133.568, accuracy: 0.001)
                XCTAssertEqual(track.type, "audio_features")
                XCTAssertEqual(track.id, "05uGBKRCuePsf43Hfm0JwX")
                XCTAssertEqual(track.uri, "spotify:track:05uGBKRCuePsf43Hfm0JwX")
                XCTAssertEqual(
                    track.trackHref,
                    "https://api.spotify.com/v1/tracks/05uGBKRCuePsf43Hfm0JwX"
                )
                XCTAssertEqual(
                    track.analysisURL,
                    URL(string: "https://api.spotify.com/v1/audio-analysis/05uGBKRCuePsf43Hfm0JwX")!
                )
                XCTAssertEqual(track.durationMS, 226667)
                XCTAssertEqual(track.timeSignature, 4)
            }
            else {
                XCTFail("second track should not be nil")
            }
            
            if let track = tracks[3] {
                XCTAssertEqual(track.danceability, 0.533, accuracy: 0.001)
                XCTAssertEqual(track.energy, 0.376, accuracy: 0.001)
                XCTAssertEqual(track.key, 9)
                XCTAssertEqual(track.loudness, -11.913, accuracy: 0.001)
                XCTAssertEqual(track.mode, 0)
                XCTAssertEqual(track.speechiness, 0.0393, accuracy: 0.001)
                XCTAssertEqual(track.acousticness, 0.0302, accuracy: 0.001)
                XCTAssertEqual(track.instrumentalness, 0.248, accuracy: 0.001)
                XCTAssertEqual(track.liveness, 0.0926, accuracy: 0.001)
                XCTAssertEqual(track.valence, 0.187, accuracy: 0.001)
                XCTAssertEqual(track.tempo, 165.007, accuracy: 0.001)
                XCTAssertEqual(track.type, "audio_features")
                XCTAssertEqual(track.id, "2EqlS6tkEnglzr7tkKAAYD")
                XCTAssertEqual(track.uri, "spotify:track:2EqlS6tkEnglzr7tkKAAYD")
                XCTAssertEqual(
                    track.trackHref,
                    "https://api.spotify.com/v1/tracks/2EqlS6tkEnglzr7tkKAAYD"
                )
                XCTAssertEqual(
                    track.analysisURL,
                    URL(string: "https://api.spotify.com/v1/audio-analysis/2EqlS6tkEnglzr7tkKAAYD")!
                )
                XCTAssertEqual(track.durationMS, 259947)
                XCTAssertEqual(track.timeSignature, 4)
            }
            else {
                XCTFail("fourth track should not be nil")
            }

        }
        
        let expectation = XCTestExpectation(
            description: "testTrackAudioFeatures"
        )
        
        let tracks: [SpotifyURIConvertible] = [
            URIs.Tracks.eclipse,
            URIs.Tracks.brainDamage,
            "spotify:track:invaliduri",
            URIs.Tracks.comeTogether
        ]
        
        Self.spotify.tracksAudioFeatures(tracks)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveTracks(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

}

final class SpotifyAPIClientCredentialsFlowTrackTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPITrackTests
{
 
    static let allTests = [
        ("testTrack", testTrack),
        ("testTrackLink", testTrackLink),
        ("testTracks", testTracks),
        ("testTrackAudioAnalysis", testTrackAudioAnalysis),
        ("testTrackAudioFeatures", testTrackAudioFeatures),
        ("testTracksAudioFeatures", testTracksAudioFeatures),
        ("testInvalidIdCategories", testInvalidIdCategories)
    ]
    
    func testTrack() { track() }
    func testTrackLink() { trackLink() }
    func testTracks() { tracks() }
    func testInvalidIdCategories() { invalidIdCategories() }
    func testTrackAudioAnalysis() { trackAudioAnalysis() }
    func testTrackAudioFeatures() { trackAudioFeatures() }
    func testTracksAudioFeatures() { tracksAudioFeatures() }
    
}

final class SpotifyAPIAuthorizationCodeFlowTrackTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPITrackTests
{
 
    static let allTests = [
        ("testTrack", testTrack),
        ("testTrackLink", testTrackLink),
        ("testTracks", testTracks),
        ("testTrackAudioAnalysis", testTrackAudioAnalysis),
        ("testTrackAudioFeatures", testTrackAudioFeatures),
        ("testTracksAudioFeatures", testTracksAudioFeatures),
        ("testInvalidIdCategories", testInvalidIdCategories)
    ]
    
    func testTrack() { track() }
    func testTrackLink() { trackLink() }
    func testTracks() { tracks() }
    func testInvalidIdCategories() { invalidIdCategories() }
    func testTrackAudioAnalysis() { trackAudioAnalysis() }
    func testTrackAudioFeatures() { trackAudioFeatures() }
    func testTracksAudioFeatures() { tracksAudioFeatures() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCETrackTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPITrackTests
{
 
    static let allTests = [
        ("testTrack", testTrack),
        ("testTrackLink", testTrackLink),
        ("testTracks", testTracks),
        ("testTrackAudioAnalysis", testTrackAudioAnalysis),
        ("testTrackAudioFeatures", testTrackAudioFeatures),
        ("testTracksAudioFeatures", testTracksAudioFeatures),
        ("testInvalidIdCategories", testInvalidIdCategories)
    ]
    
    func testTrack() { track() }
    func testTrackLink() { trackLink() }
    func testTracks() { tracks() }
    func testInvalidIdCategories() { invalidIdCategories() }
    func testTrackAudioAnalysis() { trackAudioAnalysis() }
    func testTrackAudioFeatures() { trackAudioFeatures() }
    func testTracksAudioFeatures() { tracksAudioFeatures() }
    
}

