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


protocol SpotifyAPIArtistTests: SpotifyAPITests { }

extension SpotifyAPIArtistTests {
    
    func receivePinkFloyd(_ artist: Artist) {
        print("receivePinkFloyd")
        encodeDecode(artist, areEqual: ==)
        
        XCTAssertEqual(artist.name, "Pink Floyd")
        XCTAssertEqual(artist.type, .artist)
        XCTAssertEqual(artist.uri, "spotify:artist:0k17h0D3J5VfsdmQ1iZtE9")
        XCTAssertEqual(artist.id, "0k17h0D3J5VfsdmQ1iZtE9")
        XCTAssertEqual(
            artist.href,
            URL(string: "https://api.spotify.com/v1/artists/0k17h0D3J5VfsdmQ1iZtE9")!
        )
        if let popularity = artist.popularity {
            XCTAssert((0...100).contains(popularity), "\(popularity)")
        }
        else {
            XCTFail("popularity should not be nil")
        }
        
        if let genres = artist.genres {
            XCTAssert(genres.contains("art rock"))
            XCTAssert(genres.contains("album rock"))
            XCTAssert(genres.contains("classic rock"))
            XCTAssert(genres.contains("progressive rock"))
            XCTAssert(genres.contains("psychedelic rock"))
            XCTAssert(genres.contains("rock"))
            XCTAssert(genres.contains("symphonic rock"))
        }
        else {
            XCTFail("genres should not be nil")
        }

        if let externalURLs = artist.externalURLs {
            XCTAssertEqual(
                externalURLs["spotify"],
                URL(string: "https://open.spotify.com/artist/0k17h0D3J5VfsdmQ1iZtE9")!,
                "\(externalURLs)"
            )
        }
        else {
            XCTFail("externalURLs should not be nil")
        }
        
        if let followers = artist.followers {
            XCTAssert(followers.total > 1_000_000, "\(followers.total)")
        }
        else {
            XCTFail("followers should not be nil")
        }
        
        XCTAssertImagesExist(artist.images, assertSizeNotNil: true)
        
    }
    
    func receiveArtistAlbums(_ albums: PagingObject<Album>) {

        XCTAssertGreaterThanOrEqual(albums.items.count, 4)
        XCTAssertEqual(albums.items.count, albums.total)
        XCTAssertEqual(albums.limit, 35)
        XCTAssertEqual(albums.offset, 0)
        XCTAssertNil(albums.next)
        XCTAssertNil(albums.previous)
        
        let expectedAlbumsHREF = """
            https://api.spotify.com/v1/artists/4kSGbjWGxTchKpIxXPJv0B\
            /albums?offset=0&limit=35&include_groups=album,single,\
            compilation,appears_on&market=US
            """
        XCTAssert(
            albums.href.absoluteString.starts(
                with: expectedAlbumsHREF
            ),
            "\(albums.href.absoluteString) does not start with " +
            "\(expectedAlbumsHREF)"
        )
        
        for album in albums.items {
            XCTAssertEqual(album.artists?.first?.name, "Crumb")
            XCTAssertEqual(
                album.artists?.first?.uri,
                "spotify:artist:4kSGbjWGxTchKpIxXPJv0B"
            )
            
        }

    }

    func artist() {
        
        let expectation = XCTestExpectation(description: "testArtist")
        
        Self.spotify.artist(URIs.Artists.pinkFloyd)
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receivePinkFloyd(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 60)

    }

