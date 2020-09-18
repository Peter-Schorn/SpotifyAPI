import Foundation
import XCTest
import Combine
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyURIs

protocol SpotifyAPIArtistTests: SpotifyAPITests { }

extension SpotifyAPIArtistTests {
    
    func artist() {
        
        func receiveArtist(_ artist: Artist) {
            
            XCTAssertEqual(artist.name, "Pink Floyd")
            XCTAssertEqual(artist.type, .artist)
            XCTAssertEqual(artist.uri, "spotify:artist:0k17h0D3J5VfsdmQ1iZtE9")
            XCTAssertEqual(artist.id, "0k17h0D3J5VfsdmQ1iZtE9")
            XCTAssert(artist.genres?.contains("art rock") ?? false)
            XCTAssert(artist.genres?.contains("album rock") ?? false)
            XCTAssert(artist.genres?.contains("classic rock") ?? false)
            XCTAssert(artist.genres?.contains("progressive rock") ?? false)
            XCTAssert(artist.genres?.contains("psychedelic rock") ?? false)
            XCTAssert(artist.genres?.contains("rock") ?? false)
            XCTAssert(artist.genres?.contains("symphonic rock") ?? false)
            
            encodeDecode(artist)
            
        }
        
        let expectation = XCTestExpectation(description: "testArtist")
        
        Self.spotify.artist(URIs.Artists.pinkFloyd)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveArtist(_:)
            )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 30)

    }

}

class SpotifyAPIAuthorizationCodeFlowArtistTests:
        SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIArtistTests
{

    static let allTests = [
        ("testArtist", testArtist)
    ]
    
    func testArtist() { artist() }

}

class SpotifyAPIClientCredentialsFlowArtistTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIArtistTests
{

    static let allTests = [
        ("testArtist", testArtist)
    ]

    func testArtist() { artist() }

}
