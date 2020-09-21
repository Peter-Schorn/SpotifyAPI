import Foundation
import XCTest
import Combine
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

protocol SpotifyAPIPlaylistsTests: SpotifyAPITests { }

extension SpotifyAPIPlaylistsTests {
    
    func getCrumbPlaylist() {
        
        let expectation = XCTestExpectation(
            description: "getCrumbPlaylist"
        )
        
        let trackNames = [
            "Part III", "Plants", "Locket", "Nina", "Jinx",
            "M.R.", "And It Never Ends", "Thirty-Nine", "Cracking",
            "Recently Played", "Vinta", "Faces", "Ghostride",
            "Bones", "Fall Down"
        ]
        
        Self.spotify.playlist(URIs.Playlists.crumb)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { playlist in
                    encodeDecode(playlist)
                    XCTAssertEqual(playlist.name, "Crumb")
                    XCTAssertEqual(playlist.items.items.count, 15)
                    if playlist.items.items.count < 15 { return }
                    
                    let tracks = playlist.items.items.map(\.item)
                    for (i, track) in tracks.enumerated() {
                        guard case .track(let track) = track else {
                            XCTFail("playlist should only contain tracks")
                            continue
                        }
                        XCTAssertEqual(track.name, trackNames[i])
                    }
                    
                }
            )
            .store(in: &Self.cancellables)

        wait(for: [expectation], timeout: 30)
    }
    
    func getCrumbPlaylistTracks() {
        
        let expectation = XCTestExpectation(
            description: "getCrumPlaylistTracks"
        )
        
        let trackNames = [
            "Part III", "Plants", "Locket", "Nina", "Jinx",
            "M.R.", "And It Never Ends", "Thirty-Nine", "Cracking",
            "Recently Played", "Vinta", "Faces", "Ghostride",
            "Bones", "Fall Down"
        ]
        
        Self.spotify.playlistTracks(URIs.Playlists.crumb)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { playlistTracks in
                    encodeDecode(playlistTracks)
                    let tracks = playlistTracks.items.map(\.item)
                    XCTAssertEqual(playlistTracks.items.count, 15)
                    if playlistTracks.items.count < 15 { return }
                    
                    for (i, track) in tracks.enumerated() {
                        XCTAssertEqual(track.name, trackNames[i])
                    }
            
                }
            )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 30)

    }

}

extension SpotifyAPIPlaylistsTests where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{
    
    func createPlaylistAndAddTracksThenUnfollowIt() {
        
        let dateString = Date().description(with: .current)
        let newItems = URIs.Tracks.array(
            .jinx, .fearless, .illWind, .nuclearFusion, .theBay
            ) + URIs.Episodes.array(
                .samHarris213, .samHarris214, .samHarris212
        )
        
        let details = PlaylistDetails(
            name: "createPlaylistAddTracks",
            isPublic: false,
            collaborative: false,
            description: dateString
        )
        
        let expectation = XCTestExpectation(
            description: "createPlaylistAndAddTracks"
        )
        
        var createdPlaylistURI = ""
        var createdPlaylistSnaphotId = ""
        
        // get the uri of the current user
        Self.spotify.currentUserProfile()
            .flatMap { user -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                // create a playlist for them
                encodeDecode(user)
                return Self.spotify.createPlaylist(for: user.uri, details)
        }
        .flatMap { playlist -> AnyPublisher<String, Error> in
            
            encodeDecode(playlist)
            XCTAssertEqual(playlist.name, "createPlaylistAddTracks")
            XCTAssertEqual(playlist.description, dateString)
            XCTAssertFalse(playlist.isPublic ?? true)
            XCTAssertFalse(playlist.collaborative)
            XCTAssertEqual(playlist.items.items.count, 0)
            
            createdPlaylistURI = playlist.uri
            
            // add tracks and episodes to the playlist
            return Self.spotify.addToPlaylist(
                playlist.uri,
                uris: newItems
            )
        }
        .flatMap { snapshotId -> AnyPublisher<Playlist<PlaylistItems>, Error> in
            // retrieve the playlist
            createdPlaylistSnaphotId = snapshotId
            return Self.spotify.playlist(createdPlaylistURI)
        }
        .flatMap { playlist -> AnyPublisher<Void, Error> in
            
            encodeDecode(playlist)
            XCTAssertEqual(playlist.uri, createdPlaylistURI)
            XCTAssertEqual(playlist.snapshotId, createdPlaylistSnaphotId)
            XCTAssertEqual(playlist.name, "createPlaylistAddTracks")
            XCTAssertEqual(playlist.description, dateString)
            XCTAssertFalse(playlist.isPublic ?? true)
            XCTAssertFalse(playlist.collaborative)
            XCTAssertEqual(
                playlist.items.items.map(\.item.uri),
                newItems.map(\.uri)
            )
            
            // unfollow the playlist
            return Self.spotify.unfollowPlaylistForCurrentUser(
                createdPlaylistURI
            )
            
        }
        .flatMap {
            // get all of the current user's playlists
            Self.spotify.currentUserPlaylists()
        }
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { playlists in
                encodeDecode(playlists)
                XCTAssertFalse(
                    // ensure the user is no longer following the playlist
                    // because we just unfollowed it
                    playlists.items.map(\.uri).contains(createdPlaylistURI)
                )
        }
        )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 30)
        
    }

}

class SpotifyAPIAuthorizationCodeFlowPlaylistsTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIPlaylistsTests
{

    static let allTests = [
        (
            "testCreatePlaylistAndAddTracksThenUnfollowIt",
            testCreatePlaylistAndAddTracksThenUnfollowIt
        ),
        ("testGetCrumbPlaylist", testGetCrumbPlaylist),
        ("testGetCrumPlaylistTracks", testGetCrumbPlaylistTracks)
    ]
    
    func testCreatePlaylistAndAddTracksThenUnfollowIt() {
        createPlaylistAndAddTracksThenUnfollowIt()
    }
    func testGetCrumbPlaylist() { getCrumbPlaylist() }
    func testGetCrumbPlaylistTracks() { getCrumbPlaylistTracks() }

}

class SpotifyAPIClientCredentialsFlowPlaylistsTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIPlaylistsTests
{

    static let allTests = [
        ("testGetCrumbPlaylist", testGetCrumbPlaylist),
        ("testGetCrumbPlaylistTracks", testGetCrumbPlaylistTracks)
    ]
    
    func testGetCrumbPlaylist() { getCrumbPlaylist() }
    func testGetCrumbPlaylistTracks() { getCrumbPlaylistTracks() }

}
