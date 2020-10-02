import Foundation
import XCTest
import Combine
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

protocol SpotifyAPIArtistTests: SpotifyAPITests { }

extension SpotifyAPIArtistTests {
    
    func artist() {
        
        func receiveArtist(_ artist: Artist) {

            encodeDecode(artist)
            
            XCTAssertEqual(artist.name, "Pink Floyd")
            XCTAssertEqual(artist.type, .artist)
            XCTAssertEqual(artist.uri, "spotify:artist:0k17h0D3J5VfsdmQ1iZtE9")
            XCTAssertEqual(artist.id, "0k17h0D3J5VfsdmQ1iZtE9")
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
            
            XCTAssertNotNil(artist.popularity)
            XCTAssertNotNil(artist.href)
            
            
        }
        
        let expectation = XCTestExpectation(description: "testArtist")
        
        Self.spotify.artist(URIs.Artists.pinkFloyd)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveArtist(_:)
            )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 60)

    }

    func artists() {
        
        func receiveArtists(_ artists: [Artist?]) {

            for artist in artists {
                if let artist = artist {
                    XCTAssertEqual(artist.type, .artist)
                }
                encodeDecode(artist)
            }
            
            
            guard artists.count == 4 else {
                XCTFail("should've received 4 artists (got \(artists.count)")
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
            
            
        }
        
        let artists: [SpotifyURIConvertible] = [
            URIs.Artists.levitationRoom,
            "spotify:artist:invaliduri",
            URIs.Artists.theBeatles,
            URIs.Artists.radiohead
        ]
        
        let expectation = XCTestExpectation(description: "testArtists")
        
        Self.spotify.artists(artists)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveArtists(_:)
            )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 60)

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
                        accuracy: 43_200   // 12 hours
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
                        -47606400,
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
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        -13651200,
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
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: receiveArtistAlbums(_:)
        )
        .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 60)

    }
    
    func artistAlbumsSingles() {
        
        func receiveArtistAlbums(_ albums: PagingObject<Album>) {
            encodeDecode(albums)
            for album in albums.items {
                encodeDecode(album)
                XCTAssertEqual(album.albumGroup, .single)
                XCTAssertEqual(album.artists?.first?.name, "Led Zeppelin")
                XCTAssertEqual(
                    album.artists?.first?.uri,
                    "spotify:artist:36QJpDe2go2KgaRleHCDTp"
                )
                
                // these albums are not singles
                XCTAssertNotEqual(
                    album.uri, "spotify:album:1J8QW9qsMLx3staWaHpQmU"
                )
                XCTAssertNotEqual(
                    album.id, "1J8QW9qsMLx3staWaHpQmU"
                )
                XCTAssertNotEqual(
                    album.uri, "spotify:album:6VH2op0GKIl3WNTbZmmcmI"
                )
                
            }
            let reversedAlbums = Array(albums.items.reversed())
            guard reversedAlbums.count >= 3 else {
                XCTFail("Led Zeppelin should have at least 3 singles")
                return
            }
            do {
                let album = reversedAlbums[0]
                XCTAssertEqual(
                    album.name, "Black Dog (Basic Track With Guitar Overdubs)"
                )
                XCTAssertEqual(album.uri, "spotify:album:2eQNcZeVzL0g0GJ0NsLlH0")
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        60480000,
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
                    album.name, "Houses of the Holy (Rough Mix with Overdubs)"
                )
                XCTAssertEqual(album.uri, "spotify:album:3ZuGyUoJcVvHCePD1DJnvE")
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        1421798400,
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
                    album.name, "Rock and Roll (Sunset Sound Mix)"
                )
                XCTAssertEqual(album.uri, "spotify:album:6kjX6lluEIbwV0vPEVa6xa")
                XCTAssertEqual(album.releaseDatePrecision, "day")
                if let releaseDate = album.releaseDate {
                    XCTAssertEqual(
                        releaseDate.timeIntervalSince1970,
                        1524268800,
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
        
        Self.spotify.authorizationManager.setExpirationDate(to: Date())
        
        var authChangeCount = 0
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            authChangeCount += 1
        })
        .store(in: &Self.cancellables)
        
        Self.spotify.artistAlbums(
            URIs.Artists.ledZeppelin,
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

        wait(for: [expectation], timeout: 60)
        XCTAssertEqual(
            authChangeCount, 1,
            "authorizationManagerDidChange should emit exactly once"
        )
    }
    
    func artistTopTracks() {
        
        let expectation = XCTestExpectation(
            description: "testArtistTopTracks"
        )
        
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
        
        wait(for: [expectation], timeout: 60)
        
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
                    encodeDecode(artists)
                    for artist in artists {
                        encodeDecode(artist)
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
            
        wait(for: [expectation], timeout: 60)
        
    }
    
}

final class SpotifyAPIAuthorizationCodeFlowArtistTests:
        SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIArtistTests
{

    static let allTests = [
        ("testArtist", testArtist),
        ("testArtists", testArtists),
        ("testArtistAlbums", testArtistAlbums),
        ("testArtistAlbumsSingles", testArtistAlbumsSingles),
        ("testArtistTopTracks", testArtistTopTracks),
        ("testRelatedArtists", testRelatedArtists)
        
    ]
    
    func testArtist() { artist() }
    func testArtists() { artists() }
    func testArtistAlbums() { artistAlbums() }
    func testArtistAlbumsSingles() { artistAlbumsSingles() }
    func testArtistTopTracks() { artistTopTracks() }
    func testRelatedArtists() { relatedArtists() }
    
}

final class SpotifyAPIClientCredentialsFlowArtistTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIArtistTests
{

    static let allTests = [
        ("testArtist", testArtist),
        ("testArtists", testArtists),
        ("testArtistAlbums", testArtistAlbums),
        ("testArtistAlbumsSingles", testArtistAlbumsSingles),
        ("testArtistTopTracks", testArtistTopTracks),
        ("testRelatedArtists", testRelatedArtists)
        
    ]
    
    func testArtist() { artist() }
    func testArtists() { artists() }
    func testArtistAlbums() { artistAlbums() }
    func testArtistAlbumsSingles() { artistAlbumsSingles() }
    func testArtistTopTracks() { artistTopTracks() }
    func testRelatedArtists() { relatedArtists() }
    
}
