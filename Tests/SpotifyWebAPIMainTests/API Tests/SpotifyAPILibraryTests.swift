import Foundation
import XCTest
#if canImport(Combine)
import Combine
#else
import OpenCombine


#endif
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

protocol SpotifyAPILibraryTests: SpotifyAPITests { }

extension SpotifyAPILibraryTests where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{
    
    func saveAlbums() {
        
        let fullAlbums = URIs.Albums.array(
            .skiptracing, .housesOfTheHoly, .tiger, .illmatic
        )
        
        let partialAlbunms = URIs.Albums.array(
            .skiptracing, .housesOfTheHoly
        )
        
        let expectation = XCTestExpectation(description: "testSaveAlbums")
        
        let publisher: AnyPublisher<Void, Error> = Self.spotify
            .removeSavedAlbumsForCurrentUser(fullAlbums)
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedAlbums(
                    limit: 50, offset: 0
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .flatMap { savedAlbumsArray -> AnyPublisher<Void, Error> in
                let allAlbums = savedAlbumsArray
                    .flatMap(\.items).compactMap(\.item.uri)
                for album in allAlbums {
                    XCTAssertFalse(fullAlbums.contains(album))
                }
                return Self.spotify.saveAlbumsForCurrentUser(partialAlbunms)
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()

        publisher
            .receiveOnMain(delay: 1)
            .flatMap { () -> AnyPublisher<[Bool], Error> in
                Self.spotify.currentUserSavedAlbumsContains(fullAlbums)
            }
            .XCTAssertNoFailure()
            .flatMap { results -> AnyPublisher<Void, Error> in
                XCTAssertEqual(results, [true, true, false, false])
                return Self.spotify.removeSavedAlbumsForCurrentUser(fullAlbums)
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedAlbums(
                    limit: 50, offset: 0
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { savedAlbumsArray in
                    let allAlbums = savedAlbumsArray
                        .flatMap(\.items).compactMap(\.item.uri)
                    for album in allAlbums {
                        XCTAssertFalse(fullAlbums.contains(album))
                    }
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)
            
    }
    
    func saveTracks() {
        
        let fullTracks = URIs.Tracks.array(
            .because, .blueBoy, .breathe, .faces
        )
        
        let partialTracks = URIs.Tracks.array(
            .because, .blueBoy
        )
        
        let expectation = XCTestExpectation(description: "testSaveTracks")
        
         let publisher: AnyPublisher<Void, Error> = Self.spotify
            .removeSavedTracksForCurrentUser(fullTracks)
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedTracks(
                    limit: 50, offset: 0
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .flatMap { savedTracksArray -> AnyPublisher<Void, Error> in
                let allTracks = savedTracksArray
                    .flatMap(\.items).compactMap(\.item.uri)
                for track in allTracks {
                    XCTAssertFalse(fullTracks.contains(track))
                }
                return Self.spotify.saveTracksForCurrentUser(partialTracks)
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()
        
        publisher
            .receiveOnMain(delay: 1)
            .flatMap { () -> AnyPublisher<[Bool], Error> in
                Self.spotify.currentUserSavedTracksContains(fullTracks)
            }
            .XCTAssertNoFailure()
            .flatMap { results -> AnyPublisher<Void, Error> in
                XCTAssertEqual(results, [true, true, false, false])
                return Self.spotify.removeSavedTracksForCurrentUser(fullTracks)
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedTracks(
                    limit: 50, offset: 0
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { savedTracksArray in
                    let allTracks = savedTracksArray
                        .flatMap(\.items).compactMap(\.item.uri)
                    for track in allTracks {
                        XCTAssertFalse(fullTracks.contains(track))
                    }
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)
            
    }
    
    func saveShows() {
        
        let fullShows = URIs.Shows.array(
            .joeRogan, .samHarris, .scienceSalon, .seanCarroll
        )
        
        let partialShows = URIs.Shows.array(
            .joeRogan, .samHarris
        )
        
        let expectation = XCTestExpectation(description: "testSaveTracks")
        
        let publisher: AnyPublisher<Void, Error> = Self.spotify
            .removeSavedShowsForCurrentUser(fullShows)
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedShows(
                    limit: 50, offset: 0
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .flatMap { savedShowsArray -> AnyPublisher<Void, Error> in
                let allShows = savedShowsArray
                    .flatMap(\.items).map(\.item.uri)
                for show in allShows {
                    XCTAssertFalse(fullShows.contains(show))
                }
                return Self.spotify.saveShowsForCurrentUser(partialShows)
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()
        
        publisher
            .receiveOnMain(delay: 1)
            .flatMap { () -> AnyPublisher<[Bool], Error> in
                Self.spotify.currentUserSavedShowsContains(fullShows)
            }
            .XCTAssertNoFailure()
            .flatMap { results -> AnyPublisher<Void, Error> in
                XCTAssertEqual(results, [true, true, false, false])
                return Self.spotify.removeSavedShowsForCurrentUser(fullShows)
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedShows(
                    limit: 50, offset: 0
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { savedShowsArray in
                    let allShows = savedShowsArray
                        .flatMap(\.items).map(\.item.uri)
                    for show in allShows {
                        XCTAssertFalse(fullShows.contains(show))
                    }
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)
            
    }
    
    
}

final class SpotifyAPIAuthorizationCodeFlowLibraryTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPILibraryTests
{
    
    static let allTests = [
        ("testSaveAlbums", testSaveAlbums),
        ("testSaveTracks", testSaveTracks),
        ("testSaveShows", testSaveShows)
    ]
    
    func testSaveAlbums() { saveAlbums() }
    func testSaveTracks() { saveTracks() }
    func testSaveShows() { saveShows() }

}

final class SpotifyAPIAuthorizationCodeFlowPKCELibraryTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPILibraryTests
{
    
    static let allTests = [
        ("testSaveAlbums", testSaveAlbums),
        ("testSaveTracks", testSaveTracks),
        ("testSaveShows", testSaveShows)
    ]
    
    func testSaveAlbums() { saveAlbums() }
    func testSaveTracks() { saveTracks() }
    func testSaveShows() { saveShows() }

}