    func artists() {
        
        func receiveArtists(_ artists: [Artist?]) {

            for artist in artists {
                if let artist = artist {
                    XCTAssertEqual(artist.type, .artist)
                }
                encodeDecode(artist, areEqual: ==)
            }
            
            
            guard artists.count == 5 else {
                XCTFail("should've received 5 artists (got \(artists.count)")
                return
            }
            
            XCTAssertNil(
                artists[1],
                "second artist should be nil because URI is invalid"
            )
            
            XCTAssertEqual(artists[0]?.name, "levitation room")
            XCTAssertEqual(artists[0]?.uri, "spotify:artist:0SVxQVCnJn1BNUMY9ZcRO4")
            XCTAssertEqual(artists[0]?.id, "0SVxQVCnJn1BNUMY9ZcRO4")
            
            XCTAssertEqual(artists[2]?.name, "The Beatles")
            XCTAssertEqual(artists[2]?.uri, "spotify:artist:3WrFJ7ztbogyGnTHbHJFl2")
            XCTAssertEqual(artists[2]?.id, "3WrFJ7ztbogyGnTHbHJFl2")
            
            XCTAssertEqual(artists[3]?.name, "Radiohead")
            XCTAssertEqual(artists[3]?.uri, "spotify:artist:4Z8W4fKeB5YxbusRsdQVPb")
            XCTAssertEqual(artists[3]?.id, "4Z8W4fKeB5YxbusRsdQVPb")

            if let pinkFloyd = artists[4] {
                receivePinkFloyd(pinkFloyd)
            }
            else {
                XCTFail("fifth artist should not be nil")
            }
            
        }
        
        let artists: [SpotifyURIConvertible] = [
            URIs.Artists.levitationRoom,
            "spotify:artist:invaliduri",
            URIs.Artists.theBeatles,
            URIs.Artists.radiohead,
            URIs.Artists.pinkFloyd
        ]
        
        let expectation = XCTestExpectation(description: "testArtists")
        
        Self.spotify.artists(artists)
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveArtists(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 60)

    }
    
