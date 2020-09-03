import Foundation
import XCTest
import Combine
@testable import SpotifyWebAPI
import SpotifyContent

protocol SpotifyAPIAlbumsTests: SpotifyAPITests { }

extension SpotifyAPIAlbumsTests {

    func albumJinx() {
        
        func receiveAlbum(_ album: Album) {
            
            encodeDecode(album)
            
            XCTAssertEqual(album.name, "Jinx")
            XCTAssertEqual(album.tracks?.items.count, 10)
            XCTAssertEqual(album.tracks?.total, 10)
            XCTAssertEqual(album.label, "Crumb Records")
            XCTAssertEqual(album.type, .album)

            XCTAssert(
                album.releaseDate?.timeIntervalSince1970.isApproximatelyEqual(
                    to: 1560470400, absoluteTolerance: 60 * 60 * 12
                ) ?? false
            )
            XCTAssertEqual(album.releaseDatePrecision, "day")
            
            guard let tracks = album.tracks?.items else {
                XCTFail("tracks shouldn't be nil")
                return
            }
            for track in tracks {
                XCTAssertEqual(track.artists?.first?.name, "Crumb")
            }
            
            XCTAssertEqual(tracks[0].name, "Cracking")
            XCTAssertEqual(tracks[1].name, "Nina")
            XCTAssertEqual(tracks[2].name, "Ghostride")
            XCTAssertEqual(tracks[3].name, "Fall Down")
            XCTAssertEqual(tracks[4].name, "M.R.")
            XCTAssertEqual(tracks[5].name, "The Letter")
            XCTAssertEqual(tracks[6].name, "Part III")
            XCTAssertEqual(tracks[7].name, "And It Never Ends")
            XCTAssertEqual(tracks[8].name, "Faces")
            XCTAssertEqual(tracks[9].name, "Jinx")
            
        }
        
        let expectation = XCTestExpectation(description: "testAlbum")
        
        Self.spotify.album(URIs.Albums.jinx)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveAlbum(_:)
            )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 10)
        
    }
   
    func albums() {

        func receiveAlbums(_ albums: [Album?]) {

            for album in albums {
                guard let album = album else {
                    XCTFail("album shouldn't be nil")
                    continue
                }
                encodeDecode(album)
            }
            
            XCTAssertEqual(albums[0]?.name, "Jinx")
            XCTAssertEqual(albums[1]?.name, "Locket")
            XCTAssertEqual(albums[2]?.name, "Meddle")
            
            XCTAssertEqual(albums[0]?.tracks?.items.count, 10)
            XCTAssertEqual(albums[1]?.tracks?.items.count, 4)
            XCTAssertEqual(albums[2]?.tracks?.items.count, 6)
            
            XCTAssert(
                albums[0]?.releaseDate?.timeIntervalSince1970.isApproximatelyEqual(
                    to: 1560470400, absoluteTolerance: 60 * 60 * 12
                ) ?? false
            )
            XCTAssert(
                albums[1]?.releaseDate?.timeIntervalSince1970.isApproximatelyEqual(
                    to: 1498176000, absoluteTolerance: 60 * 60 * 12
                ) ?? false
            )
            XCTAssert(
                albums[2]?.releaseDate?.timeIntervalSince1970.isApproximatelyEqual(
                    to: 58665600, absoluteTolerance: 60 * 60 * 12
                ) ?? false
            )
        }
        
        let expectation = XCTestExpectation(description: "testAlbums")
        
        Self.spotify.albums(URIs.Albums.array(.jinx, .locket, .meddle))
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveAlbums(_:)
            )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 10)
        
    }
    
    func theLongestAlbumTracks() {
           
        let expectation = XCTestExpectation(
            description: "testTheLongestAlbumTracks"
        )
        
        let expectation2 = XCTestExpectation(
            description: "testTheLongestAlbumTracks2"
        )
        
        let expectation3 = XCTestExpectation(
            description: "testTheLongestAlbumTracks3"
        )
        
        func receiveAlbumTracks(_ album: PagingObject<Track>) {
            
            encodeDecode(album)
            
            let tracks = album.items
            if tracks.count < 50 {
                XCTFail("tracks count should be 50")
                return
            }
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
         
            Self.spotify.albumTracks(
                URIs.Albums.longestAlbum, limit: 50, offset: 50
            )
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation2.fulfill() },
                receiveValue: { secondAlbum in
                    receiveAlbumTracksPage2(firstAlbumPage: album, secondAlbumPage: secondAlbum)
                }
            )
            .store(in: &Self.cancellables)
        }
        
        func receiveAlbumTracksPage2(
            firstAlbumPage: PagingObject<Track>,
            secondAlbumPage: PagingObject<Track>
        ) {
            encodeDecode(secondAlbumPage)
            let tracks = secondAlbumPage.items
            XCTAssertEqual(tracks.count, 50)
            if tracks.count < 50 { return }
            do {
                XCTAssertEqual(tracks[0].name, "One More Time - Dian Solo Version")
                XCTAssertEqual(tracks[10].name, "I Feel Like I Am")
                XCTAssertEqual(tracks[20].name, "Bogatstvo - Club Mix")
                XCTAssertEqual(tracks[30].name, "Welcome To The Deep Zone")
                XCTAssertEqual(tracks[40].name, "Nov Jivot")
                XCTAssertEqual(tracks[49].name, "Fresh")
                
            }
            
            Self.spotify.albumTracks(
                URIs.Albums.longestAlbum, limit: 50, offset: 100
            )
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation3.fulfill() },
                receiveValue: receiveAlbumTracksPage3(_:)
            )
            .store(in: &Self.cancellables)
            

        }
        
        func receiveAlbumTracksPage3(_ album: PagingObject<Track>) {
            encodeDecode(album)
            let tracks = album.items
            XCTAssertEqual(tracks.count, 25)
            if tracks.count < 25 { return }
            do {
                XCTAssertEqual(tracks[0].name, "Tazi Nosht")
                XCTAssertEqual(tracks[10].name, "Na Ryba Na Ludostta - Extended Mix")
                XCTAssertEqual(tracks[20].name, "Viarvai")
                XCTAssertEqual(tracks[22].name, "Drama Queen - Radio Mix")
                XCTAssertEqual(tracks[23].name, "Maski Dolu - Club Remix")
                XCTAssertEqual(tracks[24].name, "Jore Dos - Club Mix")
                
            }

        }
           
       Self.spotify.albumTracks(URIs.Albums.longestAlbum, limit: 50)
           .XCTAssertNoFailure()
           .sink(
               receiveCompletion: { _ in expectation.fulfill() },
               receiveValue: receiveAlbumTracks(_:)
           )
           .store(in: &Self.cancellables)

       wait(for: [expectation, expectation2, expectation3], timeout: 10)
           
    }

}


class SpotifyAPIAuthorizationCodeFlowAlbumsTests:
        SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIAlbumsTests
{

    static let allTests = [
        ("testAlbum", testAlbum),
        ("testAlbums", testAlbums),
        ("testTheLongestAlbumTracks", testTheLongestAlbumTracks)
    ]
    
    func testAlbum() { albumJinx() }
    func testAlbums() { albums() }
    func testTheLongestAlbumTracks() { theLongestAlbumTracks() }

}

class SpotifyAPIClientCredentialsFlowAlbumsTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIAlbumsTests
{

    static let allTests = [
        ("testAlbum", testAlbum),
        ("testAlbums", testAlbums),
        ("testTheLongestAlbumTracks", testTheLongestAlbumTracks)
    ]

    func testAlbum() { albumJinx() }
    func testAlbums() { albums() }
    func testTheLongestAlbumTracks() { theLongestAlbumTracks() }

}
