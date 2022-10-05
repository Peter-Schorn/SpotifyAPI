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

protocol SpotifyAPIAlbumsTests: SpotifyAPITests { }

extension SpotifyAPIAlbumsTests {

    func receiveJinxAlbum(_ album: Album) {
        print("receiveJinxAlbum")
        encodeDecode(album)
        
        XCTAssertEqual(album.name, "Jinx")
        XCTAssertEqual(album.uri, "spotify:album:3vukTUpiENDHDoYTVrwqtz")
        XCTAssertEqual(album.id, "3vukTUpiENDHDoYTVrwqtz")
        XCTAssertEqual(album.albumType, .album)
        XCTAssertEqual(album.label, "Crumb Records")
        XCTAssertEqual(album.type, .album)
        XCTAssertEqual(album.tracks?.items.count, 10)
        XCTAssertEqual(album.tracks?.total, 10)
        if let popularity = album.popularity {
            XCTAssert((0...100).contains(popularity), "\(popularity)")
        }
        else {
            XCTFail("popularity should not be nil")
        }
        
        // XCTAssertEqual(album.availableMarkets?.contains("US"), true)
        
        XCTAssertEqual(
            album.href,
            URL(string: "https://api.spotify.com/v1/albums/3vukTUpiENDHDoYTVrwqtz")!
        )

        if let releaseDate = album.releaseDate {
            XCTAssertEqual(
                releaseDate.timeIntervalSince1970,
                1560470400,
                accuracy: 43_200
            )
        }
        else {
            XCTFail("release date should not be nil")
        }
        XCTAssertEqual(album.releaseDatePrecision, "day")
        
        if let copyrights = album.copyrights {
            XCTAssertEqual(copyrights[0].text, "2019 Crumb Records")
            XCTAssertEqual(copyrights[0].type, "C")
            XCTAssertEqual(copyrights[1].text, "2019 Crumb Records")
            XCTAssertEqual(copyrights[1].type, "P")
        }
        else {
            XCTFail("copyrights should not be nil")
        }

        if let externalURLs = album.externalURLs {
            XCTAssertEqual(
                externalURLs["spotify"],
                URL(string: "https://open.spotify.com/album/3vukTUpiENDHDoYTVrwqtz")!,
                "\(externalURLs)"
            )
        }
        else {
            XCTFail("externalURLs should not be nil")
        }
        
        if let externalIds = album.externalIds {
            XCTAssertEqual(
                externalIds["upc"], "656605343648",
                "\(externalIds)"
            )
        }
        else {
            XCTFail("externalIds should not be nil")
        }
        
        
        // MARK: Check Artist
        if let artist = album.artists?.first {
            XCTAssertEqual(
                artist.href,
                URL(string: "https://api.spotify.com/v1/artists/4kSGbjWGxTchKpIxXPJv0B")!
            )
            XCTAssertEqual(artist.uri, "spotify:artist:4kSGbjWGxTchKpIxXPJv0B")
            XCTAssertEqual(artist.id, "4kSGbjWGxTchKpIxXPJv0B")
            XCTAssertEqual(artist.type, .artist)
            if let externalURLs = artist.externalURLs {
                XCTAssertEqual(
                    externalURLs["spotify"],
                    URL(string: "https://open.spotify.com/artist/4kSGbjWGxTchKpIxXPJv0B")!,
                    "\(externalURLs)"
                )
            }
            else {
                XCTFail("externalURLs should not be nil")
            }
        }
        else {
            XCTFail(
                "artists should not be nil or empty: \(album.artists as Any)"
            )
        }
        
        
        // MARK: Check Tracks
        if let tracks = album.tracks?.items {
            for track in tracks {
                XCTAssertEqual(track.artists?.first?.name, "Crumb")
                XCTAssertEqual(
                    track.artists?.first?.uri,
                    "spotify:artist:4kSGbjWGxTchKpIxXPJv0B"
                )
            }
            XCTAssertEqual(tracks[0].name, "Cracking")
            XCTAssertEqual(tracks[0].uri, "spotify:track:4A4RgEk7hEFKwk9IUKdB8a")
            XCTAssertEqual(tracks[1].name, "Nina")
            XCTAssertEqual(tracks[1].uri, "spotify:track:6pMNKv4Ad6gSsoKGA4fkct")
            XCTAssertEqual(tracks[2].name, "Ghostride")
            XCTAssertEqual(tracks[2].uri, "spotify:track:476QHG5G8xxNI9VHTBFfjp")
            XCTAssertEqual(tracks[3].name, "Fall Down")
            XCTAssertEqual(tracks[3].uri, "spotify:track:6IqcbrxCPlbXaQuNoQMB8v")
            XCTAssertEqual(tracks[4].name, "M.R.")
            XCTAssertEqual(tracks[4].uri, "spotify:track:0GDHyRVlxRVxofJfrw3aVF")
            XCTAssertEqual(tracks[5].name, "The Letter")
            XCTAssertEqual(tracks[5].uri, "spotify:track:0UUP7ADHBTUMbDw31mcZPZ")
            XCTAssertEqual(tracks[6].name, "Part III")
            XCTAssertEqual(tracks[6].uri, "spotify:track:4HDLmWf73mge8isanCASnU")
            XCTAssertEqual(tracks[7].name, "And It Never Ends")
            XCTAssertEqual(tracks[7].uri, "spotify:track:00kOafrPnrR7jQhxYYg777")
            XCTAssertEqual(tracks[8].name, "Faces")
            XCTAssertEqual(tracks[8].uri, "spotify:track:1u7LOyLuApChbPeqMfXFKC")
            XCTAssertEqual(tracks[9].name, "Jinx")
            XCTAssertEqual(tracks[9].uri, "spotify:track:7qAy6TR1MrSeUV8OpMlNS1")
        }
        else {
            XCTFail("tracks shouldn't be nil")
        }
        
        // MARK: Check Images
        XCTAssertImagesExist(album.images, assertSizeNotNil: true)
    }
    