    func artistAlbums() {
        
        func receiveArtistAlbums(_ albums: PagingObject<Album>) {
            
            encodeDecode(albums)
            
            // reverse the albums so that if new albums are released,
            // the tests will still pass.
            let reversedAlbums = Array(albums.items.reversed())
            guard reversedAlbums.count >= 19 else {
                XCTFail(
                    "Pink Floyd should have at least 19 albums " +
                    "(got \(reversedAlbums.count)"
                )
                return
            }
            for album in reversedAlbums {
                
                encodeDecode(album)
                
                // this is a compilation album; it should not be returned because
                // we only requested the `album` albumGroup.
                XCTAssertNotEqual(album.uri, "spotify:album:361QTNnQcBcNJ38gn8ZWQw")
                XCTAssertNotEqual(album.id, "361QTNnQcBcNJ38gn8ZWQw")
                XCTAssertNotEqual(album.name, "Relics")
                
                XCTAssertEqual(album.type, .album)
                XCTAssertEqual(album.albumGroup, .album)
                XCTAssertEqual(album.albumType, .album)
                XCTAssertEqual(album.artists?.first?.name, "Pink Floyd")
                XCTAssertEqual(
                    album.artists?.first?.uri,
                    "spotify:artist:0k17h0D3J5VfsdmQ1iZtE9"
                )
                XCTAssertEqual(
                    album.artists?.first?.id,
                    "0k17h0D3J5VfsdmQ1iZtE9"
                )
            }
            do {
                let album = reversedAlbums[0]
                XCTAssertEqual(album.name, "The Piper at the Gates of Dawn")
                XCTAssertEqual(album.uri, "spotify:album:2Se4ZylF9NkFGD92yv1aZC")
                XCTAssertEqual(album.id, "2Se4ZylF9NkFGD92yv1aZC")
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        -76032000,
                        accuracy: 43_200  // 12 hours
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
                
            }
            do {
                let album = reversedAlbums[1]
                XCTAssertEqual(album.name, "A Saucerful of Secrets")
                XCTAssertEqual(album.uri, "spotify:album:2vnJKtGjZXRUg0mYPZ3HGH")
                XCTAssertEqual(album.id, "2vnJKtGjZXRUg0mYPZ3HGH")
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        -47588400,
                        accuracy: 43_200
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
                
            }
            do {
                let album = reversedAlbums[2]
                XCTAssertEqual(album.name, "More")
                XCTAssertEqual(album.uri, "spotify:album:6AccmjV8Q5cEUZ2tvS8s6c")
                XCTAssertEqual(album.id, "6AccmjV8Q5cEUZ2tvS8s6c")
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        -13633200,
                        accuracy: 43_200
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
            }
            do {
                let album = reversedAlbums[3]
                XCTAssertEqual(
                    album.name,
                    "Ummagumma"
                )
                XCTAssertEqual(album.uri, "spotify:album:3IPhWIXHOAhS2npnq6FiCG")
                XCTAssertEqual(album.id, "3IPhWIXHOAhS2npnq6FiCG")
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        -5857200,
                        accuracy: 43_200
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
            }
            
        }
        
        let expectation = XCTestExpectation(description: "testArtistAlbums")
        
        Self.spotify.artistAlbums(
            URIs.Artists.pinkFloyd,
            groups: [.album],
            country: "US",
            limit: 50,
            offset: 0
        )
        .receiveOnMain()
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in
                expectation.fulfill()
            },
            receiveValue: receiveArtistAlbums(_:)
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 60)

    }
    
    /// Ensure that `extendPages` works even though there is only a single
    /// page of results to return.
    func artistAlbumsExtendSinglePageSerial() {
        
        var receivedPages = 0

        let expectation = XCTestExpectation(
            description: "artistAlbumsExtendSinglePageSerial"
        )
        
        let artist = URIs.Artists.crumb

        Self.spotify.artistAlbums(artist, country: "US", limit: 35)
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { albums in
                    receivedPages += 1
                    self.receiveArtistAlbums(albums)
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        XCTAssertEqual(receivedPages, 1)
            

    }

    /// Ensure that `extendPagesConcurrently` works even though there
    /// is only a single page of results to return.
    func artistAlbumsExtendSinglePageConcurrent() {
        
        #if canImport(Combine)

        var receivedPages = 0

        let queue = DispatchQueue(
            label: "artistAlbumsExtendSinglePageConcurrent"
        )

        let expectation = XCTestExpectation(
            description: "artistAlbumsExtendSinglePageConcurrent"
        )
        
        let artist = URIs.Artists.crumb

        Self.spotify.artistAlbums(artist, country: "US", limit: 35)
            .XCTAssertNoFailure()
            .extendPagesConcurrently(Self.spotify)
            .XCTAssertNoFailure()
            .receive(on: queue)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { albums in
                    receivedPages += 1
                    self.receiveArtistAlbums(albums)
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        XCTAssertEqual(receivedPages, 1)
        
        #endif

    }

    func artistAlbumsSingles() {
        
        func receiveArtistAlbums(_ albums: PagingObject<Album>) {
            encodeDecode(albums)
            for album in albums.items {
                encodeDecode(album)
                XCTAssertEqual(album.albumGroup, .single)
                XCTAssertEqual(album.artists?.first?.name, "Radiohead")
                XCTAssertEqual(
                    album.artists?.first?.uri,
                    "spotify:artist:4Z8W4fKeB5YxbusRsdQVPb"
                )
                
                // these albums are not singles
                XCTAssertNotEqual(
                    album.uri, URIs.Albums.inRainbows.uri
                )
                XCTAssertNotEqual(
                    album.id, "3gBVdu4a1MMJVMy6vwPEb8"
                )
                XCTAssertNotEqual(
                    album.uri, "spotify:album:6ofEQubaL265rIW6WnCU8y"
                )
                
            }
            let reversedAlbums = Array(albums.items.reversed())
            guard reversedAlbums.count >= 3 else {
                XCTFail(
                    "Radiohead should have at least 3 singles " +
                    "(got \(reversedAlbums.count))"
                )
                return
            }
            do {
                let album = reversedAlbums[0]
                XCTAssertEqual(
                    album.name, "Drill EP"
                )
                XCTAssertEqual(album.uri, "spotify:album:2EUUCdjvEujOc0E3X6yAEr")
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        705042000,
                        accuracy: 43_200  // 12 hours
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
            }
            do {
                let album = reversedAlbums[1]
                XCTAssertEqual(
                    album.name, "Creep"
                )
                XCTAssertEqual(album.uri, "spotify:album:3RQlNKc08ikcuFmbg0luEw")
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        717051600,
                        accuracy: 43_200  // 12 hours
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
            }
            do {
                let album = reversedAlbums[2]
                XCTAssertEqual(
                    album.name, "Anyone Can Play Guitar"
                )
                XCTAssertEqual(album.uri, "spotify:album:37v03kt4FbojREz2VOg4BN")
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        727941600,
                        accuracy: 43_200  // 12 hours
                    )
                }
                else {
                    XCTFail("release date should not be nil")
                }
            }
            
        }
        
        let expectation = XCTestExpectation(
            description: "testArtistAlbumsSingles"
        )
        
        let authorizationManagerDidChangeExpectation = XCTestExpectation(
            description: "authorizationManagerDidChange"
        )
        let internalQueue = DispatchQueue(label: "internal")

        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didChangeCount += 1
                internalQueue.asyncAfter(deadline: .now() + 2) {
                    authorizationManagerDidChangeExpectation.fulfill()
                }
            })
            .store(in: &cancellables)
        
        Self.spotify.authorizationManager.setExpirationDate(to: Date())

        Self.spotify.artistAlbums(
            URIs.Artists.radiohead,
            groups: [.single],
            country: "US",
            limit: 50
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveArtistAlbums(_:)
        )
        .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 60)
        self.wait(
            for: [authorizationManagerDidChangeExpectation],
            timeout: 5
        )

        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 1,
                "authorizationManagerDidChange should emit exactly once"
            )
        }
        
    }
    
    func artistTopTracks() {
        
        let expectation = XCTestExpectation(
            description: "testArtistTopTracks"
        )
        
        Self.spotify.authorizationManager.setExpirationDate(to: Date())
        var authChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            authChangeCount += 1
        })
        .store(in: &cancellables)

        Self.spotify.artistTopTracks(
            URIs.Artists.theBeatles, country: "US"
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { tracks in
                encodeDecode(tracks)
                for track in tracks {
                    encodeDecode(track)
                    guard let artist = track.artists?.first else {
                        XCTFail("no artists for track '\(track.name)'")
                        continue
                    }
                    XCTAssertEqual(artist.name, "The Beatles")
                    XCTAssertEqual(artist.uri, "spotify:artist:3WrFJ7ztbogyGnTHbHJFl2")
                    XCTAssertEqual(artist.id, "3WrFJ7ztbogyGnTHbHJFl2")
                    
                }
            }
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 60)
        XCTAssertEqual(
            authChangeCount, 1,
            "authorizationManagerDidChange should emit exactly once"
        )
        
    }
    
    func relatedArtists() {
        
        let expectation = XCTestExpectation(
            description: "testRelatedArtists"
        )
        
        Self.spotify.relatedArtists(URIs.Artists.crumb)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { artists in
                    encodeDecode(artists, areEqual: ==)
                    for artist in artists {
                        encodeDecode(artist, areEqual: ==)
                        XCTAssertEqual(artist.type, .artist)
                        XCTAssertNotNil(artist.name)
                        XCTAssertNotNil(artist.id)
                        XCTAssertNotNil(artist.uri)
                        XCTAssertNotNil(artist.genres)
                        XCTAssertNotNil(artist.href)
                        XCTAssertNotNil(artist.popularity)
                    }
                }
            )
            .store(in: &Self.cancellables)
            
        self.wait(for: [expectation], timeout: 60)
        
    }
    
}

