import Foundation
import Combine
import XCTest
import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyURIs

final class SpotifyIdentifierTests: XCTestCase {

    static var cancellables: Set<AnyCancellable> = []

    static var allTests = [
        ("testTrackURIs", testTrackURIs),
        ("testArtistURIs", testArtistURIs),
        ("testAlbumURIs", testAlbumURIs),
        ("testPlaylistURIs", testPlaylistURIs),
        ("testEpisodeURIs", testEpisodeURIs),
        ("testShowURIs", testShowURIs),
        ("testInvalidURIs", testInvalidURIs)
    ]
    
    func validateURI(
        uri: SpotifyURIConvertible, idCategory: IDCategory, id: String
    ) throws -> XCTestExpectation? {
        
        // MARK: Initialize from a URI
        let spotifyIdentifierURI = try SpotifyIdentifier(
            uri: uri, ensureCategoryMatches: [idCategory]
        )

        // assert that passing in the wrong category for
        // `ensureCategoryMatches` throws an error.
        for category in IDCategory.allCases where category != idCategory {
            XCTAssertThrowsError(
                try SpotifyIdentifier(
                    uri: uri, ensureCategoryMatches: [category]
                )
            )
        }
        
        XCTAssertEqual(spotifyIdentifierURI.uri, uri.uri)
        XCTAssertEqual(spotifyIdentifierURI.idCategory, idCategory)
        XCTAssertEqual(spotifyIdentifierURI.id, id)
        XCTAssertEqual(
            spotifyIdentifierURI.url,
            URL(string: "https://open.spotify.com/\(idCategory.rawValue)/\(id)")!
        )
        
        // MARK: Initialize from an id and id category
        let spotifyIdentifierID = SpotifyIdentifier(
            id: id, idCategory: idCategory
        )
        XCTAssertEqual(spotifyIdentifierID.uri, uri.uri)
        XCTAssertEqual(spotifyIdentifierID.idCategory, idCategory)
        XCTAssertEqual(spotifyIdentifierID.id, id)
        XCTAssertEqual(
            spotifyIdentifierID.url,
            URL(string: "https://open.spotify.com/\(idCategory.rawValue)/\(id)")!
        )
        
        guard let spotifyIdentifierIDURL = spotifyIdentifierID.url else {
            XCTFail("spotifyIdentifierID.url should not be nil")
            return nil
        }
        
        // MARK: Initialize from a URL
        let spotifyIdentifierURL = try SpotifyIdentifier(
            url: spotifyIdentifierIDURL
        )
        XCTAssertEqual(spotifyIdentifierURL.uri, uri.uri)
        XCTAssertEqual(spotifyIdentifierURL.idCategory, idCategory)
        XCTAssertEqual(spotifyIdentifierURL.id, id)
        XCTAssertEqual(
            spotifyIdentifierURL.url,
            URL(string: "https://open.spotify.com/\(idCategory.rawValue)/\(id)")!
        )
        
        
        
        // MARK: Assert that the URL actually exists
        guard let url = spotifyIdentifierURI.url else {
            XCTFail("url should not be nil")
            return nil
        }
        
        let expectation = XCTestExpectation(description: "url existence")
        
        assertURLExists(url).sink(receiveCompletion: { _ in
            print("exists: \(url)")
            expectation.fulfill()
        })
        .store(in: &Self.cancellables)
        
        return expectation
        
        // wait(for: [expectation], timeout: 30)
        
        
        
    }
    
    func validateCommaSeparatedIdsString(
        _ uris: [SpotifyURIConvertible], categories: [IDCategory]
    ) throws {
        
        _ = try SpotifyIdentifier.commaSeparatedIdsString(uris)
        
        _ = try SpotifyIdentifier.commaSeparatedIdsString(
            uris, ensureCategoryMatches: categories
        )
        
        let incorrectCategories = IDCategory.allCases.filter({
            !categories.contains($0)
        })
        
        XCTAssertThrowsError(
            try SpotifyIdentifier.commaSeparatedIdsString(
                uris, ensureCategoryMatches: incorrectCategories
            )
        )

    }
    
    
    func testTrackURIs() throws {
        
        var expectations: [XCTestExpectation] = []
        
        for track in URIs.Tracks.allCases {
            if let expectation = try validateURI(
                uri: track,
                idCategory: .track,
                id: track.uri.spotifyId!
            ) {
                expectations.append(expectation)
            }
        }
        try validateCommaSeparatedIdsString(
            URIs.Tracks.allCases.shuffled(),
            categories: [.track]
        )
        try validateCommaSeparatedIdsString(
            URIs.Tracks.allCases.shuffled() +
                URIs.Episodes.allCases.shuffled(),
            categories: [.track, .episode]
        )
        
        wait(for: expectations, timeout: 120)
        
    }
    
