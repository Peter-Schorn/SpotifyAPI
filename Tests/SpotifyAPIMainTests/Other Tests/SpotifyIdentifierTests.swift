import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import XCTest
import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

final class SpotifyIdentifierTests: SpotifyAPITestCase {

    static var cancellables: Set<AnyCancellable> = []

    static let allTests = [
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
    ) throws {
        
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
            return
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
        
        XCTAssertNotNil(spotifyIdentifierURI.url)
        
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
    
    func assertURLsExist<C: Collection>(
        _ uris: C
    ) throws where C.Element: SpotifyURIConvertible {
        
        var expectations: [XCTestExpectation] = []
        
        for uri in uris {
            guard let url = try SpotifyIdentifier(uri: uri).url else {
                XCTFail("URL should not be nil for '\(uri)'")
                continue
            }
           
            let expectation = XCTestExpectation(
                description: "assert URL exists: '\(url)'"
            )
            expectations.append(expectation)
            assertURLExists(url).sink(receiveCompletion: { _ in
                print("exists: \(url)")
                expectation.fulfill()
            })
            .store(in: &Self.cancellables)
            
        }
        
        self.wait(for: expectations, timeout: TimeInterval(uris.count * 20))

    }
    
    
    func testTrackURIs() throws {
        
        for track in URIs.Tracks.allCases {
            try validateURI(
                uri: track,
                idCategory: .track,
                id: track.uri.spotifyId!
            )
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
        
        let tracks = URIs.Tracks.allCases.shuffled().prefix(3)
        try assertURLsExist(tracks)
        
    }
    
    func testArtistURIs() throws {
                
        for artist in URIs.Artists.allCases {
            try validateURI(
                uri: artist,
                idCategory: .artist,
                id: artist.uri.spotifyId!
            )
        }
        try validateCommaSeparatedIdsString(
            URIs.Artists.allCases.shuffled(),
            categories: [.artist]
        )
        
        let artists = URIs.Artists.allCases.shuffled().prefix(3)
        try assertURLsExist(artists)
    }
    
    func testAlbumURIs() throws {
        
        for album in URIs.Albums.allCases {
            try validateURI(
                uri: album,
                idCategory: .album,
                id: album.uri.spotifyId!
            )
        }
        try validateCommaSeparatedIdsString(
            URIs.Albums.allCases.shuffled(),
            categories: [.album]
        )
        let albums = URIs.Albums.allCases.shuffled().prefix(3)
        try assertURLsExist(albums)
        
    }
    
    func testPlaylistURIs() throws {
        
        for playlist in URIs.Playlists.allCases {
            try validateURI(
                uri: playlist,
                idCategory: .playlist,
                id: playlist.uri.spotifyId!
            )
        }
        try validateCommaSeparatedIdsString(
            URIs.Playlists.allCases.shuffled(),
            categories: [.playlist]
        )
        let playlist = URIs.Playlists.bluesClassics
        try assertURLsExist([playlist])
        
    }
    
    func testEpisodeURIs() throws {
        
        for episode in URIs.Episodes.allCases {
            try validateURI(
                uri: episode,
                idCategory: .episode,
                id: episode.uri.spotifyId!
            )
        }
        try validateCommaSeparatedIdsString(
            URIs.Episodes.allCases.shuffled(),
            categories: [.episode]
        )
        let episodes = URIs.Episodes.allCases.shuffled().prefix(3)
        try assertURLsExist(episodes)
        
    }
    
    func testShowURIs() throws {
        
        for show in URIs.Shows.allCases {
            try validateURI(
                uri: show,
                idCategory: .show,
                id: show.uri.spotifyId!
            )
        }
        try validateCommaSeparatedIdsString(
            URIs.Shows.allCases.shuffled(),
            categories: [.show]
        )
        let shows = URIs.Shows.allCases.shuffled().prefix(3)
        try assertURLsExist(shows)
        
    }
    
    func testInvalidURIs() throws {
        
        let invalidURI1 = "spotifyyyy:track:6S4HP9hhTI8INa94vl6U8u"
        XCTAssertThrowsError(
            try SpotifyIdentifier(uri: invalidURI1),
            "should receive error indicating that URI must start with 'spotify:'"
        ) { error in
        
            if let error = error as? SpotifyGeneralError,
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
        
            if let error = error as? SpotifyGeneralError,
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

            if let error = error as? SpotifyGeneralError,
                   case .identifierParsingError(let message) = error {
                XCTAssertEqual(
                    message,
                    "could not parse Spotify id and/or " +
                        "id category from string: '\(invalidURI3)'"
                )
            }
            else {
                XCTFail("Should've received identifier parsing error")
            }
            
        }

    }
    
    
    
}