// MARK: Authorization and setup methods

extension SpotifyAPIArtistTests where
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager
{

    /// Authorize for zero scopes because none are required for the artist
    /// endpoints. The super implementation authorizes for all scopes.
    static func _setupAuthorization() {
        
        spotifyDecodeLogger.logLevel = .trace
        Self.spotify.authorizationManager.deauthorize()
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
        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: [], showDialog: false
        )

    }
    
    static func _tearDown() {
        spotifyDecodeLogger.logLevel = .warning
    }

    func _setup() {
        // XCTAssertEqual(
        //     Self.spotify.authorizationManager.scopes, [],
        //     "authorizationManager should contain zero scopes: " +
        //     "\(Self.spotify.authorizationManager)"
        // )
        // XCTAssertTrue(
        //     Self.spotify.authorizationManager.isAuthorized(for: []),
        //     "should be authorized for zero scopes: " +
        //     "\(Self.spotify.authorizationManager)"
        // )
        // let randomScope = Scope.allCases.randomElement()!
        // XCTAssertFalse(
        //     Self.spotify.authorizationManager.isAuthorized(for: [randomScope]),
        //     "sh ould not be authorized for \(randomScope.rawValue): " +
        //     "\(Self.spotify.authorizationManager)"
        // )
    }
    
}

// MARK: - Client -

final class SpotifyAPIClientCredentialsFlowArtistTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIArtistTests
{

    static let allTests = [
        ("testArtist", testArtist),
        ("testArtists", testArtists),
        ("testArtistAlbums", testArtistAlbums),
        (
            "testArtistAlbumsExtendSinglePageSerial",
            testArtistAlbumsExtendSinglePageSerial
        ),
        (
            "testArtistAlbumsExtendSinglePageConcurrent",
            testArtistAlbumsExtendSinglePageConcurrent
        ),
        ("testArtistAlbumsSingles", testArtistAlbumsSingles),
        ("testArtistTopTracks", testArtistTopTracks),
        ("testRelatedArtists", testRelatedArtists)
        
    ]
    
