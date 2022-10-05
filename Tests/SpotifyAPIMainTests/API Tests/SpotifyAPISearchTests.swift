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

protocol SpotifyAPISearchTests: SpotifyAPITests { }

extension SpotifyAPISearchTests {
    
    func invalidCategories() {
        
        func validateError(_ error: Error) {
            print("\n\n\(error)\n\n")
            guard let localError = error as? SpotifyGeneralError else {
                XCTFail("should've received SpotifyGeneralError: \(error)")
                return
            }
            
            if case .invalidIdCategory(let expected, let received) = localError {
                XCTAssertEqual(
                    expected,
                    [
                        .album, .artist, .playlist,
                        .track, .show, .episode, .audiobook
                    ]
                )
                XCTAssertEqual(received, [.user, .genre])
            }
            else {
                XCTFail(
                    "should've received invalid id category error: \(localError)"
                )
            }
            
        }
        
        let expectation = XCTestExpectation(
            description: "testInvalidCategories"
        )

        Self.spotify.search(
            query: "Jimi Hendrix",
            categories: [.user, .genre]
        )
        .sink(
            receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        XCTFail("publisher should not finish normally")
                    case .failure(let error):
                        validateError(error)
                }
                expectation.fulfill()
            },
            receiveValue: { results in
                XCTFail("should not receive results for invalid categories")
            }
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
        
    }

    func searchEpisodesShowsNoMarket() {
        
        func receiveResults(_ results: SearchResult) {
            
            encodeDecode(results)
            
            XCTAssertNil(results.artists)
            XCTAssertNil(results.albums)
            XCTAssertNil(results.tracks)
            XCTAssertNil(results.playlists)

            let scopes = Self.spotify.authorizationManager.scopes.map(\.rawValue)
            print("authorized scopes: \(scopes)")
            
            // MARK: Shows
            
            guard let shows = results.shows else {
                XCTFail("shows paging object should not be nil")
                return
            }

            XCTAssertEqual(shows.offset, 5)
            XCTAssertEqual(shows.limit, 2)
            XCTAssertNotNil(shows.previous)
            
            // MARK: Episodes
            
            guard let episodes = results.episodes else {
                XCTFail("episodes paging object should not be nil")
                return
            }
            
            XCTAssertEqual(episodes.offset, 5)
            XCTAssertEqual(episodes.limit, 2)
            XCTAssertNotNil(episodes.previous)
            
        }
        
        let expectation = XCTestExpectation(
            description: "testSearchEpisodesShowsNoMarket"
        )
        
        Self.spotify.search(
            query: "Sam Harris",
            categories: [.episode, .show],
            limit: 2,
            offset: 5
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveResults(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    func searchAllCategories() {
        
        let expectation = XCTestExpectation(
            description: "testSearchAllCategories"
        )
        
        Self.spotify.search(
            query: "Hello",
            categories: [
                .artist, .album, .track,
                .playlist, .episode, .audiobook
            ],
            market: "US",
            limit: 5,
            includeExternal: "audio"
        )
        .XCTAssertNoFailure()
        .flatMap { results -> AnyPublisher<PagingObject<Track>, Error> in
            
            encodeDecode(results)
            
            XCTAssertNotNil(results.artists)
            XCTAssertNotNil(results.albums)
            XCTAssertNotNil(results.playlists)
            XCTAssertNotNil(results.episodes)
            XCTAssertNil(results.shows)
            XCTAssertNotNil(results.audiobooks)
            
            guard let tracks = results.tracks else {
                return SpotifyGeneralError.other("SearchResult.tracks was nil")
                    .anyFailingPublisher()
            }
            
            return Self.spotify.extendPages(tracks, maxExtraPages: 2)
            
        }
        .XCTAssertNoFailure()
        .collect()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { tracksPages in
                
                for (i, tracksPage) in tracksPages.enumerated() {
                    XCTAssertEqual(tracksPage.limit, 5, "\(i)")
                    XCTAssertEqual(tracksPage.items.count, 5)
                    XCTAssertEqual(tracksPage.offset, i * 5)
                }

                XCTAssertEqual(tracksPages.count, 3)
                guard tracksPages.count >= 3 else {
                    return
                }
                XCTAssertNotNil(tracksPages[0].next)
                XCTAssertNotNil(tracksPages[1].next)
                
                XCTAssertNotNil(tracksPages[1].previous)
                XCTAssertNotNil(tracksPages[2].previous)
                
                
            }
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
        
    }
    
    func specificTrackSearch() {

        func receiveResults(_ results: SearchResult) {
            
            encodeDecode(results)
            
            XCTAssertNil(results.artists)
            XCTAssertNil(results.albums)
            XCTAssertNil(results.playlists)
            XCTAssertNil(results.episodes)
            XCTAssertNil(results.shows)
            
            guard let tracks = results.tracks?.items else {
                XCTFail("should've received tracks")
                return
            }
            
            guard let track = tracks.first(where: { $0.name == trackName }) else {
                XCTFail("should've found specific track")
                return
            }
            
            XCTAssertEqual(track.artists?.first?.name, "The Beatles")
            let albumName = "Sgt. Pepper's Lonely Hearts Club Band"
            XCTAssertEqual(
                track.album?.name.hasPrefix(albumName), true,
                "\(track.album?.name ?? "nil")"
            )
            XCTAssertEqual(track.type, .track)
            
        }
        
        let expectation = XCTestExpectation(
            description: "testSpecificTrackSearch"
        )
        
        let trackName =
            "Sgt. Pepper's Lonely Hearts Club Band - Reprise / Remastered 2009"

        Self.spotify.search(
            query: trackName,
            categories: [.track],
            market: "US"
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveResults(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
    }
    
    func filteredSearchForAbbeyRoad() {
        
        func receiveResults(_ results: SearchResult) {
            
            encodeDecode(results)
            
            XCTAssertNil(results.artists)
            XCTAssertNil(results.tracks)
            XCTAssertNil(results.playlists)
            XCTAssertNil(results.episodes)
            XCTAssertNil(results.shows)
            
            guard let albums = results.albums?.items else {
                XCTFail("should've received albums")
                return
            }
            
            guard let abbeyRoad = albums.first(where: {
                $0.id == "0ETFjACtuP2ADo6LFhL6HN"
            }) else {
                XCTFail("should've found abbey road album")
                return
            }
            
            XCTAssertEqual(abbeyRoad.name, "Abbey Road (Remastered)")
            XCTAssertEqual(abbeyRoad.uri, "spotify:album:0ETFjACtuP2ADo6LFhL6HN")
            XCTAssertEqual(abbeyRoad.type, .album)
            XCTAssertEqual(abbeyRoad.albumType, .album)

            guard let artist = abbeyRoad.artists?.first else {
                XCTFail("should've received artist")
                return
            }
            
            XCTAssertEqual(artist.name, "The Beatles")
            XCTAssertEqual(artist.uri, "spotify:artist:3WrFJ7ztbogyGnTHbHJFl2")

        }
        
        let expectation = XCTestExpectation(
            description: "testFilteredSearchForAbbeyRoad"
        )

        let query = """
            album: abbey road artist: the beatles year:1969
            """
        
        Self.spotify.search(
            query: query,
            categories: [.album],
            market: "US",
            limit: 50
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveResults(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
    }

    func filteredSearchForAudiobook() {
        
        func receiveSearchResults(_ results: SearchResult) {
            
            encodeDecode(results)
            
            XCTAssertNil(results.artists)
            XCTAssertNil(results.albums)
            XCTAssertNil(results.tracks)
            XCTAssertNil(results.playlists)
            XCTAssertNil(results.episodes)
            XCTAssertNil(results.shows)

            guard let audiobooks = results.audiobooks else {
                XCTFail("audiobooks was nil for search result")
                return
            }
            
            XCTAssertEqual(audiobooks.limit, 1)
            XCTAssertEqual(audiobooks.offset, 0)
            XCTAssertNil(audiobooks.previous)
            
            guard let audiobook = audiobooks.items.first as? Audiobook else {
                XCTFail("audiobook was missing or nil: \(audiobooks)")
                return
            }
            
            
            XCTAssertEqual(
                audiobook.name,
                "Harry Potter and the Chamber of Secrets"
            )
            XCTAssertEqual(audiobook.authors.count, 1)
            XCTAssertEqual(audiobook.authors.first?.name, "J.K. Rowling")

        }
        
        let expectation = XCTestExpectation(
            description: "testFilteredSearchForAudiobook"
        )
        
        
        Self.spotify.search(
            query: "Harry Potter and the Chamber",
            categories: [.audiobook],
            market: "US",
            limit: 1
        )
        .XCTAssertNoFailure()
        .receiveOnMain()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveSearchResults(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

    func filteredSearchNoMatches() {
        
        func receiveResults(_ results: SearchResult) {
            
            encodeDecode(results)
            
            XCTAssertNil(results.artists)
            XCTAssertNil(results.tracks)
            XCTAssertNil(results.playlists)
            XCTAssertNil(results.episodes)
            XCTAssertNil(results.shows)
                
            guard let albums = results.albums else {
                XCTFail("albums paging object should not be nil")
                return
            }
            
            XCTAssertEqual(albums.items.count, 0)

        }
        
        let expectation = XCTestExpectation(
            description: "testFilteredSearchNoMatches"
        )

        let query = """
            album: abbey road artist: the beatles year:1932
            """
        
        Self.spotify.search(
            query: query,
            categories: [.album],
            market: "US",
            limit: 11
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveResults(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
}

final class SpotifyAPIClientCredentialsFlowSearchTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPISearchTests
{
    
    static let allTests = [
        ("testInvalidCategories", testInvalidCategories),
        ("testSearchEpisodesShowsNoMarket", testSearchEpisodesShowsNoMarket),
        ("testSearchAllCategories", testSearchAllCategories),
        ("testSpecificTrackSearch", testSpecificTrackSearch),
        ("testFilteredSearchForAbbeyRoad", testFilteredSearchForAbbeyRoad),
        ("testFilteredSearchForAudiobook", testFilteredSearchForAudiobook),
        ("testFilteredSearchNoMatches", testFilteredSearchNoMatches)
    ]
    
    func testInvalidCategories() { invalidCategories() }
    func testSearchEpisodesShowsNoMarket() { searchEpisodesShowsNoMarket() }
    func testSearchAllCategories() { searchAllCategories() }
    func testSpecificTrackSearch() { specificTrackSearch() }
    func testFilteredSearchForAbbeyRoad() { filteredSearchForAbbeyRoad() }
    func testFilteredSearchForAudiobook() { filteredSearchForAudiobook() }
    func testFilteredSearchNoMatches() { filteredSearchNoMatches() }
}

final class SpotifyAPIAuthorizationCodeFlowSearchTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPISearchTests
{
    
    static let allTests = [
        ("testInvalidCategories", testInvalidCategories),
        ("testSearchEpisodesShowsNoMarket", testSearchEpisodesShowsNoMarket),
        ("testSearchAllCategories", testSearchAllCategories),
        ("testSpecificTrackSearch", testSpecificTrackSearch),
        ("testFilteredSearchForAbbeyRoad", testFilteredSearchForAbbeyRoad),
        ("testFilteredSearchForAudiobook", testFilteredSearchForAudiobook),
        ("testFilteredSearchNoMatches", testFilteredSearchNoMatches)
    ]
    
    func testInvalidCategories() { invalidCategories() }
    func testSearchEpisodesShowsNoMarket() { searchEpisodesShowsNoMarket() }
    func testSearchAllCategories() { searchAllCategories() }
    func testSpecificTrackSearch() { specificTrackSearch() }
    func testFilteredSearchForAbbeyRoad() { filteredSearchForAbbeyRoad() }
    func testFilteredSearchForAudiobook() { filteredSearchForAudiobook() }
    func testFilteredSearchNoMatches() { filteredSearchNoMatches() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCESearchTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPISearchTests
{
    
    static let allTests = [
        ("testInvalidCategories", testInvalidCategories),
        ("testSearchEpisodesShowsNoMarket", testSearchEpisodesShowsNoMarket),
        ("testSearchAllCategories", testSearchAllCategories),
        ("testSpecificTrackSearch", testSpecificTrackSearch),
        ("testFilteredSearchForAbbeyRoad", testFilteredSearchForAbbeyRoad),
        ("testFilteredSearchForAudiobook", testFilteredSearchForAudiobook),
        ("testFilteredSearchNoMatches", testFilteredSearchNoMatches)
    ]
    
    func testInvalidCategories() { invalidCategories() }
    func testSearchEpisodesShowsNoMarket() { searchEpisodesShowsNoMarket() }
    func testSearchAllCategories() { searchAllCategories() }
    func testSpecificTrackSearch() { specificTrackSearch() }
    func testFilteredSearchForAbbeyRoad() { filteredSearchForAbbeyRoad() }
    func testFilteredSearchForAudiobook() { filteredSearchForAudiobook() }
    func testFilteredSearchNoMatches() { filteredSearchNoMatches() }
    
}
