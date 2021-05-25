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

protocol SpotifyAPIPersonalizationTests: SpotifyAPITests { }

extension SpotifyAPIPersonalizationTests where
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager
{
    
    // MARK: Artists
    
    func currentUserTopArtistsShortTerm() {
        
        let decodeLogLevel = spotifyDecodeLogger.logLevel
        spotifyDecodeLogger.logLevel = .trace
        
        func receiveArtists(_ topArtists: PagingObject<Artist>) {
            encodeDecode(topArtists, areEqual: ==)
            XCTAssertEqual(topArtists.limit, 10)
            XCTAssertEqual(topArtists.offset, 3)
            XCTAssertLessThanOrEqual(topArtists.items.count, 10)
            if topArtists.total > topArtists.items.count + topArtists.offset {
                XCTAssertNotNil(topArtists.next)
            }
        }
        
        let expectation = XCTestExpectation(
            description: "testCurrentUserTopArtistsShortTerm"
        )
        
        Self.spotify.currentUserTopArtists(
            .shortTerm,
            offset: 3,
            limit: 10
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveArtists(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

        spotifyDecodeLogger.logLevel = decodeLogLevel
        
    }
    
    func currentUserTopArtistsMediumTerm() {
        
        func receiveArtists(_ topArtists: PagingObject<Artist>) {
            encodeDecode(topArtists, areEqual: ==)
            XCTAssertEqual(topArtists.offset, 0)
        }
        
        let expectation = XCTestExpectation(
            description: "testCurrentUserTopArtistsMediumTerm"
        )
        
        Self.spotify.currentUserTopArtists(
            .mediumTerm
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveArtists(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func currentUserTopArtistsLongTerm() {
        
        func receiveArtists(_ topArtists: PagingObject<Artist>) {
            encodeDecode(topArtists, areEqual: ==)
            XCTAssertEqual(topArtists.offset, 0)
        }
        
        let expectation = XCTestExpectation(
            description: "testCurrentUserTopArtistsLongTerm"
        )
        
        Self.spotify.currentUserTopArtists(
            .longTerm
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveArtists(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

    func currentUserTopArtists() {
        
        func receiveArtists(_ topArtists: PagingObject<Artist>) {
            encodeDecode(topArtists, areEqual: ==)
            XCTAssertEqual(topArtists.offset, 0)
        }
        
        let expectation = XCTestExpectation(
            description: "testCurrentUserTopArtists"
        )
        
        Self.spotify.currentUserTopArtists()
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveArtists(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

    // MARK: Tracks
    
    func currentUserTopTracksShortTerm() {
        
        func receiveTracks(_ topTracks: PagingObject<Track>) {
            encodeDecode(topTracks)
            XCTAssertEqual(topTracks.offset, 0)
        }
        
        let expectation = XCTestExpectation(
            description: "testCurrentUserTopTracksShortTerm"
        )
        
        Self.spotify.currentUserTopTracks(.shortTerm)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveTracks(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func currentUserTopTracksMediumTerm() {
        
        func receiveTracks(_ topTracks: PagingObject<Track>) {
            encodeDecode(topTracks)
            XCTAssertEqual(topTracks.offset, 5)
        }
        
        let expectation = XCTestExpectation(
            description: "testCurrentUserTopTracksMediumTerm"
        )
        
        Self.spotify.currentUserTopTracks(
            .mediumTerm,
            offset: 5
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveTracks(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func currentUserTopTracksLongTerm() {
        
        func receiveTracks(_ topTracks: PagingObject<Track>) {
            encodeDecode(topTracks)
            XCTAssertEqual(topTracks.offset, 2)
            XCTAssertEqual(topTracks.limit, 1)
        }
        
        let expectation = XCTestExpectation(
            description: "testCurrentUserTopTracksLongTerm"
        )
        
        Self.spotify.currentUserTopTracks(
            .longTerm,
            offset: 2,
            limit: 1
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveTracks(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func currentUserTopTracks() {
        
        func receiveTracks(_ topTracks: PagingObject<Track>) {
            encodeDecode(topTracks)
            XCTAssertEqual(topTracks.offset, 0)
        }
        
        let expectation = XCTestExpectation(
            description: "testCurrentUserTopTracks"
        )
        
        Self.spotify.currentUserTopTracks()
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveTracks(_:)
            )
            .store(in: &Self.cancellables)
            
        self.wait(for: [expectation], timeout: 120)

    }
    
}

final class SpotifyAPIAuthorizationCodeFlowPersonalizationTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIPersonalizationTests
{

    static let allTests = [
        ("testCurrentUserTopArtistsShortTerm", testCurrentUserTopArtistsShortTerm),
        ("testCurrentUserTopArtistsMediumTerm", testCurrentUserTopArtistsMediumTerm),
        ("testCurrentUserTopArtistsLongTerm", testCurrentUserTopArtistsLongTerm),
        ("testCurrentUserTopArtists", testCurrentUserTopArtists),
        ("testCurrentUserTopTracksShortTerm", testCurrentUserTopTracksShortTerm),
        ("testCurrentUserTopTracksMediumTerm", testCurrentUserTopTracksMediumTerm),
        ("testCurrentUserTopTracksLongTerm", testCurrentUserTopTracksLongTerm),
        ("testCurrentUserTopTracks", testCurrentUserTopTracks)
    ]
    
    func testCurrentUserTopArtistsShortTerm() {
        currentUserTopArtistsShortTerm()
    }
    func testCurrentUserTopArtistsMediumTerm() {
        currentUserTopArtistsMediumTerm()
    }
    func testCurrentUserTopArtistsLongTerm() {
        currentUserTopArtistsLongTerm()
    }
    func testCurrentUserTopArtists() {
        currentUserTopArtists()
    }
    func testCurrentUserTopTracksShortTerm() {
        currentUserTopTracksShortTerm()
    }
    func testCurrentUserTopTracksMediumTerm() {
        currentUserTopTracksMediumTerm()
    }
    func testCurrentUserTopTracksLongTerm() {
        currentUserTopTracksLongTerm()
    }
    func testCurrentUserTopTracks() {
        currentUserTopTracks()
    }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEPersonalizationTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIPersonalizationTests
{

    static let allTests = [
        ("testCurrentUserTopArtistsShortTerm", testCurrentUserTopArtistsShortTerm),
        ("testCurrentUserTopArtistsMediumTerm", testCurrentUserTopArtistsMediumTerm),
        ("testCurrentUserTopArtistsLongTerm", testCurrentUserTopArtistsLongTerm),
        ("testCurrentUserTopArtists", testCurrentUserTopArtists),
        ("testCurrentUserTopTracksShortTerm", testCurrentUserTopTracksShortTerm),
        ("testCurrentUserTopTracksMediumTerm", testCurrentUserTopTracksMediumTerm),
        ("testCurrentUserTopTracksLongTerm", testCurrentUserTopTracksLongTerm),
        ("testCurrentUserTopTracks", testCurrentUserTopTracks)
    ]
    
    func testCurrentUserTopArtistsShortTerm() {
        currentUserTopArtistsShortTerm()
    }
    func testCurrentUserTopArtistsMediumTerm() {
        currentUserTopArtistsMediumTerm()
    }
    func testCurrentUserTopArtistsLongTerm() {
        currentUserTopArtistsLongTerm()
    }
    func testCurrentUserTopArtists() {
        currentUserTopArtists()
    }
    func testCurrentUserTopTracksShortTerm() {
        currentUserTopTracksShortTerm()
    }
    func testCurrentUserTopTracksMediumTerm() {
        currentUserTopTracksMediumTerm()
    }
    func testCurrentUserTopTracksLongTerm() {
        currentUserTopTracksLongTerm()
    }
    func testCurrentUserTopTracks() {
        currentUserTopTracks()
    }
    
}