    func testArtistURIs() throws {
        
        var expectations: [XCTestExpectation] = []
        
        for artist in URIs.Artists.allCases {
            if let expectation = try validateURI(
                uri: artist,
                idCategory: .artist,
                id: artist.uri.spotifyId!
            ) {
                expectations.append(expectation)
            }
        }
        try validateCommaSeparatedIdsString(
            URIs.Artists.allCases.shuffled(),
            categories: [.artist]
        )

        wait(for: expectations, timeout: 120)
        
    }
    
    func testAlbumURIs() throws {
        
        var expectations: [XCTestExpectation] = []
        
        for album in URIs.Albums.allCases {
            if let expectation = try validateURI(
                uri: album,
                idCategory: .album,
                id: album.uri.spotifyId!
            ) {
                expectations.append(expectation)
            }
        }
        try validateCommaSeparatedIdsString(
            URIs.Albums.allCases.shuffled(),
            categories: [.album]
        )
        
        wait(for: expectations, timeout: 120)

    }
    
    func testPlaylistURIs() throws {
        
        var expectations: [XCTestExpectation] = []
        
        for playlist in URIs.Playlists.allCases {
            if let expectation = try validateURI(
                uri: playlist,
                idCategory: .playlist,
                id: playlist.uri.spotifyId!
            ) {
                expectations.append(expectation)
            }
        }
        try validateCommaSeparatedIdsString(
            URIs.Playlists.allCases.shuffled(),
            categories: [.playlist]
        )
        
        wait(for: expectations, timeout: 120)

    }
    
    func testEpisodeURIs() throws {
        
        var expectations: [XCTestExpectation] = []
        
        for episode in URIs.Episodes.allCases {
            if let expectation = try validateURI(
                uri: episode,
                idCategory: .episode,
                id: episode.uri.spotifyId!
            ) {
                expectations.append(expectation)
            }
        }
        try validateCommaSeparatedIdsString(
            URIs.Episodes.allCases.shuffled(),
            categories: [.episode]
        )
        
        wait(for: expectations, timeout: 120)

    }
    
    func testShowURIs() throws {
        
        var expectations: [XCTestExpectation] = []
        
        for show in URIs.Shows.allCases {
            if let expectation = try validateURI(
                uri: show,
                idCategory: .show,
                id: show.uri.spotifyId!
            ) {
                expectations.append(expectation)
            }
        }
        try validateCommaSeparatedIdsString(
            URIs.Shows.allCases.shuffled(),
            categories: [.show]
        )
        
        wait(for: expectations, timeout: 120)

    }
    
    func testInvalidURIs() throws {
        
        let invalidURI1 = "spotifyyyy:track:6S4HP9hhTI8INa94vl6U8u"
        XCTAssertThrowsError(
            try SpotifyIdentifier(uri: invalidURI1),
            "should receive error indicating that URI must start with 'spotify:'"
        ) { error in
        
            if let error = error as? SpotifyLocalError,
                   case .identifierParsingError(let message) = error {
                XCTAssertTrue(
                    message.hasSuffix("URI must start with 'spotify:'")
                )
            }
            else {
                XCTFail("Should've received identifier parsing error")
            }
            
        }
        
        let invalidURI2 = "spotify:song:7vuVUQV0dDnjXUyLPzJLPi"
        XCTAssertThrowsError(
            try SpotifyIdentifier(uri: invalidURI2),
            "should receive error indicating that 'song' is not an id category"
        ) { error in
        
            if let error = error as? SpotifyLocalError,
                   case .identifierParsingError(let message) = error {
                XCTAssertTrue(
                    message.hasSuffix(
                        """
                        : id category must be one of the following: \
                        \(IDCategory.allCases.map(\.rawValue)), \
                        but received 'song'
                        """
                    )
                )
            }
            else {
                XCTFail("Should've received identifier parsing error")
            }
            
        }
        
        let invalidURI3 = "spotify:playlist:"
        XCTAssertThrowsError(
            try SpotifyIdentifier(uri: invalidURI3),
            "should receive identifier parsing error"
        ) { error in

            if let error = error as? SpotifyLocalError,
                   case .identifierParsingError(let message) = error {
                XCTAssertEqual(
                    message,
                    "could not parse spotify id and/or " +
                        "id category from string: '\(invalidURI3)'"
                )
            }
            else {
                XCTFail("Should've received identifier parsing error")
            }
            
        }

    }
    
    
    
}