    func testArtist() { artist() }
    func testArtists() { artists() }
    func testArtistAlbums() { artistAlbums() }
    func testArtistAlbumsExtendSinglePageSerial() {
        artistAlbumsExtendSinglePageSerial()
    }
    func testArtistAlbumsExtendSinglePageConcurrent() {
        artistAlbumsExtendSinglePageConcurrent()
    }
    func testArtistAlbumsSingles() { artistAlbumsSingles() }
    func testArtistTopTracks() { artistTopTracks() }
    func testRelatedArtists() { relatedArtists() }
    
}

final class SpotifyAPIAuthorizationCodeFlowArtistTests:
        SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIArtistTests
{

    static let allTests = [
        ("testArtist", testArtist),
        ("testArtists", testArtists),
        ("testArtistAlbums", testArtistAlbums),
        (
            "testArtistAlbumsExtendSinglePageSerial",
            testArtistAlbumsExtendSinglePageSerial
        ),
        (
            "testArtistAlbumsExtendSinglePageConcurrent",
            testArtistAlbumsExtendSinglePageConcurrent
        ),
        ("testArtistAlbumsSingles", testArtistAlbumsSingles),
        ("testArtistTopTracks", testArtistTopTracks),
        ("testRelatedArtists", testRelatedArtists)
        
    ]
    
    /// Authorize for zero scopes because none are required for the artist
    /// endpoints. The super implementation authorizes for all scopes.
    override class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases,
        showDialog: Bool = true
    ) {
        Self._setupAuthorization()
    }

    override class func tearDown() {
        Self._tearDown()
    }

    override func setUp() {
        self._setup()
    }
    
    func testArtist() { artist() }
    func testArtists() { artists() }
    func testArtistAlbums() { artistAlbums() }
    func testArtistAlbumsExtendSinglePageSerial() {
        artistAlbumsExtendSinglePageSerial()
    }
    func testArtistAlbumsExtendSinglePageConcurrent() {
        artistAlbumsExtendSinglePageConcurrent()
    }
    func testArtistAlbumsSingles() { artistAlbumsSingles() }
    func testArtistTopTracks() { artistTopTracks() }
    func testRelatedArtists() { relatedArtists() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEArtistTests:
        SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIArtistTests
{

    static let allTests = [
        ("testArtist", testArtist),
        ("testArtists", testArtists),
        ("testArtistAlbums", testArtistAlbums),
        (
            "testArtistAlbumsExtendSinglePageSerial",
            testArtistAlbumsExtendSinglePageSerial
        ),
        (
            "testArtistAlbumsExtendSinglePageConcurrent",
            testArtistAlbumsExtendSinglePageConcurrent
        ),
        ("testArtistAlbumsSingles", testArtistAlbumsSingles),
        ("testArtistTopTracks", testArtistTopTracks),
        ("testRelatedArtists", testRelatedArtists)
        
    ]
    
    /// Authorize for zero scopes because none are required for the artist
    /// endpoints. The super implementation authorizes for all scopes.
    override class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases
    ) {
        Self._setupAuthorization()
    }

    override class func tearDown() {
        Self._tearDown()
    }

    override func setUp() {
        self._setup()
    }
    
    func testArtist() { artist() }
    func testArtists() { artists() }
    func testArtistAlbums() { artistAlbums() }
    func testArtistAlbumsExtendSinglePageSerial() {
        artistAlbumsExtendSinglePageSerial()
    }
    func testArtistAlbumsExtendSinglePageConcurrent() {
        artistAlbumsExtendSinglePageConcurrent()
    }
    func testArtistAlbumsSingles() { artistAlbumsSingles() }
    func testArtistTopTracks() { artistTopTracks() }
    func testRelatedArtists() { relatedArtists() }
    
}

// MARK: - Proxy -

