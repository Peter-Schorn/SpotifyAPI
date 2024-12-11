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
            XCTAssertEqual(album.releaseDate, "1969-09-26")
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
                XCTAssertEqual(onTheRun.album?.releaseDate, "1973-03-01")
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
            
            if let reckoner = tracks[2] {
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
                XCTAssertEqual(reckoner.album?.releaseDate, "2007-12-28")
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
    
}

final class SpotifyAPIClientCredentialsFlowTrackTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPITrackTests
{
 
    static let allTests = [
        ("testTrack", testTrack),
        ("testTrackLink", testTrackLink),
        ("testTracks", testTracks),
        ("testInvalidIdCategories", testInvalidIdCategories)
    ]
    
    func testTrack() { track() }
    func testTrackLink() { trackLink() }
    func testTracks() { tracks() }
    func testInvalidIdCategories() { invalidIdCategories() }

}

final class SpotifyAPIAuthorizationCodeFlowTrackTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPITrackTests
{
 
    static let allTests = [
        ("testTrack", testTrack),
        ("testTrackLink", testTrackLink),
        ("testTracks", testTracks),
        ("testInvalidIdCategories", testInvalidIdCategories)
    ]

    func testTrack() { track() }
    func testTrackLink() { trackLink() }
    func testTracks() { tracks() }
    func testInvalidIdCategories() { invalidIdCategories() }

}

final class SpotifyAPIAuthorizationCodeFlowPKCETrackTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPITrackTests
{
 
    static let allTests = [
        ("testTrack", testTrack),
        ("testTrackLink", testTrackLink),
        ("testTracks", testTracks),
        ("testInvalidIdCategories", testInvalidIdCategories)
    ]

    func testTrack() { track() }
    func testTrackLink() { trackLink() }
    func testTracks() { tracks() }
    func testInvalidIdCategories() { invalidIdCategories() }

}