    func albumJinx() {
        
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

        let expectation = XCTestExpectation(description: "testAlbum")
        
        Self.spotify.authorizationManager.setExpirationDate(to: Date())

        Self.spotify.album(URIs.Albums.jinx)
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveJinxAlbum(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(
            for: [
                expectation,
                authorizationManagerDidChangeExpectation
            ],
            timeout: 60
        )
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 1,
                "authorizationManagerDidChange should emit exactly once"
            )
        }
        
    }
   
    func albums() {

        func receiveAlbums(_ albums: [Album?]) {

            if let jinxAlbum = albums[0] {
                receiveJinxAlbum(jinxAlbum)
            }
            else {
                XCTFail("jinx album should not be nil")
            }
            
            for album in albums {
                encodeDecode(album)
            }
            
            guard albums.count == 4 else {
                XCTFail("should've received 4 albums (got \(albums.count)")
                return
            }
            
            XCTAssertNil(albums[2])
            
            XCTAssertEqual(albums[0]?.name, "Jinx")
            
            
            XCTAssertEqual(albums[1]?.name, "Locket")
            XCTAssertEqual(albums[3]?.name, "Meddle")
            
            XCTAssertEqual(albums[0]?.tracks?.items.count, 10)
            XCTAssertEqual(albums[1]?.tracks?.items.count, 4)
            XCTAssertEqual(albums[3]?.tracks?.items.count, 6)
            
            if let releaseDate = albums[0]?.releaseDate {
                XCTAssertEqual(
                    releaseDate.timeIntervalSince1970,
                    1560470400,
                    accuracy: 43_200
                )
            }
            else {
                XCTFail("release date should not be nil")
            }
            if let releaseDate = albums[1]?.releaseDate {
                XCTAssertEqual(
                    releaseDate.timeIntervalSince1970,
                    1498176000,
                    accuracy: 43_200
                )
            }
            else {
                XCTFail("release date should not be nil")
            }
            if let releaseDate = albums[3]?.releaseDate {
                XCTAssertEqual(
                    releaseDate.timeIntervalSince1970,
                    58665600,
                    accuracy: 43_200
                )
            }
            else {
                XCTFail("release date should not be nil")
            }
            
        }
        
        let expectation = XCTestExpectation(description: "testAlbums")
        
        let albums: [SpotifyURIConvertible] = [
            URIs.Albums.jinx,
            URIs.Albums.locket,
            "spotify:album:invaliduri",
            URIs.Albums.meddle
        ]
        
        Self.spotify.albums(albums)
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveAlbums(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
    }
    
    /// Use the combine operator to extend pages
    func theLongestAlbumTracks() {
        
        let internalQueue = DispatchQueue(
            label: "theLongestAlbumTracks internal"
        )
        
        var receiveAlbumTracksPage1CalledCount = 0
        var receiveAlbumTracksPage2CalledCount = 0
        var receiveAlbumTracksPage3CalledCount = 0
        
        let albumTracksOffsetExpectation = XCTestExpectation(
            description: "album tracks offset"
        )
        
        Self.spotify.albumTracks(URIs.Albums.longestAlbum, limit: 50)
            .XCTAssertNoFailure()
            .flatMap { albumTracks -> AnyPublisher<PagingObject<Track>, Error> in
                self.receiveAlbumTracksPage1(albumTracks)
                internalQueue.sync {
                    receiveAlbumTracksPage1CalledCount += 1
                }
                return Self.spotify.albumTracks(
                    URIs.Albums.longestAlbum, limit: 50, offset: 50
                )
            }
            .XCTAssertNoFailure()
            .flatMap { albumTracks -> AnyPublisher<PagingObject<Track>, Error> in
                self.receiveAlbumTracksPage2(albumTracks)
                internalQueue.sync {
                    receiveAlbumTracksPage2CalledCount += 1
                }
                return Self.spotify.albumTracks(
                    URIs.Albums.longestAlbum, limit: 50, offset: 100
                )
            }
            .XCTAssertNoFailure()
            .flatMap { albumTracks -> AnyPublisher<PagingObject<Track>, Error> in
                self.receiveAlbumTracksPage3(albumTracks)
                internalQueue.sync {
                    receiveAlbumTracksPage3CalledCount += 1
                }
                guard let previous = albumTracks.previous else {
                    return SpotifyGeneralError.other(
                        "third page of results should have prevous href"
                    )
                    .anyFailingPublisher()
                }
                return Self.spotify.getFromHref(
                    previous,
                    responseType: PagingObject<Track>.self
                )
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in
                    albumTracksOffsetExpectation.fulfill()
                },
                receiveValue: { tracks in
                    self.receiveAlbumTracksPage2(tracks)
                    internalQueue.sync {
                        receiveAlbumTracksPage2CalledCount += 1
                    }
                }
            )
            .store(in: &Self.cancellables)
        
        
        var currentPage: Int? = 1
        var receivedPages = 0
        
        var currentPageHref: Int? = 1
        var receivedPagesHref = 0
        
        let albumTracksExtendPagesExpectation = XCTestExpectation(
            description: "album tracks extend pages"
        )
        
        Self.spotify.albumTracks(URIs.Albums.longestAlbum, limit: 50)
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .flatMap { albumTracks -> AnyPublisher<PagingObject<Track>, Error> in
                print(
                    "\nalbumTracks FLATMAP receiveValue: " +
                    "offset: \(albumTracks.offset)\n"
                )
                receivedPages += 1
                if currentPage == 1 {
                    XCTAssertEqual(
                        albumTracks.offset, 0,
                        "first page should be received first"
                    )
                    XCTAssertEqual(receivedPages, 1)
                    currentPage = 2
                    self.receiveAlbumTracksPage1(albumTracks)
                    internalQueue.sync {
                        receiveAlbumTracksPage1CalledCount += 1
                    }
                }
                else if currentPage == 2 {
                    XCTAssertEqual(
                        albumTracks.offset, 50,
                        "second page should be received second"
                    )
                    XCTAssertEqual(receivedPages, 2)
                    currentPage = 3
                    self.receiveAlbumTracksPage2(albumTracks)
                    internalQueue.sync {
                        receiveAlbumTracksPage2CalledCount += 1
                    }
                }
                else if currentPage == 3 {
                    XCTAssertEqual(
                        albumTracks.offset, 100,
                        "third page should be received third"
                    )
                    XCTAssertEqual(receivedPages, 3)
                    currentPage = nil
                    self.receiveAlbumTracksPage3(albumTracks)
                    internalQueue.sync {
                        receiveAlbumTracksPage3CalledCount += 1
                    }
                }
                else {
                    XCTFail(
                        "current page should be 1, 2, or 3, " +
                        "not \(currentPage as Any)"
                    )
                }
                return Self.spotify.getFromHref(
                    albumTracks.href,
                    responseType: PagingObject<Track>.self
                )
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in
                    print("\nfullfilling expectationExtendPages\n")
                    albumTracksExtendPagesExpectation.fulfill()
                },
                receiveValue: { albumTracks in
                    print(
                        "\nalbumTracks SINK receiveValue: " +
                        "offset: \(albumTracks.offset)\n"
                    )
                    receivedPagesHref += 1
                    if currentPageHref == 1 {
                        XCTAssertEqual(
                            albumTracks.offset, 0,
                            "first page should be received first"
                        )
                        XCTAssertEqual(receivedPagesHref, 1)
                        currentPageHref = 2
                        self.receiveAlbumTracksPage1(albumTracks)
                        internalQueue.sync {
                            receiveAlbumTracksPage1CalledCount += 1
                        }
                    }
                    else if currentPageHref == 2 {
                        XCTAssertEqual(
                            albumTracks.offset, 50,
                            "second page should be received second"
                        )
                        XCTAssertEqual(receivedPagesHref, 2)
                        currentPageHref = 3
                        self.receiveAlbumTracksPage2(albumTracks)
                        internalQueue.sync {
                            receiveAlbumTracksPage2CalledCount += 1
                        }
                    }
                    else if currentPageHref == 3 {
                        XCTAssertEqual(
                            albumTracks.offset, 100,
                            "third page should be received third"
                        )
                        XCTAssertEqual(receivedPagesHref, 3)
                        currentPageHref = nil
                        self.receiveAlbumTracksPage3(albumTracks)
                        internalQueue.sync {
                            receiveAlbumTracksPage3CalledCount += 1
                        }
                    }
                    else {
                        XCTFail(
                            "current page should be 1, 2, or 3, " +
                            "not \(currentPageHref as Any)"
                        )
                    }
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(
            for: [
                albumTracksOffsetExpectation,
                albumTracksExtendPagesExpectation
            ],
            timeout: 500
        )
        
        XCTAssertNil(currentPage)
        XCTAssertNil(currentPageHref)
        XCTAssertEqual(receivedPages, 3, "should've received 3 pages")
        XCTAssertEqual(receivedPagesHref, 3, "should've received 3 pages")
        XCTAssertEqual(receiveAlbumTracksPage1CalledCount, 3)
        XCTAssertEqual(receiveAlbumTracksPage2CalledCount, 4)
        XCTAssertEqual(receiveAlbumTracksPage3CalledCount, 3)
            
    }

    /// Use `SpotifyAPI.extendPages(_:maxExtraPages:)`.
    func theLongestAlbumTracks2() {
        
        let expectation = XCTestExpectation(
            description: "theLongestAlbumTracks2"
        )
        
        var receivedPages = 0
        var currentPage = 0

        Self.spotify.albumTracks(URIs.Albums.longestAlbum, limit: 50)
            .XCTAssertNoFailure()
            .flatMap { firstPage -> AnyPublisher<PagingObject<Track>, Error> in
                receivedPages += 1
                self.receiveAlbumTracksPage1(firstPage)
                return Self.spotify.extendPages(firstPage, maxExtraPages: 1)
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { page in
                    receivedPages += 1
                    currentPage += 1
                    switch currentPage {
                        case 1:
                            self.receiveAlbumTracksPage1(page)
                        case 2:
                            self.receiveAlbumTracksPage2(page)
                        default:
                            XCTFail("unexpected page: \(currentPage)")
                    }
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 300)
        
        XCTAssertEqual(currentPage, 2)
        XCTAssertEqual(receivedPages, 3)

    }

    func theLongestAlbumTracksConcurrent() {
        
        #if canImport(Combine)

        let internalQueue = DispatchQueue(
            label: "theLongestAlbumTracksConcurrent internal"
        )
        
        let expectation = XCTestExpectation(
            description: "album tracks extend pages concurrent"
        )
        
        var receivePage1Count = 0
        var receivePage2Count = 0
        var receivePage3Count = 0

        Self.spotify.albumTracks(URIs.Albums.longestAlbum, limit: 50)
            .XCTAssertNoFailure()
            .extendPagesConcurrently(Self.spotify)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { page in
                    switch page.estimatedIndex + 1 {
                        case 1:
                            self.receiveAlbumTracksPage1(page)
                            internalQueue.sync {
                                receivePage1Count += 1
                            }
                        case 2:
                            self.receiveAlbumTracksPage2(page)
                            internalQueue.sync {
                                receivePage2Count += 1
                            }
                        case 3:
                            self.receiveAlbumTracksPage3(page)
                            internalQueue.sync {
                                receivePage3Count += 1
                            }
                        default:
                            XCTFail(
                                "unexpected page: \(page.estimatedIndex + 1); " +
                                "offset: \(page.offset)"
                            )
                    }
                }
            )
            .store(in: &Self.cancellables)
        
        
        self.wait(
            for: [expectation],
            timeout: 300
        )
        
        XCTAssertEqual(receivePage1Count, 1)
        XCTAssertEqual(receivePage2Count, 1)
        XCTAssertEqual(receivePage3Count, 1)
        
        #endif
            
    }
    
    func theLongestAlbumTracksConcurrent2() {
        
        #if canImport(Combine)

        let internalQueue = DispatchQueue(
            label: "theLongestAlbumTracksConcurrent2 internal"
        )
        
        let expectation = XCTestExpectation(
            description: "album tracks extend pages concurrent 2"
        )
        
        var receivePage1Count = 0
        var receivePage2Count = 0

        Self.spotify.albumTracks(URIs.Albums.longestAlbum, limit: 50)
            .XCTAssertNoFailure()
            .flatMap { firstPage -> AnyPublisher<PagingObject<Track>, Error> in
                receivePage1Count += 1
                self.receiveAlbumTracksPage1(firstPage)
                return Self.spotify.extendPagesConcurrently(
                    firstPage, maxExtraPages: 1
                )
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { page in
                    switch page.estimatedIndex + 1 {
                        case 1:
                            self.receiveAlbumTracksPage1(page)
                            internalQueue.sync {
                                receivePage1Count += 1
                            }
                        case 2:
                            self.receiveAlbumTracksPage2(page)
                            internalQueue.sync {
                                receivePage2Count += 1
                            }
                        default:
                            XCTFail(
                                "unexpected page: \(page.estimatedIndex + 1); " +
                                "offset: \(page.offset)"
                            )
                    }
                }
            )
            .store(in: &Self.cancellables)
        
        
        self.wait(
            for: [expectation],
            timeout: 300
        )

        XCTAssertEqual(receivePage1Count, 2)
        XCTAssertEqual(receivePage2Count, 1)
        
        #endif
            
    }
    
    func theLongestAlbumTracksCollect() {
        
        #if canImport(Combine)

        let queue = DispatchQueue(
            label: "theLongestAlbumTracksCollect"
        )

        let expectation = XCTestExpectation(
            description: "theLongestAlbumTracksCollect"
        )

        var receivedPages = 0

        let album = URIs.Albums.longestAlbum

        Self.spotify.albumTracks(album, limit: 20)
            .XCTAssertNoFailure()
            .extendPagesConcurrently(Self.spotify)
            .handleEvents(receiveOutput: { _ in
                queue.sync {
                    receivedPages += 1
                }
            })
            .XCTAssertNoFailure()
            .collectAndSortByOffset()
            .sink(
                receiveCompletion: { completion in
                    expectation.fulfill()
                },
                receiveValue: { tracks in
                    XCTAssertEqual(tracks.count, 125)
                    guard tracks.count >= 125 else {
                        return
                    }
                    let firstPage = Array(tracks[0..<50])
                    self.checkTracksPage1(firstPage)
                    
                    let secondPage = Array(tracks[50..<100])
                    self.checkTracksPage2(secondPage)
                    
                    let thirdPage = Array(tracks[100..<125])
                    self.checkTracksPage3(thirdPage)
                    
                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)
        queue.sync {
            XCTAssertEqual(receivedPages, 7)
        }
        
        #endif

    }
    
    func receiveAlbumTracksPage1(_ page: PagingObject<Track>) {
        print("begin receiveAlbumTracksPage1")
        
        encodeDecode(page)
        for track in page.items {
            encodeDecode(track)
        }
        
        XCTAssertEqual(page.estimatedIndex, 0)
        XCTAssertEqual(page.estimatedTotalPages, 3)
        XCTAssertEqual(page.limit, 50)
        XCTAssertEqual(page.total, 125)
        XCTAssertNil(page.previous)
        XCTAssertNotNil(page.next)
        XCTAssertEqual(page.offset, 0)
        
        XCTAssertNotNil(page.next)
        
        let tracks = page.items
        self.checkTracksPage1(tracks)
        
        print("end receiveAlbumTracksPage1")
        
    }
    
    func receiveAlbumTracksPage2(_ page: PagingObject<Track>) {
        print("begin receiveAlbumTracksPage2")
        
        encodeDecode(page)
        
        XCTAssertEqual(page.estimatedIndex, 1)
        XCTAssertEqual(page.estimatedTotalPages, 3)
        XCTAssertEqual(page.limit, 50)
        XCTAssertEqual(page.total, 125)
        XCTAssertNotNil(page.next)
        XCTAssertNotNil(page.next)
        XCTAssertNotNil(page.previous)
        XCTAssertNotNil(page.previous)
        XCTAssertEqual(page.offset, 50)
        
        let tracks = page.items
        self.checkTracksPage2(tracks)
        print("end receiveAlbumTracksPage2")
        
    }
    
    func receiveAlbumTracksPage3(_ page: PagingObject<Track>) {
        print("begin receiveAlbumTracksPage3")
        
        encodeDecode(page)
        
        XCTAssertEqual(page.estimatedIndex, 2)
        XCTAssertEqual(page.estimatedTotalPages, 3)
        
        XCTAssertEqual(page.limit, 50)
        XCTAssertEqual(page.total, 125)
        XCTAssertNotNil(page.previous)
        XCTAssertNotNil(page.previous)
        XCTAssertNil(page.next)
        XCTAssertEqual(page.offset, 100)
        
        
        let tracks = page.items
        self.checkTracksPage3(tracks)
        print("end receiveAlbumTracksPage3")
        
    }
    
    func checkTracksPage1(_ tracks: [Track]) {
        XCTAssertEqual(tracks.count, 50)
        if tracks.count < 50 { return }
        
        XCTAssertEqual(tracks[0].name, "Maski Dolu")
        XCTAssertEqual(tracks[1].name, "Chista Ludost")
        XCTAssertEqual(tracks[2].name, "Mystery - Dian Solo Mix")
        XCTAssertEqual(tracks[3].name, "Leten Kadar")
        XCTAssertEqual(tracks[4].name, "Niama Ne")
        XCTAssertEqual(tracks[5].name, "DJ Take Me Away")
        XCTAssertEqual(tracks[6].name, "I Love My DJ")
        XCTAssertEqual(tracks[7].name, "Magnit")
        XCTAssertEqual(tracks[8].name, "Biagstvo")
        XCTAssertEqual(tracks[9].name, "Zig Zag - BG Version")
        XCTAssertEqual(tracks[10].name, "Ela Izgrei")
        XCTAssertEqual(tracks[11].name, "Viarvam v Teb")
        XCTAssertEqual(tracks[12].name, "Hazard")
        XCTAssertEqual(tracks[13].name, "Suzdadeni Edin Za Drug")
        XCTAssertEqual(tracks[14].name, "I Feel Like")
        XCTAssertEqual(tracks[15].name, "Bez Kofein")
        XCTAssertEqual(tracks[16].name, "Nikoi drug")
        XCTAssertEqual(tracks[17].name, "Funk You")
        XCTAssertEqual(tracks[18].name, "Iskam da te imam")
        XCTAssertEqual(tracks[19].name, "Addicted to You")
        XCTAssertEqual(tracks[20].name, "Az i Ti")
        XCTAssertEqual(tracks[21].name, "Neka Silata Bude s Nas")
        XCTAssertEqual(tracks[22].name, "Az i Ti - Trap Mix")
        XCTAssertEqual(tracks[23].name, "Deeper & Stronger")
        XCTAssertEqual(tracks[24].name, "Nevidim - Remix")
        XCTAssertEqual(tracks[25].name, "Mai Se Napravihme")
        XCTAssertEqual(tracks[26].name, "Samo s teb")
        XCTAssertEqual(tracks[27].name, "Beyond the Universe - Club Mix")
        XCTAssertEqual(tracks[28].name, "Rise Again - Dian Solo Mix")
        XCTAssertEqual(tracks[29].name, "Do Kraia")
        XCTAssertEqual(tracks[30].name, "Welcome to the Loop")
        XCTAssertEqual(tracks[31].name, "Pochivni dni - Club Mix")
        XCTAssertEqual(tracks[32].name, "Niakoga Predi - Remix")
        XCTAssertEqual(tracks[33].name, "Arrogance Lifestyle (Part. 2)")
        XCTAssertEqual(tracks[34].name, "Cry for You")
        XCTAssertEqual(tracks[35].name, "Feel It")
        XCTAssertEqual(tracks[36].name, "Lesno se vyzbujdam")
        XCTAssertEqual(tracks[37].name, "Lonely")
        XCTAssertEqual(tracks[38].name, "May the Music Be with You - Dian Solo Dub Mix")
        XCTAssertEqual(tracks[39].name, "Say My Name - Armada Version")
        XCTAssertEqual(tracks[40].name, "Nikoi - Remix")
        XCTAssertEqual(tracks[41].name, "Piasuk Ot Zlato")
        XCTAssertEqual(tracks[42].name, "Alone")
        XCTAssertEqual(tracks[43].name, "Tova E Hit")
        XCTAssertEqual(tracks[44].name, "Den Sled Den")
        XCTAssertEqual(tracks[45].name, "Jelaya")
        XCTAssertEqual(tracks[46].name, "I Zamirisva Na More - Remix")
        XCTAssertEqual(tracks[47].name, "Sbogom Moia Lyubov - Club Mix")
        XCTAssertEqual(tracks[48].name, "Change the World")
        XCTAssertEqual(tracks[49].name, "Space Cowboy - Dian Solo Mix")
    }
    
    func checkTracksPage2(_ tracks: [Track]) {
        XCTAssertEqual(tracks.count, 50)
        if tracks.count < 50 { return }
        
        XCTAssertEqual(tracks[0].name, "One More Time - Dian Solo Version")
        XCTAssertEqual(tracks[1].name, "Ethnika - Club Mix")
        XCTAssertEqual(tracks[2].name, "Moon Landing - Angry Outsider - Club Mix")
        XCTAssertEqual(tracks[3].name, "My Love")
        XCTAssertEqual(tracks[4].name, "Piano Fantasia")
        XCTAssertEqual(tracks[5].name, "Please Don't Go")
        XCTAssertEqual(tracks[6].name, "Dve sledi")
        XCTAssertEqual(tracks[7].name, "Vsiaka Nedelia")
        XCTAssertEqual(tracks[8].name, "Daniela 2012 - Dian Solo Rework")
        XCTAssertEqual(tracks[9].name, "Vlizam v teb - Club Mix")
        XCTAssertEqual(tracks[10].name, "I Feel Like I Am")
        XCTAssertEqual(tracks[11].name, "Spasenie - Club Mix")
        XCTAssertEqual(tracks[12].name, "Vsichko e lyubov")
        XCTAssertEqual(tracks[13].name, "Mystika")
        XCTAssertEqual(tracks[14].name, "Kumcho Vulcho - Club Mix")
        XCTAssertEqual(tracks[15].name, "Sexy producent")
        XCTAssertEqual(tracks[16].name, "Znak Za Lyubov")
        XCTAssertEqual(tracks[17].name, "Detstvo Moe - Club Mix")
        XCTAssertEqual(tracks[18].name, "Bosa po asvalta - Club Mix")
        XCTAssertEqual(tracks[19].name, "Edna Bulgarska Roza - Club Mix")
        XCTAssertEqual(tracks[20].name, "Bogatstvo - Club Mix")
        XCTAssertEqual(tracks[21].name, "Bulgari Napred - Club Mix")
        XCTAssertEqual(tracks[22].name, "Nashia Signal")
        XCTAssertEqual(tracks[23].name, "Clap Your Hands")
        XCTAssertEqual(tracks[24].name, "Magic")
        XCTAssertEqual(tracks[25].name, "Arrogance Life Style 1")
        XCTAssertEqual(tracks[26].name, "Izvikai silno")
        XCTAssertEqual(tracks[27].name, "On Fire")
        XCTAssertEqual(tracks[28].name, "Slave")
        XCTAssertEqual(tracks[29].name, "Vyrni se")
        XCTAssertEqual(tracks[30].name, "Welcome To The Deep Zone")
        XCTAssertEqual(tracks[31].name, "Zvezden Grad")
        XCTAssertEqual(tracks[32].name, "Made for Loving You - Radio Mix")
        XCTAssertEqual(tracks[33].name, "Liatoto Doide")
        XCTAssertEqual(tracks[34].name, "Play")
        XCTAssertEqual(tracks[35].name, "Walking People - Short Version")
        XCTAssertEqual(tracks[36].name, "Dark Side - EDM Mix")
        XCTAssertEqual(tracks[37].name, "Chance to Love You - Juratone Version")
        XCTAssertEqual(tracks[38].name, "Az sum tuk - Remix")
        XCTAssertEqual(tracks[39].name, "Dama Na Bezbroi Muje - Jazzy Mix")
        XCTAssertEqual(tracks[40].name, "Nov Jivot")
        XCTAssertEqual(tracks[41].name, "Svetut E Za Dvama - Club Mix")
        XCTAssertEqual(tracks[42].name, "I Feel")
        XCTAssertEqual(tracks[43].name, "Obeshtai Mi Lyubov")
        XCTAssertEqual(tracks[44].name, "Water - Remix")
        XCTAssertEqual(tracks[45].name, "Ledeno Kafe")
        XCTAssertEqual(tracks[46].name, "Up 2 the Sky")
        XCTAssertEqual(tracks[47].name, "Varviat li dvama - Club Mix")
        XCTAssertEqual(tracks[48].name, "Budi zvezda - Club Mix")
        XCTAssertEqual(tracks[49].name, "Fresh")

    }
    
    func checkTracksPage3(_ tracks: [Track]) {
        XCTAssertEqual(tracks.count, 25)
        if tracks.count < 25 { return }

        XCTAssertEqual(tracks[0].name, "Tazi Nosht")
        XCTAssertEqual(tracks[1].name, "X-Perience")
        XCTAssertEqual(tracks[2].name, "Tancuvam na volia")
        XCTAssertEqual(tracks[3].name, "I'm Not Right")
        XCTAssertEqual(tracks[4].name, "Waiting 4 You")
        XCTAssertEqual(tracks[5].name, "Celuvka Za Sbogom - Club Mix")
        XCTAssertEqual(tracks[6].name, "Sunny Days - Juratone Version")
        XCTAssertEqual(tracks[7].name, "Prerodena - Extended Version")
        XCTAssertEqual(tracks[8].name, "Terminal 2 - Balkan Mix")
        XCTAssertEqual(tracks[9].name, "As Long as I Have You - Juratone Version")
        XCTAssertEqual(tracks[10].name, "Na Ryba Na Ludostta - Extended Mix")
        XCTAssertEqual(tracks[11].name, "Another Dimension - Dian Solo Mix")
        XCTAssertEqual(tracks[12].name, "Let's Get Down")
        XCTAssertEqual(tracks[13].name, "Zalojnik Na Dansinga - Club Mix")
        XCTAssertEqual(tracks[14].name, "Tancuvam s Viatura - Club Mix")
        XCTAssertEqual(tracks[15].name, "Funky Bass & Strings")
        XCTAssertEqual(tracks[16].name, "Izpii Me")
        XCTAssertEqual(tracks[17].name, "The Dance of the World")
        XCTAssertEqual(tracks[18].name, "Suck My Jackpot")
        XCTAssertEqual(tracks[19].name, "Vechnata taina")
        XCTAssertEqual(tracks[20].name, "Viarvai")
        XCTAssertEqual(tracks[21].name, "I'll Not Forget You - Juratone Version")
        XCTAssertEqual(tracks[22].name, "Drama Queen - Radio Mix")
        XCTAssertEqual(tracks[23].name, "Maski Dolu - Club Remix")
        XCTAssertEqual(tracks[24].name, "Jore Dos - Club Mix")
        
    }

}

final class SpotifyAPIClientCredentialsFlowAlbumsTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIAlbumsTests
{

    static let allTests = [
        ("testAlbumJinx", testAlbumJinx),
        ("testAlbums", testAlbums),
        ("testTheLongestAlbumTracks", testTheLongestAlbumTracks),
        ("testTheLongestAlbumTracks2", testTheLongestAlbumTracks2),
        (
            "testTheLongestAlbumTracksConcurrent",
            testTheLongestAlbumTracksConcurrent
        ),
        (
            "testTheLongestAlbumTracksConcurrent2",
            testTheLongestAlbumTracksConcurrent2
        ),
        (
            "testTheLongestAlbumTracksCollect",
            testTheLongestAlbumTracksCollect
        )
    ]

    func testAlbumJinx() { albumJinx() }
    func testAlbums() { albums() }
    func testTheLongestAlbumTracks() { theLongestAlbumTracks() }
    func testTheLongestAlbumTracks2() { theLongestAlbumTracks2() }
    func testTheLongestAlbumTracksConcurrent() { theLongestAlbumTracksConcurrent() }
    func testTheLongestAlbumTracksConcurrent2() { theLongestAlbumTracksConcurrent2() }
    func testTheLongestAlbumTracksCollect() {
        theLongestAlbumTracksCollect()
    }

}

final class SpotifyAPIAuthorizationCodeFlowAlbumsTests:
        SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIAlbumsTests
{

    static let allTests = [
        ("testAlbumJinx", testAlbumJinx),
        ("testAlbums", testAlbums),
        ("testTheLongestAlbumTracks", testTheLongestAlbumTracks),
        ("testTheLongestAlbumTracks2", testTheLongestAlbumTracks2),
        (
            "testTheLongestAlbumTracksConcurrent",
            testTheLongestAlbumTracksConcurrent
        ),
        (
            "testTheLongestAlbumTracksConcurrent2",
            testTheLongestAlbumTracksConcurrent2
        ),
        (
            "testTheLongestAlbumTracksCollect",
            testTheLongestAlbumTracksCollect
        )
    ]

    func testAlbumJinx() { albumJinx() }
    func testAlbums() { albums() }
    func testTheLongestAlbumTracks() { theLongestAlbumTracks() }
    func testTheLongestAlbumTracks2() { theLongestAlbumTracks2() }
    func testTheLongestAlbumTracksConcurrent() { theLongestAlbumTracksConcurrent() }
    func testTheLongestAlbumTracksConcurrent2() { theLongestAlbumTracksConcurrent2() }
    func testTheLongestAlbumTracksCollect() {
        theLongestAlbumTracksCollect()
    }

}

final class SpotifyAPIAuthorizationCodeFlowPKCEAlbumsTests:
        SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIAlbumsTests
{

    static let allTests = [
        ("testAlbumJinx", testAlbumJinx),
        ("testAlbums", testAlbums),
        ("testTheLongestAlbumTracks", testTheLongestAlbumTracks),
        ("testTheLongestAlbumTracks2", testTheLongestAlbumTracks2),
        (
            "testTheLongestAlbumTracksConcurrent",
            testTheLongestAlbumTracksConcurrent
        ),
        (
            "testTheLongestAlbumTracksConcurrent2",
            testTheLongestAlbumTracksConcurrent2
        ),
        (
            "testTheLongestAlbumTracksCollect",
            testTheLongestAlbumTracksCollect
        )
    ]

    func testAlbumJinx() { albumJinx() }
    func testAlbums() { albums() }
    func testTheLongestAlbumTracks() { theLongestAlbumTracks() }
    func testTheLongestAlbumTracks2() { theLongestAlbumTracks2() }
    func testTheLongestAlbumTracksConcurrent() { theLongestAlbumTracksConcurrent() }
    func testTheLongestAlbumTracksConcurrent2() { theLongestAlbumTracksConcurrent2() }
    func testTheLongestAlbumTracksCollect() {
        theLongestAlbumTracksCollect()
    }

}
