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
            "https://api.spotify.com/v1/albums/3vukTUpiENDHDoYTVrwqtz"
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
                "https://open.spotify.com/album/3vukTUpiENDHDoYTVrwqtz",
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
                "https://api.spotify.com/v1/artists/4kSGbjWGxTchKpIxXPJv0B"
            )
            XCTAssertEqual(artist.uri, "spotify:artist:4kSGbjWGxTchKpIxXPJv0B")
            XCTAssertEqual(artist.id, "4kSGbjWGxTchKpIxXPJv0B")
            XCTAssertEqual(artist.type, .artist)
            if let externalURLs = artist.externalURLs {
                XCTAssertEqual(
                    externalURLs["spotify"],
                    "https://open.spotify.com/artist/4kSGbjWGxTchKpIxXPJv0B",
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
        if let images = album.images {
            var imageExpectations: [XCTestExpectation] = []
            for (i, image) in images.enumerated() {
                XCTAssertNotNil(image.height)
                XCTAssertNotNil(image.width)
                guard let url = URL(string: image.url) else {
                    XCTFail("couldn't convert to URL: '\(image.url)'")
                    continue
                }
                let imageExpectation = XCTestExpectation(
                    description: "loadImage \(i)"
                )
                imageExpectations.append(imageExpectation)
                
                assertURLExists(url)
                    .sink(receiveCompletion: { _ in
                        imageExpectation.fulfill()
                    })
                    .store(in: &Self.cancellables)
            }
            
            print("waiting for \(imageExpectations.count) expectations")
            self.wait(for: imageExpectations, timeout: TimeInterval(60 * images.count))
            print("FINISHED waiting for image expectations")
        }
        else {
            XCTFail("images should not be nil")
        }

    }
    
    func albumJinx() {
        
        Self.spotify.authorizationManager.setExpirationDate(to: Date())
        
        var authChangeCount = 0
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            authChangeCount += 1
        })
        .store(in: &Self.cancellables)

        let expectation = XCTestExpectation(description: "testAlbum")
        
        Self.spotify.album(URIs.Albums.jinx)
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveJinxAlbum(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 60)
        XCTAssertEqual(
            authChangeCount, 1,
            "authorizationManagerDidChange should emit exactly once"
        )
        
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
    
    func theLongestAlbumTracks() {
        
        let internalQueue = DispatchQueue(
            label: "theLongestAlbumTracks internal"
        )
        
        var receiveAlbumTracksPage1CalledCount = 0
        var receiveAlbumTracksPage2CalledCount = 0
        var receiveAlbumTracksPage3CalledCount = 0
        
        func main() {
            
            let albumTracksOffsetExpectation = XCTestExpectation(
                description: "album tracks offset"
            )
            
            Self.spotify.albumTracks(URIs.Albums.longestAlbum, limit: 50)
                .XCTAssertNoFailure()
                .flatMap { albumTracks -> AnyPublisher<PagingObject<Track>, Error> in
                    receiveAlbumTracksPage1(albumTracks)
                    return Self.spotify.albumTracks(
                        URIs.Albums.longestAlbum, limit: 50, offset: 50
                    )
                }
                .XCTAssertNoFailure()
                .flatMap { albumTracks -> AnyPublisher<PagingObject<Track>, Error> in
                    receiveAlbumTracksPage2(albumTracks)
                    return Self.spotify.albumTracks(
                        URIs.Albums.longestAlbum, limit: 50, offset: 100
                    )
                }
                .XCTAssertNoFailure()
                .flatMap { albumTracks -> AnyPublisher<PagingObject<Track>, Error> in
                    receiveAlbumTracksPage3(albumTracks)
                    guard let previous = albumTracks.previous else {
                        return SpotifyLocalError.other(
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
                    receiveValue: receiveAlbumTracksPage2(_:)
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
                            "first page should be recieved first"
                        )
                        XCTAssertEqual(receivedPages, 1)
                        currentPage = 2
                        receiveAlbumTracksPage1(albumTracks)
                    }
                    else if currentPage == 2 {
                        XCTAssertEqual(
                            albumTracks.offset, 50,
                            "second page should be recieved second"
                        )
                        XCTAssertEqual(receivedPages, 2)
                        currentPage = 3
                        receiveAlbumTracksPage2(albumTracks)
                    }
                    else if currentPage == 3 {
                        XCTAssertEqual(
                            albumTracks.offset, 100,
                            "third page should be recieved third"
                        )
                        XCTAssertEqual(receivedPages, 3)
                        currentPage = nil
                        receiveAlbumTracksPage3(albumTracks)
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
                                "first page should be recieved first"
                            )
                            XCTAssertEqual(receivedPagesHref, 1)
                            currentPageHref = 2
                            receiveAlbumTracksPage1(albumTracks)
                        }
                        else if currentPageHref == 2 {
                            XCTAssertEqual(
                                albumTracks.offset, 50,
                                "second page should be recieved second"
                            )
                            XCTAssertEqual(receivedPagesHref, 2)
                            currentPageHref = 3
                            receiveAlbumTracksPage2(albumTracks)
                        }
                        else if currentPageHref == 3 {
                            XCTAssertEqual(
                                albumTracks.offset, 100,
                                "third page should be recieved third"
                            )
                            XCTAssertEqual(receivedPagesHref, 3)
                            currentPageHref = nil
                            receiveAlbumTracksPage3(albumTracks)
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
        
        func receiveAlbumTracksPage1(_ album: PagingObject<Track>) {
            print("begin receiveAlbumTracksPage1")
            
            encodeDecode(album)
            for track in album.items {
                encodeDecode(track)
            }
            
            XCTAssertEqual(album.estimatedTotalPages, 3)
            XCTAssertEqual(album.limit, 50)
            XCTAssertEqual(album.total, 125)
            XCTAssertNil(album.previous)
            XCTAssertNotNil(album.next)
            XCTAssertEqual(album.offset, 0)
            
            XCTAssertNotNil(URL(string: album.href))
            XCTAssertNotNil(album.next.map(URL.init(string:)))
            
            let tracks = album.items
            XCTAssertEqual(album.items.count, 50)
            if tracks.count < 50 { return }
            do {
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
            
            internalQueue.sync {
                receiveAlbumTracksPage1CalledCount += 1
            }
            print("end receiveAlbumTracksPage1")
            
        }
        
        func receiveAlbumTracksPage2(_ album: PagingObject<Track>) {
            print("begin receiveAlbumTracksPage2")
            
            encodeDecode(album)
            
            XCTAssertEqual(album.estimatedTotalPages, 3)
            XCTAssertEqual(album.limit, 50)
            XCTAssertEqual(album.total, 125)
            XCTAssertNotNil(album.next)
            XCTAssertNotNil(album.next.map(URL.init(string:)))
            XCTAssertNotNil(album.previous)
            XCTAssertNotNil(album.previous.map(URL.init(string:)))
            XCTAssertEqual(album.offset, 50)
            XCTAssertNotNil(URL(string: album.href))
            
            let tracks = album.items
            XCTAssertEqual(tracks.count, 50)
            if tracks.count < 50 { return }
            do {
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
                
                // XCTAssertEqual(tracks[<#I#>].name, "<#name#>")
                
            }
            
            internalQueue.sync {
                receiveAlbumTracksPage2CalledCount += 1
            }
            print("end receiveAlbumTracksPage2")
            
        }
        
        func receiveAlbumTracksPage3(_ album: PagingObject<Track>) {
            print("begin receiveAlbumTracksPage3")
            
            encodeDecode(album)
            
            XCTAssertEqual(album.estimatedTotalPages, 3)
            
            XCTAssertEqual(album.limit, 50)
            XCTAssertEqual(album.total, 125)
            XCTAssertNotNil(album.previous)
            XCTAssertNotNil(album.previous.map(URL.init(string:)))
            XCTAssertNil(album.next)
            XCTAssertEqual(album.offset, 100)
            XCTAssertNotNil(URL(string: album.href))
            
            
            let tracks = album.items
            XCTAssertEqual(tracks.count, 25)
            if tracks.count < 25 { return }
            
            do {
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
            
            internalQueue.sync {
                receiveAlbumTracksPage3CalledCount += 1
            }
            print("end receiveAlbumTracksPage3")
            
        }
        
        main()
        
    }

}

final class SpotifyAPIClientCredentialsFlowAlbumsTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIAlbumsTests
{

    static let allTests = [
        ("testAlbumJinx", testAlbumJinx),
        ("testAlbums", testAlbums),
        ("testTheLongestAlbumTracks", testTheLongestAlbumTracks)
    ]

    func testAlbumJinx() { albumJinx() }
    func testAlbums() { albums() }
    func testTheLongestAlbumTracks() { theLongestAlbumTracks() }

}

final class SpotifyAPIAuthorizationCodeFlowAlbumsTests:
        SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIAlbumsTests
{

    static let allTests = [
        ("testAlbumJinx", testAlbumJinx),
        ("testAlbums", testAlbums),
        ("testTheLongestAlbumTracks", testTheLongestAlbumTracks)
    ]

    func testAlbumJinx() { albumJinx() }
    func testAlbums() { albums() }
    func testTheLongestAlbumTracks() { theLongestAlbumTracks() }

}


final class SpotifyAPIAuthorizationCodeFlowPKCEAlbumsTests:
        SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIAlbumsTests
{

    static let allTests = [
        ("testAlbumJinx", testAlbumJinx),
        ("testAlbums", testAlbums),
        ("testTheLongestAlbumTracks", testTheLongestAlbumTracks)
    ]

    func testAlbumJinx() { albumJinx() }
    func testAlbums() { albums() }
    func testTheLongestAlbumTracks() { theLongestAlbumTracks() }

}

