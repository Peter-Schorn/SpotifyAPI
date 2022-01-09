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

protocol SpotifyAPILibraryTests: SpotifyAPITests { }

extension SpotifyAPILibraryTests where
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager
{
    
    func saveAlbums() {
        
        let fullAlbums = URIs.Albums.array(
            .skiptracing, .housesOfTheHoly, .tiger, .illmatic
        )
        
        let partialAlbums = URIs.Albums.array(
            .skiptracing, .housesOfTheHoly
        )
        
        let expectation = XCTestExpectation(description: "testSaveAlbums")
        
        let publisher: AnyPublisher<Void, Error> = Self.spotify
            .removeSavedAlbumsForCurrentUser(fullAlbums)
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedAlbums(
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .flatMap { savedAlbumsArray -> AnyPublisher<Void, Error> in
                encodeDecode(savedAlbumsArray)
                
                let allAlbums = savedAlbumsArray
                    .flatMap(\.items)
                for album in allAlbums {
                    XCTAssertEqual(album.type, .album)
                }
                
                let albumURIs = allAlbums
                    .compactMap(\.item.uri)
                for album in albumURIs {
                    XCTAssertFalse(fullAlbums.contains(album))
                }
                
                return Self.spotify.saveAlbumsForCurrentUser(partialAlbums)
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()

        publisher
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedAlbums(
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPagesConcurrently(Self.spotify)
            .XCTAssertNoFailure()
            .collectAndSortByOffset()
            .flatMap { savedAlbums -> AnyPublisher<[Bool], Error> in
                encodeDecode(savedAlbums)
                // fullAlbums were removed from the library.
                // Library contains partialAlbums
                for album in savedAlbums {
                    XCTAssertEqual(album.type, .album)
                }
                let albumURIs = savedAlbums.compactMap(\.item.uri)
                for album in partialAlbums {
                    XCTAssert(albumURIs.contains(album))
                }

                XCTAssertFalse(
                    albumURIs.contains(URIs.Albums.tiger.uri)
                )
                XCTAssertFalse(
                    albumURIs.contains(URIs.Albums.illmatic.uri)
                )

                if let skipTracing = savedAlbums.first(where: { album in
                    album.item.uri == URIs.Albums.skiptracing.uri
                }) {
                    XCTAssertEqual(
                        skipTracing.addedAt.timeIntervalSince1970,
                        Date().timeIntervalSince1970,
                        accuracy: 20
                    )
                    XCTAssertEqual(skipTracing.item.name, "Skiptracing")
                }
                else {
                    XCTFail("saved albums should contain skiptracing")
                }
                
                if let housesOfTheHoly = savedAlbums.first(where: { album in
                    album.item.uri == URIs.Albums.housesOfTheHoly.uri
                }) {
                    XCTAssertEqual(
                        housesOfTheHoly.addedAt.timeIntervalSince1970,
                        Date().timeIntervalSince1970,
                        accuracy: 20
                    )
                    XCTAssertEqual(
                        housesOfTheHoly.item.name,
                        "Houses of the Holy (Remaster)"
                    )
                }
                else {
                    XCTFail("saved albums should contain houses of the holy")
                }

                return Self.spotify.currentUserSavedAlbumsContains(fullAlbums)
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
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { savedAlbumsArray in
                    encodeDecode(savedAlbumsArray)
                    
                    let allAlbums = savedAlbumsArray
                        .flatMap(\.items)
                    for album in allAlbums {
                        XCTAssertEqual(album.type, .album)
                    }
                    
                    let albumURIs = allAlbums
                        .compactMap(\.item.uri)
                    for album in albumURIs {
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
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .flatMap { savedTracksArray -> AnyPublisher<Void, Error> in
                encodeDecode(savedTracksArray)
                let allTracks = savedTracksArray
                    .flatMap(\.items)
                for track in allTracks {
                    XCTAssertEqual(track.type, .track)
                }

                let trackURIs = allTracks
                    .compactMap(\.item.uri)
                for track in trackURIs {
                    XCTAssertFalse(fullTracks.contains(track))
                }
                
                return Self.spotify.saveTracksForCurrentUser(partialTracks)
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()
        
        publisher
            .receiveOnMain(delay: 3)
            .flatMap {
                Self.spotify.currentUserSavedTracks(
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPagesConcurrently(Self.spotify)
            .XCTAssertNoFailure()
            .collectAndSortByOffset()
            .flatMap { savedTracks -> AnyPublisher<[Bool], Error> in
                encodeDecode(savedTracks)
                // fullTracks were removed from the library.
                // Library contains partialTracks
                for track in savedTracks {
                    XCTAssertEqual(track.type, .track)
                }
                let trackURIs = savedTracks.compactMap(\.item.uri)
                for track in partialTracks {
                    XCTAssert(trackURIs.contains(track))
                }
                
                XCTAssertFalse(
                    trackURIs.contains(URIs.Tracks.breathe.uri)
                )
                XCTAssertFalse(
                    trackURIs.contains(URIs.Tracks.faces.uri)
                )
                
                if let because = savedTracks.first(where: { track in
                    track.item.uri == URIs.Tracks.because.uri
                }) {
                    XCTAssertEqual(
                        because.addedAt.timeIntervalSince1970,
                        Date().timeIntervalSince1970,
                        accuracy: 20
                    )
                    XCTAssertEqual(
                        because.item.name,
                        "Because - Remastered 2009"
                    )
                }
                else {
                    XCTFail("saved tracks should contain because")
                }

                if let blueBoy = savedTracks.first(where: { album in
                    album.item.uri == URIs.Tracks.blueBoy.uri
                }) {
                    XCTAssertEqual(
                        blueBoy.addedAt.timeIntervalSince1970,
                        Date().timeIntervalSince1970,
                        accuracy: 20
                    )
                    XCTAssertEqual(blueBoy.item.name, "Blue Boy")
                }
                else {
                    XCTFail("saved tracks should contain blue boy")
                }

                return Self.spotify.currentUserSavedTracksContains(fullTracks)
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
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { savedTracksArray in
                    encodeDecode(savedTracksArray)
                    let allTracks = savedTracksArray
                        .flatMap(\.items)
                    for track in allTracks {
                        XCTAssertEqual(track.type, .track)
                    }

                    let trackURIs = allTracks
                        .compactMap(\.item.uri)
                    for track in trackURIs {
                        XCTAssertFalse(fullTracks.contains(track))
                    }
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)
            
    }

    func saveEpisodes() {
        
        let fullEpisodes = URIs.Episodes.array(
            .joeRogan1531, .samHarris212, .samHarris215, .seanCarroll112
        )
        
        let partialEpisodes = URIs.Episodes.array(
            .joeRogan1531, .samHarris212
        )
        
        let expectation = XCTestExpectation(description: "testSaveEpisodes")
        
        let publisher: AnyPublisher<Void, Error> = Self.spotify
            .removeSavedEpisodesForCurrentUser(fullEpisodes)
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedEpisodes(
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .flatMap { savedEpisodesArray -> AnyPublisher<Void, Error> in
                encodeDecode(savedEpisodesArray)
                
                let allEpisodes = savedEpisodesArray
                    .flatMap(\.items)
                for episode in allEpisodes {
                    XCTAssertEqual(episode.type, .episode)
                }
                
                let episodeURIs = allEpisodes
                    .map(\.item.uri)
                for episode in episodeURIs {
                    XCTAssertFalse(fullEpisodes.contains(episode))
                }
                
                return Self.spotify.saveEpisodesForCurrentUser(partialEpisodes)
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()
        
        publisher
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedEpisodes(
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collectAndSortByOffset()
            .flatMap { savedEpisodes -> AnyPublisher<[Bool], Error> in
                encodeDecode(savedEpisodes)
                // fullEpisodes were removed from the library.
                // Library contains partialEpisodes
                for episode in savedEpisodes {
                    XCTAssertEqual(episode.type, .episode)
                }
                let episodeURIs = savedEpisodes.map(\.item.uri)
                for episode in partialEpisodes {
                    XCTAssert(episodeURIs.contains(episode))
                }
                
                XCTAssertFalse(
                    episodeURIs.contains(URIs.Episodes.samHarris215.uri)
                )
                XCTAssertFalse(
                    episodeURIs.contains(URIs.Episodes.seanCarroll112.uri)
                )
                
                if let joeRogan1531 = savedEpisodes.first(where: { episode in
                    episode.item.uri == URIs.Episodes.joeRogan1531.uri
                }) {
                    XCTAssertEqual(
                        joeRogan1531.addedAt.timeIntervalSince1970,
                        Date().timeIntervalSince1970,
                        accuracy: 20
                    )
                    XCTAssertEqual(
                        joeRogan1531.item.name,
                        "#1531 - Miley Cyrus"
                    )
                }
                else {
                    XCTFail(
                        "saved episodes should contain joe rogan 1531"
                    )
                }
                
                if let samHarris212 = savedEpisodes.first(where: { episode in
                    episode.item.uri == URIs.Episodes.samHarris212.uri
                }) {
                    XCTAssertEqual(
                        samHarris212.addedAt.timeIntervalSince1970,
                        Date().timeIntervalSince1970,
                        accuracy: 20
                    )
                    XCTAssertEqual(
                        samHarris212.item.name,
                        "#212 — A Conversation with Kathryn Paige Harden"
                    )
                }
                else {
                    XCTFail(
                        "saved episodes should contain sam harris 212"
                    )
                }
                

                return Self.spotify.currentUserSavedEpisodesContains(fullEpisodes)
            }
            .XCTAssertNoFailure()
            .flatMap { results -> AnyPublisher<Void, Error> in
                XCTAssertEqual(results, [true, true, false, false])
                return Self.spotify.removeSavedEpisodesForCurrentUser(fullEpisodes)
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedEpisodes(
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { savedEpisodesArray in
                    encodeDecode(savedEpisodesArray)
                    
                    let allEpisodes = savedEpisodesArray
                        .flatMap(\.items)
                    for episode in allEpisodes {
                        XCTAssertEqual(episode.type, .episode)
                    }
                    
                    let episodeURIs = allEpisodes
                        .map(\.item.uri)
                    for episode in episodeURIs {
                        XCTAssertFalse(fullEpisodes.contains(episode))
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
        
        let expectation = XCTestExpectation(description: "testSaveShows")
        
        let publisher: AnyPublisher<Void, Error> = Self.spotify
            .removeSavedShowsForCurrentUser(fullShows)
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedShows(
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .flatMap { savedShowsArray -> AnyPublisher<Void, Error> in
                encodeDecode(savedShowsArray)
                
                let allShows = savedShowsArray
                    .flatMap(\.items)
                for show in allShows {
                    XCTAssertEqual(show.type, .show)
                }
                
                let showURIs = allShows
                    .map(\.item.uri)
                for show in showURIs {
                    XCTAssertFalse(fullShows.contains(show))
                }
                
                return Self.spotify.saveShowsForCurrentUser(partialShows)
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()
        
        publisher
            .receiveOnMain(delay: 1)
            .flatMap {
                Self.spotify.currentUserSavedShows(
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collectAndSortByOffset()
            .flatMap { savedShows -> AnyPublisher<[Bool], Error> in
                encodeDecode(savedShows)
                // fullShows were removed from the library.
                // Library contains partialShows
                for show in savedShows {
                    XCTAssertEqual(show.type, .show)
                }
                let showURIs = savedShows.map(\.item.uri)
                for show in partialShows {
                    XCTAssert(showURIs.contains(show))
                }
                
                XCTAssertFalse(
                    showURIs.contains(URIs.Shows.scienceSalon.uri)
                )
                XCTAssertFalse(
                    showURIs.contains(URIs.Shows.seanCarroll.uri)
                )
                
                if let joeRogan = savedShows.first(where: { show in
                    show.item.uri == URIs.Shows.joeRogan.uri
                }) {
                    XCTAssertEqual(
                        joeRogan.addedAt.timeIntervalSince1970,
                        Date().timeIntervalSince1970,
                        accuracy: 20
                    )
                    XCTAssertEqual(
                        joeRogan.item.name,
                        "The Joe Rogan Experience"
                    )
                }
                else {
                    XCTFail(
                        "saved shows should contain the joe rogan experience"
                    )
                }
                
                if let samHarris = savedShows.first(where: { show in
                    show.item.uri == URIs.Shows.samHarris.uri
                }) {
                    XCTAssertEqual(
                        samHarris.addedAt.timeIntervalSince1970,
                        Date().timeIntervalSince1970,
                        accuracy: 20
                    )
                    XCTAssertEqual(
                        samHarris.item.name,
                        "Making Sense with Sam Harris"
                    )
                }
                else {
                    XCTFail(
                        "saved shows should contain making sense with sam harris"
                    )
                }
                

                return Self.spotify.currentUserSavedShowsContains(fullShows)
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
                    limit: 50, offset: 0, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { savedShowsArray in
                    encodeDecode(savedShowsArray)
                    
                    let allShows = savedShowsArray
                        .flatMap(\.items)
                    for show in allShows {
                        XCTAssertEqual(show.type, .show)
                    }
                    
                    let showURIs = allShows
                        .map(\.item.uri)
                    for show in showURIs {
                        XCTAssertFalse(fullShows.contains(show))
                    }
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)
            
    }
    
    func _setUp() {
        DistributedLock.library.lock()
    }
    
    func _tearDown() {
        DistributedLock.library.unlock()
    }
    
}

final class SpotifyAPIAuthorizationCodeFlowLibraryTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPILibraryTests
{
    
    static let allTests = [
        ("testSaveAlbums", testSaveAlbums),
        ("testSaveTracks", testSaveTracks),
        ("testSaveEpisodes", testSaveEpisodes),
        ("testSaveShows", testSaveShows)
    ]
    
    func testSaveAlbums() { saveAlbums() }
    func testSaveTracks() { saveTracks() }
    func testSaveEpisodes() { saveEpisodes() }
    func testSaveShows() { saveShows() }
    
    override func setUp() {
        self._setUp()
    }
    
    override func tearDown() {
        self._tearDown()
    }

}

final class SpotifyAPIAuthorizationCodeFlowPKCELibraryTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPILibraryTests
{
    
    static let allTests = [
        ("testSaveAlbums", testSaveAlbums),
        ("testSaveTracks", testSaveTracks),
        ("testSaveEpisodes", testSaveEpisodes),
        ("testSaveShows", testSaveShows)
    ]
    
    func testSaveAlbums() { saveAlbums() }
    func testSaveTracks() { saveTracks() }
    func testSaveEpisodes() { saveEpisodes() }
    func testSaveShows() { saveShows() }

    override func setUp() {
        self._setUp()
    }
    
    override func tearDown() {
        self._tearDown()
    }

}

#if !canImport(Combine)

extension Publisher where Output: PagingObjectProtocol {
    
    func extendPagesConcurrently<AuthorizationManager: SpotifyAuthorizationManager>(
        _ spotify: SpotifyAPI<AuthorizationManager>,
        maxExtraPages: Int? = nil
    ) -> AnyPublisher<Output, Error> {
     
        return self.extendPages(spotify, maxExtraPages: maxExtraPages)
        
    }

}

#endif