final class SpotifyAPIClientCredentialsFlowProxyArtistTests:
    SpotifyAPIClientCredentialsFlowProxyTests, SpotifyAPIArtistTests
{

    static let allTests = [
        ("testArtist", testArtist),
        ("testArtists", testArtists),
        ("testArtistAlbums", testArtistAlbums),
        (
            "testArtistAlbumsExtendSinglePageSerial",
            testArtistAlbumsExtendSinglePageSerial
        ),
        (
            "testArtistAlbumsExtendSinglePageConcurrent",
            testArtistAlbumsExtendSinglePageConcurrent
        ),
        ("testArtistAlbumsSingles", testArtistAlbumsSingles),
        ("testArtistTopTracks", testArtistTopTracks),
        ("testRelatedArtists", testRelatedArtists)
        
    ]
    
    func testArtist() { artist() }
    func testArtists() { artists() }
    func testArtistAlbums() { artistAlbums() }
    func testArtistAlbumsExtendSinglePageSerial() {
        artistAlbumsExtendSinglePageSerial()
    }
    func testArtistAlbumsExtendSinglePageConcurrent() {
        artistAlbumsExtendSinglePageConcurrent()
    }
    func testArtistAlbumsSingles() { artistAlbumsSingles() }
    func testArtistTopTracks() { artistTopTracks() }
    func testRelatedArtists() { relatedArtists() }
    
}

final class SpotifyAPIAuthorizationCodeFlowProxyArtistTests:
        SpotifyAPIAuthorizationCodeFlowProxyTests, SpotifyAPIArtistTests
{

    static let allTests = [
        ("testArtist", testArtist),
        ("testArtists", testArtists),
        ("testArtistAlbums", testArtistAlbums),
        (
            "testArtistAlbumsExtendSinglePageSerial",
            testArtistAlbumsExtendSinglePageSerial
        ),
        (
            "testArtistAlbumsExtendSinglePageConcurrent",
            testArtistAlbumsExtendSinglePageConcurrent
        ),
        ("testArtistAlbumsSingles", testArtistAlbumsSingles),
        ("testArtistTopTracks", testArtistTopTracks),
        ("testRelatedArtists", testRelatedArtists)
        
    ]
    
    /// Authorize for zero scopes because none are required for the artist
    /// endpoints. The super implementation authorizes for all scopes.
    override class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases,
        showDialog: Bool = true
    ) {
        Self._setupAuthorization()
    }

    override class func tearDown() {
        Self._tearDown()
    }

    override func setUp() {
        self._setup()
    }
    
    func testArtist() { artist() }
    func testArtists() { artists() }
    func testArtistAlbums() { artistAlbums() }
    func testArtistAlbumsExtendSinglePageSerial() {
        artistAlbumsExtendSinglePageSerial()
    }
    func testArtistAlbumsExtendSinglePageConcurrent() {
        artistAlbumsExtendSinglePageConcurrent()
    }
    func testArtistAlbumsSingles() { artistAlbumsSingles() }
    func testArtistTopTracks() { artistTopTracks() }
    func testRelatedArtists() { relatedArtists() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEProxyArtistTests:
        SpotifyAPIAuthorizationCodeFlowPKCEProxyTests, SpotifyAPIArtistTests
{

    static let allTests = [
        ("testArtist", testArtist),
        ("testArtists", testArtists),
        ("testArtistAlbums", testArtistAlbums),
        (
            "testArtistAlbumsExtendSinglePageSerial",
            testArtistAlbumsExtendSinglePageSerial
        ),
        (
            "testArtistAlbumsExtendSinglePageConcurrent",
            testArtistAlbumsExtendSinglePageConcurrent
        ),
        ("testArtistAlbumsSingles", testArtistAlbumsSingles),
        ("testArtistTopTracks", testArtistTopTracks),
        ("testRelatedArtists", testRelatedArtists)
        
    ]
    
    /// Authorize for zero scopes because none are required for the artist
    /// endpoints. The super implementation authorizes for all scopes.
    override class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases
    ) {
        Self._setupAuthorization()
    }

    override class func tearDown() {
        Self._tearDown()
    }

    override func setUp() {
        self._setup()
    }
    
    func testArtist() { artist() }
    func testArtists() { artists() }
    func testArtistAlbums() { artistAlbums() }
    func testArtistAlbumsExtendSinglePageSerial() {
        artistAlbumsExtendSinglePageSerial()
    }
    func testArtistAlbumsExtendSinglePageConcurrent() {
        artistAlbumsExtendSinglePageConcurrent()
    }
    func testArtistAlbumsSingles() { artistAlbumsSingles() }
    func testArtistTopTracks() { artistTopTracks() }
    func testRelatedArtists() { relatedArtists() }
    
}
