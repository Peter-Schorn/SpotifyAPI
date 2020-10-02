import Foundation
import XCTest
import Combine
import SwiftUI
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
                    XCTAssertEqual(playlist.uri, "spotify:playlist:33yLOStnp2emkEA76ew1Dz")
                    XCTAssertEqual(playlist.id, "33yLOStnp2emkEA76ew1Dz")
                    guard playlist.items.items.count >= 15 else {
                        XCTFail("Crumb playlist should have at least 15 tracks")
                        return
                    }
                    let tracks = playlist.items.items.map(\.item)
                    for (i, track) in tracks.enumerated() {
                        guard case .track(let track) = track else {
                            XCTFail("playlist should only contain tracks")
                            continue
                        }
                        print(i)
                        XCTAssertEqual(track.name, trackNames[i])
                    }
                    
                }
            )
            .store(in: &Self.cancellables)

        wait(for: [expectation], timeout: 60)
    }
    
    func getCrumbPlaylistTracks() {
        
        let expectation = XCTestExpectation(
            description: "getCrumPlaylistTracks"
        )
        
        let trackNames = [
            "Nina", "Jinx", "M.R.", "And It Never Ends", "Thirty-Nine",
            "Cracking", "Recently Played", "Vinta", "Faces", "Ghostride"
        ]
        
        Self.spotify.authorizationManager.setExpirationDate(to: Date())
        
        var authChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            .sink(receiveValue: {
                authChangeCount += 1
            })
            .store(in: &Self.cancellables)
        
        Self.spotify.playlistTracks(
            URIs.Playlists.crumb,
            limit: 10,
            offset: 3,
            market: "US"
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { playlistTracks in
                encodeDecode(playlistTracks)
                let tracks = playlistTracks.items.map(\.item)
                XCTAssertEqual(playlistTracks.items.count, 10)
                if playlistTracks.items.count < 10 { return }
                
                for (i, track) in tracks.enumerated() {
                    XCTAssertEqual(track.name, trackNames[i])
                    XCTAssertEqual(track.artists?.first?.name, "Crumb")
                    XCTAssertEqual(
                        track.artists?.first?.uri,
                        "spotify:artist:4kSGbjWGxTchKpIxXPJv0B"
                    )
                    XCTAssertEqual(
                        track.artists?.first?.id,
                        "4kSGbjWGxTchKpIxXPJv0B"
                    )
                    
                }
        
            }
        )
        .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 60)
        XCTAssertEqual(
            authChangeCount, 1,
            "authorizationManagerDidChange should emit exactly once"
        )

    }
    
    func filteredPlaylist() {
        
        let expectation = XCTestExpectation(
            description: "testFilteredPlaylist"
        )
        
        let filters =
        "name,uri,owner.display_name,tracks.items(track.artists(name,uri,type))"
        
        Self.spotify.filteredPlaylistRequest(
            URIs.Playlists.macDeMarco,
            filters: filters,
            additionalTypes: [.track]
        )
        .XCTAssertNoFailure()
        .decodeSpotifyObject(FilteredPlaylist.self)
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { playlist in
                encodeDecode(playlist)
                XCTAssertEqual(playlist.name, "Mac DeMarco")
                XCTAssertEqual(playlist.uri, "spotify:playlist:6oyVZ3dZZVCkXJm451Hj5v")
                XCTAssertEqual(playlist.ownerDisplayName, "petervschorn")
                let artists = playlist.tracks.flatMap(\.artists)
                for artist in artists {
                    XCTAssertEqual(artist.name, "Mac DeMarco")
                    XCTAssertEqual(artist.type, .artist)
                    XCTAssertEqual(artist.uri, "spotify:artist:3Sz7ZnJQBIHsXLUSo0OQtM")
                }
            }
        )
        .store(in: &Self.cancellables)
     
        wait(for: [expectation], timeout: 120)

    }
    
    func otherUserCurrentPlaylists() {
        
        let expectation = XCTestExpectation(
            description: "testOtherUserCUrrentPlaylists"
        )
        
        let user = URIs.Users.april
        
        Self.spotify.userPlaylists(
            for: user,
            limit: 50,
            offset: 0
        )
        .XCTAssertNoFailure()
        .extendPages(Self.spotify)
        .XCTAssertNoFailure()
        .collect()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { playlistsArray in
                encodeDecode(playlistsArray)
                let playlists = playlistsArray.flatMap(\.items)
                for playlist in playlists {
                    print("[\(playlist.name)]")
                }
                let playlist = playlists.first(where: { playlist in
                    playlist.name.strip() == "Kpop" &&
                            playlist.uri == "spotify:playlist:7p0mfgdBNyKWugXrO04WhI" &&
                            playlist.id == "7p0mfgdBNyKWugXrO04WhI"
                })
                
                XCTAssertNotNil(
                    playlist, "Should've found April's Kpop playlist"
                )
                
            }
        )
        .store(in: &Self.cancellables)
        

    }
    
}

extension SpotifyAPIPlaylistsTests where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{
    
    func createPlaylistAndAddTracksThenUnfollowIt() {
        
        let dateString = Date().description(with: .current)
        let itemsToAddToPlaylist = URIs.Tracks.array(
            .jinx, .fearless, .illWind, .nuclearFusion, .theBay
        ) + URIs.Episodes.array(
            .samHarris213, .samHarris214, .samHarris212
        )
        
        let details = PlaylistDetails(
            name: "createPlaylistAddTracks",
            isPublic: false,
            isCollaborative: false,
            description: dateString
        )
        encodeDecode(details)
        
        let expectation = XCTestExpectation(
            description: "createPlaylistAndAddTracks"
        )
        
        var createdPlaylistURI = ""
        var createdPlaylistSnaphotId = ""
        
        // get the uri of the current user
        Self.spotify.currentUserProfile()
            .XCTAssertNoFailure()
            .flatMap { user -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                // create a playlist for them
                encodeDecode(user)
                return Self.spotify.createPlaylist(for: user.uri, details)
        }
        .XCTAssertNoFailure()
        .flatMap { playlist -> AnyPublisher<String, Error> in
            
            encodeDecode(playlist)
            XCTAssertEqual(playlist.name, "createPlaylistAddTracks")
            XCTAssertEqual(playlist.description, dateString)
            XCTAssertFalse(playlist.isPublic ?? true)
            XCTAssertFalse(playlist.isCollaborative)
            XCTAssertEqual(playlist.items.items.count, 0)
            
            createdPlaylistURI = playlist.uri
            XCTAssert(createdPlaylistURI.count > 5)
            
            // add tracks and episodes to the playlist
            return Self.spotify.addToPlaylist(
                playlist.uri, uris: itemsToAddToPlaylist
            )
        }
        .XCTAssertNoFailure()
        .flatMap { snapshotId -> AnyPublisher<Playlist<PlaylistItems>, Error> in
            // retrieve the playlist
            createdPlaylistSnaphotId = snapshotId
            XCTAssert(createdPlaylistURI.count > 5)
            XCTAssert(createdPlaylistSnaphotId.count > 5)
            return Self.spotify.playlist(createdPlaylistURI)
        }
        .XCTAssertNoFailure()
        .flatMap { playlist -> AnyPublisher<Void, Error> in
            
            encodeDecode(playlist)
            XCTAssertEqual(playlist.uri, createdPlaylistURI)
            XCTAssertEqual(playlist.snapshotId, createdPlaylistSnaphotId)
            XCTAssertEqual(playlist.name, "createPlaylistAddTracks")
            XCTAssertEqual(playlist.description, dateString)
            XCTAssertFalse(playlist.isPublic ?? true)
            XCTAssertFalse(playlist.isCollaborative)
            // assert that the playlist contains all of the items that
            // we just added, in the same order.
            XCTAssertEqual(
                playlist.items.items.map(\.item.uri),
                itemsToAddToPlaylist.map(\.uri)
            )
            
            // unfollow the playlist
            return Self.spotify.unfollowPlaylistForCurrentUser(
                createdPlaylistURI
            )
            
        }
        .XCTAssertNoFailure()
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
        
        wait(for: [expectation], timeout: 120)
        
    }
    
    func createPlaylistAddRemoveReorderItems() {
        
        let itemsToAddToPlaylist: [SpotifyURIConvertible] = [
            URIs.Tracks.anyColourYouLike,  // 0
            URIs.Tracks.because,           // 1 | rangeStart
            URIs.Tracks.blueBoy,           // 2 |
            URIs.Tracks.breathe,           // 3 | rangeLength = 3
            URIs.Episodes.seanCarroll111,  // 4
            URIs.Episodes.joeRogan1531,    // 5
            URIs.Episodes.samHarris212     // 6  insertBefore
        ]
        
        let reorderRequest1 = ReorderPlaylistItems(
            rangeStart: 1,
            rangeLength: 3,
            insertBefore: 6
        )
        
        /// The expected order of the items after sending `reorderRequest1`.
        let reordered1: [SpotifyURIConvertible] = [
            URIs.Tracks.anyColourYouLike,  //      0
                                           //---->
            URIs.Episodes.seanCarroll111,  //    | 1
            URIs.Episodes.joeRogan1531,    //    | 2
            URIs.Tracks.because,           //  <-| 3
            URIs.Tracks.blueBoy,           //  <-| 4
            URIs.Tracks.breathe,           //  <-| 5
            URIs.Episodes.samHarris212     //      6
        ]
        
        let reorderRequest2 = ReorderPlaylistItems(
            rangeStart: 5,
            insertBefore: 2
        )
        
        let reordered2: [SpotifyURIConvertible] = [
            URIs.Tracks.anyColourYouLike,  // 0
            URIs.Episodes.seanCarroll111,  // 1
            URIs.Tracks.breathe,           // 2  —
            URIs.Episodes.joeRogan1531,    // 3  |
            URIs.Tracks.because,           // 4  |
            URIs.Tracks.blueBoy,           // 5  —
            URIs.Episodes.samHarris212     // 6
        ]

        let dateString = Date().description(with: .current)
        var createdPlaylistURI = ""
            
        let playlistDetails = PlaylistDetails(
            name: "createPlaylistAddRemoveReorderItems",
            isCollaborative: nil,
            description: dateString
        )
        
        encodeDecode(playlistDetails)
        
        let expectation = XCTestExpectation(
            description: "testCreatePlaylistAddRemoveReorderItems"
        )
        
        let publisher: AnyPublisher<PlaylistItems, Error> = Self.spotify
            .currentUserProfile()
            .XCTAssertNoFailure()
            .flatMap { user -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                encodeDecode(user)
                // MARK: Create the playlist
                return Self.spotify.createPlaylist(
                    for: user.uri, playlistDetails
                )
            }
            .XCTAssertNoFailure()
            .flatMap { (playlist: Playlist<PlaylistItems>) -> AnyPublisher<String, Error> in
             
                encodeDecode(playlist)
                // MARK: Ensure it has the details we added
                XCTAssertEqual(playlist.name, "createPlaylistAddRemoveReorderItems")
                XCTAssertEqual(playlist.description, dateString)
                if let isPublic = playlist.isPublic {
                    XCTAssertTrue(isPublic)
                }
                else {
                    XCTFail("playlist.isPublic should not be nil")
                }
                XCTAssertFalse(playlist.isCollaborative)
                XCTAssertEqual(playlist.items.items.count, 0)
                
                createdPlaylistURI = playlist.uri
                XCTAssert(createdPlaylistURI.count > 5)
                
                // MARK: Add Tracks and episodes to the playlist
                return Self.spotify.addToPlaylist(
                    playlist.uri, uris: itemsToAddToPlaylist
                )
                
            }
            .XCTAssertNoFailure()
            .delay(for: 2, scheduler: DispatchQueue.main)
            .flatMap { (snapshotId: String) -> AnyPublisher<PagingObject<Playlist<PlaylistsItemsReference>>, Error> in
                // get all of the current user's playlists
                // MARK: Get all of the user's playlists
                Self.spotify.currentUserPlaylists()
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .flatMap { (playlistsArray: [PagingObject<Playlist<PlaylistsItemsReference>>]) -> AnyPublisher<PlaylistItems, Error> in
                
                encodeDecode(playlistsArray)
                // MARK: Ensure the user is following the playlist we just created
                let playlists = playlistsArray.flatMap({ $0.items })
                let playlist = playlists.first(where: { playlist in
                    playlist.uri == createdPlaylistURI
                })
                XCTAssertNotNil(
                    playlist,
                    "should've found just-created playlist in currentUserPlaylists"
                )
                
                XCTAssert(createdPlaylistURI.count > 5)
                // MARK: Get all of the tracks and episodes in the playlist
                return Self.spotify.playlistItems(createdPlaylistURI)
            }
            .XCTAssertNoFailure()
        
        // A single subscription stream takes too long to type-check.
        publisher
            .flatMap { playlistItems -> AnyPublisher<String, Error> in
            
                encodeDecode(playlistItems)
                // assert that the playlist contains all of the items that
                // we just added, in the same order.
                // MARK: Ensure the playlist has the items we added
                XCTAssertEqual(
                    playlistItems.items.map(\.item.uri),
                    itemsToAddToPlaylist.map(\.uri)
                )
            
                // MARK: Reorder the items in the playlist 1
                return Self.spotify.reorderPlaylistItems(
                    createdPlaylistURI, body: reorderRequest1
                )
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.main)
            .flatMap { snapshotId -> AnyPublisher<PlaylistItems, Error> in
                // MARK: Get the items in the playlist again
                return Self.spotify.playlistItems(createdPlaylistURI)
            }
            .XCTAssertNoFailure()
            .flatMap { playlistItems -> AnyPublisher<String, Error> in
            
                encodeDecode(playlistItems)
                // MARK: Ensure the items in the playlist were reordered as requested 1
                XCTAssertEqual(
                    playlistItems.items.map(\.item.uri),
                    reordered1.map(\.uri)
                )
                // MARK: Reorder the items in the playlist 2
                return Self.spotify.reorderPlaylistItems(
                    createdPlaylistURI, body: reorderRequest2
                )
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.main)
            .flatMap { snapshotId -> AnyPublisher<PlaylistItems, Error> in
                // MARK: Get the items in the playlist again
                return Self.spotify.playlistItems(createdPlaylistURI)
            }
            .XCTAssertNoFailure()
            .flatMap { playlistItems -> AnyPublisher<Void, Error> in
                encodeDecode(playlistItems)
                // MARK: Ensure the items in the playlist were reordered as requested 2
                XCTAssertEqual(
                    playlistItems.items.map(\.item.uri),
                    reordered2.map(\.uri)
                )
                // MARK: Unfollow the playlist
                return Self.spotify.unfollowPlaylistForCurrentUser(
                    createdPlaylistURI
                )
            
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.main)
            .flatMap {
                // get all of the current user's playlists
                // MARK: Get all of the user's playlists
                Self.spotify.currentUserPlaylists()
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { playlists in
                    encodeDecode(playlists)
                    XCTAssertFalse(
                        // ensure the user is no longer following the playlist
                        // because we just unfollowed it
                        // MARK: Ensure the playlist is no longer being followed
                        playlists.items.map(\.uri).contains(createdPlaylistURI)
                    )
                }
            )
            .store(in: &Self.cancellables)
            

        wait(for: [expectation], timeout: 300)
        
    }
    
    func playlistCoverImage() {
        
        var cancellables: [AnyCancellable] = []

        var expectations: [XCTestExpectation] = []
        
        func receiveImages(_ images: [SpotifyImage]) {
            
            print("line \(#line): recevied \(images.count) images")
            XCTAssertFalse(images.isEmpty)
            
            for (i, image) in images.enumerated() {
                
                let loadImageExpectation = XCTestExpectation(
                    description: "load image \(i)"
                )
                expectations.append(loadImageExpectation)
                
                image.load()
                    .XCTAssertNoFailure()
                    .sink(
                        receiveCompletion: { _ in
                            print("loadImageExpectation.fulfill() \(i)")
                            loadImageExpectation.fulfill()
                        },
                        receiveValue: { image in
                            print("received image \(i): \(image)")
                        }
                    )
                    .store(in: &cancellables)
                
                
                if let url = URL(string: image.url) {
                    let urlExists = XCTestExpectation(
                        description: "url exists \(i)"
                    )
                    expectations.append(urlExists)
                    assertURLExists(url)
                        .sink(
                            receiveCompletion: { _ in
                                print("urlExists.fulfill() '\(image.url)'")
                                urlExists.fulfill()
                            },
                            receiveValue: { _ in
                                print("urlExists receiveValue '\(image.url)'")
                            }
                        )
                        .store(in: &cancellables)
                
                } else {
                    XCTFail("couldn't convert string to URL: '\(image.url)'")
                }
                
            }
            
        }
        
        let playlists: [URIs.Playlists] = [
            .thisIsTheBeatles, .all, .bluesClassics
        ]
        for (i, playlist) in playlists.enumerated() {

            let playlistCoverImageExpectation = XCTestExpectation(
                description: "testPlaylistCoverImage \(i)"
            )
            expectations.append(playlistCoverImageExpectation)
            
            Self.spotify.getPlaylistImage(playlist)
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { _ in
                        playlistCoverImageExpectation.fulfill()
                    },
                    receiveValue: receiveImages(_:)
                )
                .store(in: &cancellables)
            
        }
        
        wait(for: expectations, timeout: 240)
        

    }
    
    func removeAllOccurencesFromPlaylist() {
        
        let itemsToAddToPlaylist: [SpotifyURIConvertible] = [
            URIs.Episodes.samHarris215,
            URIs.Tracks.honey,
            URIs.Tracks.friends,
            URIs.Tracks.friends,
            URIs.Tracks.because,
            URIs.Tracks.friends,
            URIs.Tracks.friends,
            URIs.Episodes.joeRogan1531,
            URIs.Episodes.joeRogan1531,
            URIs.Episodes.samHarris214,
            URIs.Episodes.joeRogan1531,
            URIs.Episodes.joeRogan1531
        ]
        
        let itemsToRemoveFromPlaylist: [SpotifyURIConvertible] = [
            URIs.Tracks.friends,
            URIs.Episodes.joeRogan1531,
            URIs.Tracks.because
        ]
        
        let itemsLeftInPlaylist: [SpotifyURIConvertible] = [
            URIs.Episodes.samHarris215,
            URIs.Tracks.honey,
            URIs.Episodes.samHarris214
        ]
        
        var createdPlaylistURI = ""
        
        let playlistDetails = PlaylistDetails(
            name: "removeAllOccurencesFromPlaylist",
            isPublic: false,
            isCollaborative: true
        )

        encodeDecode(playlistDetails)
        
        let expectation = XCTestExpectation(
            description: "testRemoveAllOccurencesFromPlaylist"
        )
        
        Self.spotify.currentUserProfile()
            .XCTAssertNoFailure()
            .flatMap { user -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                encodeDecode(user)
                return Self.spotify.createPlaylist(
                    for: user.uri, playlistDetails
                )
            }
            .XCTAssertNoFailure()
            .flatMap { playlist -> AnyPublisher<String, Error> in
                
                encodeDecode(playlist)
                XCTAssertEqual(playlist.name, "removeAllOccurencesFromPlaylist")
                XCTAssertFalse(playlist.isPublic ?? true)
                XCTAssertTrue(playlist.isCollaborative)
                XCTAssertEqual(playlist.items.items.count, 0)
                
                createdPlaylistURI = playlist.uri
                XCTAssert(createdPlaylistURI.count > 5)
                
                // add tracks and episodes to the playlist
                return Self.spotify.addToPlaylist(
                    playlist.uri, uris: itemsToAddToPlaylist
                )
            }
            .XCTAssertNoFailure()
            .flatMap { snapshotId -> AnyPublisher<PlaylistItems, Error> in
                // retrieve the playlist
                XCTAssert(createdPlaylistURI.count > 5)
                return Self.spotify.playlistItems(createdPlaylistURI)
            }
            .XCTAssertNoFailure()
            .flatMap { playlistItems -> AnyPublisher<String, Error> in
                
                encodeDecode(playlistItems)
                XCTAssertEqual(
                    playlistItems.items.map(\.item.uri),
                    itemsToAddToPlaylist.map(\.uri)
                )
                
                return Self.spotify.removeAllOccurencesFromPlaylist(
                    createdPlaylistURI, of: itemsToRemoveFromPlaylist
                )
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.main)
            .flatMap { snapshotId -> AnyPublisher<PlaylistItems, Error> in
                return Self.spotify.playlistItems(createdPlaylistURI)
            }
            .XCTAssertNoFailure()
            .flatMap { playlistItems -> AnyPublisher<Void, Error> in
                
                encodeDecode(playlistItems)
                XCTAssertEqual(
                    playlistItems.items.map(\.item.uri),
                    itemsLeftInPlaylist.map(\.uri)
                )
                
                return Self.spotify.unfollowPlaylistForCurrentUser(
                    createdPlaylistURI
                )
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { }
            )
            .store(in: &Self.cancellables)

        wait(for: [expectation], timeout: 180)
        
    }

    func removeSpecificOccurencesFromPlaylist() {
        
        let itemsToAddToPlaylist: [SpotifyURIConvertible] = [
            URIs.Episodes.seanCarroll111,  // 0
            URIs.Episodes.seanCarroll112,  // 1
            URIs.Tracks.breathe,           // 2
            URIs.Tracks.houseOfCards,      // 3
            URIs.Tracks.illWind,           // 4
            URIs.Episodes.seanCarroll112,  // 5
            URIs.Tracks.houseOfCards,      // 6
            URIs.Tracks.breathe,           // 7
            URIs.Tracks.breathe            // 8
        ]
        
        let itemsToRemoveFromPlaylist = URIsWithPositionsContainer(
            snapshotId: nil,
            urisWithPositions: [
                (uri: URIs.Episodes.seanCarroll112, positions: [1, 5]),
                (uri: URIs.Tracks.breathe, positions: [2, 7]),
                (uri: URIs.Tracks.houseOfCards, positions: [3])
            ]
        )
        
        let itemsLeftInPlaylist: [SpotifyURIConvertible] = [
            URIs.Episodes.seanCarroll111,  // 0
            URIs.Tracks.illWind,           // 4
            URIs.Tracks.houseOfCards,      // 6
            URIs.Tracks.breathe            // 8
        ]
        
        var createdPlaylistURI = ""
        
        let playlistDetails = PlaylistDetails(
            name: "removeSpecificOccurencesFromPlaylist",
            isCollaborative: nil
        )
        encodeDecode(playlistDetails)
        
        let newPlaylistDetails = PlaylistDetails(
            name: "renamed removeSpecificOccurencesFromPlaylist",
            isPublic: false,
            isCollaborative: false,
            description: "programmatically"
        )
        encodeDecode(newPlaylistDetails)
        
        let expectation = XCTestExpectation(
            description: "testRemoveSpecificOccurencesFromPlaylist"
        )
        
        Self.spotify.currentUserProfile()
            .XCTAssertNoFailure()
            .flatMap { user -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                encodeDecode(user)
                return Self.spotify.createPlaylist(
                    for: user.uri, playlistDetails
                )
            }
            .XCTAssertNoFailure()
            .flatMap { playlist -> AnyPublisher<Void, Error> in
        
                encodeDecode(playlist)
                XCTAssertEqual(playlist.name, "removeSpecificOccurencesFromPlaylist")
                if let isPublic = playlist.isPublic {
                    XCTAssertTrue(isPublic)
                }
                else {
                    XCTFail("playlist.isPublic should not be nil")
                }
                XCTAssertFalse(playlist.isCollaborative)
                XCTAssertEqual(playlist.items.items.count, 0)
        
                createdPlaylistURI = playlist.uri
                XCTAssert(createdPlaylistURI.count > 5)
                
                return Self.spotify.changePlaylistDetails(
                    createdPlaylistURI, to: newPlaylistDetails
                )
                
            }
            .XCTAssertNoFailure()
            .flatMap { () -> AnyPublisher<String, Error> in
                
                // add tracks and episodes to the playlist
                return Self.spotify.addToPlaylist(
                    createdPlaylistURI, uris: itemsToAddToPlaylist
                )

            }
            .XCTAssertNoFailure()
            .flatMap { snapshotId -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                // retrieve the playlist
                XCTAssert(createdPlaylistURI.count > 5)
                return Self.spotify.playlist(
                    createdPlaylistURI, market: "US"
                )
            }
            .XCTAssertNoFailure()
            .flatMap { playlist -> AnyPublisher<String, Error> in
        
                encodeDecode(playlist)
                
                XCTAssertEqual(playlist.name, "renamed removeSpecificOccurencesFromPlaylist")
                if let isPublic = playlist.isPublic {
                    XCTAssertFalse(isPublic)
                }
                else {
                    XCTFail("playlist.isPublic should not be nil")
                }
                XCTAssertFalse(playlist.isCollaborative)
                XCTAssertEqual(playlist.description, "programmatically")
                
                let playlistItems = playlist.items.items.map(\.item.uri)
                XCTAssertEqual(
                    playlistItems, itemsToAddToPlaylist.map(\.uri)
                )
        
                return Self.spotify.removeSpecificOccurencesFromPlaylist(
                    createdPlaylistURI, of: itemsToRemoveFromPlaylist
                )
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.main)
            .flatMap { snapshotId -> AnyPublisher<PlaylistItems, Error> in
                return Self.spotify.playlistItems(
                    createdPlaylistURI,
                    limit: 100,
                    offset: 0,
                    market: "US"
                )
            }
            .XCTAssertNoFailure()
            .flatMap { playlistItems -> AnyPublisher<Void, Error> in
        
                encodeDecode(playlistItems)
                XCTAssertEqual(
                    playlistItems.items.map(\.item.uri),
                    itemsLeftInPlaylist.map(\.uri)
                )
        
                return Self.spotify.unfollowPlaylistForCurrentUser(
                    createdPlaylistURI
                )
            }
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { }
            )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 180)
        
    }
    
    func replaceItemsInPlaylist() {
        
        let itemsToAddToPlaylist: [SpotifyURIConvertible] = [
            URIs.Tracks.plants,
            URIs.Tracks.jinx,
            URIs.Tracks.wadingOut,
            URIs.Tracks.plants,
            URIs.Tracks.nuclearFusion,
            URIs.Tracks.odeToViceroy,
            URIs.Episodes.samHarris213,
            URIs.Episodes.samHarris213
        ]
        
        let replacementItems: [SpotifyURIConvertible] = [
            URIs.Tracks.plants,
            URIs.Tracks.jinx,
            URIs.Episodes.samHarris213
        ]
        
        let dateString = Date().description(with: .current)
        
        var createdPlaylistURI = ""
        
        let playlistDetails = PlaylistDetails(
            name: "replaceItemsInPlaylist",
            isPublic: false,
            isCollaborative: true,
            description: dateString
        )
        encodeDecode(playlistDetails)
        
        let expectation = XCTestExpectation(
            description: "testReplaceItemsInPlaylist"
        )
        
        Self.spotify.currentUserProfile()
            .XCTAssertNoFailure()
            .flatMap { user -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                encodeDecode(user)
                return Self.spotify.createPlaylist(
                    for: user.uri, playlistDetails
                )
            }
            .XCTAssertNoFailure()
            .flatMap { playlist -> AnyPublisher<String, Error> in
        
                encodeDecode(playlist)
                XCTAssertEqual(playlist.name, "replaceItemsInPlaylist")
                XCTAssertEqual(playlist.items.items.count, 0)
                XCTAssertTrue(playlist.isCollaborative)
                if let isPublic = playlist.isPublic {
                    XCTAssertFalse(isPublic)
                }
                else {
                    XCTFail("playlist.isPublic should not be nil")
                }
                XCTAssertEqual(playlist.description, dateString)
                createdPlaylistURI = playlist.uri
                XCTAssert(createdPlaylistURI.count > 5)
                
                return Self.spotify.addToPlaylist(
                    createdPlaylistURI,
                    uris: itemsToAddToPlaylist,
                    position: 0
                )
                
            }
            .XCTAssertNoFailure()
            .flatMap { snapshotId -> AnyPublisher<PlaylistItems, Error> in
                // retrieve the playlist
                return Self.spotify.playlistItems(
                    createdPlaylistURI,
                    limit: 32,
                    offset: 0
                )
            }
            .XCTAssertNoFailure()
            .flatMap { playlistItems -> AnyPublisher<String, Error> in
                
                let tracks = playlistItems.items.map(\.item.uri)
                XCTAssertEqual(tracks, itemsToAddToPlaylist.map(\.uri))

                return Self.spotify.replaceAllPlaylistItems(
                    createdPlaylistURI, with: replacementItems
                )
         
            }
            .XCTAssertNoFailure()
            .flatMap { snapshotId -> AnyPublisher<PlaylistItems, Error> in
                // retrieve the playlist
                return Self.spotify.playlistItems(
                    createdPlaylistURI,
                    limit: 69,
                    offset: 0,
                    market: "US"
                )
            }
            .XCTAssertNoFailure()
            .flatMap { playlistItems -> AnyPublisher<String, Error> in
                
                let tracks = playlistItems.items.map(\.item.uri)
                XCTAssertEqual(tracks, replacementItems.map(\.uri))

                return Self.spotify.replaceAllPlaylistItems(
                    createdPlaylistURI, with: []
                )
            }
            .XCTAssertNoFailure()
            .flatMap { snapshotId -> AnyPublisher<PlaylistItems, Error> in
                // retrieve the playlist
                return Self.spotify.playlistItems(
                    createdPlaylistURI,
                    limit: 69,
                    offset: 0,
                    market: "US"
                )
            }
            .XCTAssertNoFailure()
            .flatMap { playlistItems -> AnyPublisher<Void, Error> in
             
                XCTAssertEqual(playlistItems.items.count, 0)
                XCTAssertEqual(playlistItems.total, 0)
                return Self.spotify.unfollowPlaylistForCurrentUser(
                    createdPlaylistURI
                )
                
            }
            .XCTAssertNoFailure()
            .delay(for: 1, scheduler: DispatchQueue.main)
            .flatMap {
                // get all of the current user's playlists
                // MARK: Get all of the user's playlists
                Self.spotify.currentUserPlaylists()
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { playlists in
                    encodeDecode(playlists)
                    XCTAssertFalse(
                        // ensure the user is no longer following the playlist
                        // because we just unfollowed it
                        // MARK: Ensure the playlist is no longer being followed
                        playlists.items.map(\.uri).contains(createdPlaylistURI)
                    )
                }
            )
            .store(in: &Self.cancellables)
        
        wait(for: [expectation], timeout: 300)
        
    }
    
}

class SpotifyAPIAuthorizationCodeFlowPlaylistsTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIPlaylistsTests
{

    static let allTests = [
        ("testGetCrumbPlaylist", testGetCrumbPlaylist),
        ("testGetCrumPlaylistTracks", testGetCrumbPlaylistTracks),
        ("testFilteredPlaylist", testFilteredPlaylist),
        ("testOtherUserCurrentPlaylists", testOtherUserCurrentPlaylists),
        (
            "testCreatePlaylistAndAddTracksThenUnfollowIt",
            testCreatePlaylistAndAddTracksThenUnfollowIt
        ),
        (
            "testCreatePlaylistAddRemoveReorderItems",
            testCreatePlaylistAddRemoveReorderItems
        ),
        ("testPlaylistCoverImage", testPlaylistCoverImage),
        (
            "testRemoveAllOccurencesFromPlaylist",
            testRemoveAllOccurencesFromPlaylist
        ),
        (
            "testRemoveSpecificOccurencesFromPlaylist",
            testRemoveSpecificOccurencesFromPlaylist
        ),
        ("testReplaceItemsInPlaylist", testReplaceItemsInPlaylist)
    ]
    
    func testGetCrumbPlaylist() { getCrumbPlaylist() }
    func testGetCrumbPlaylistTracks() { getCrumbPlaylistTracks() }
    func testFilteredPlaylist() { filteredPlaylist() }
    func testOtherUserCurrentPlaylists() { otherUserCurrentPlaylists() }
    func testCreatePlaylistAndAddTracksThenUnfollowIt() {
        createPlaylistAndAddTracksThenUnfollowIt()
    }
    func testCreatePlaylistAddRemoveReorderItems() {
        createPlaylistAddRemoveReorderItems()
    }
    func testPlaylistCoverImage() { playlistCoverImage() }
    func testRemoveAllOccurencesFromPlaylist() {
        removeAllOccurencesFromPlaylist()
    }
    func testRemoveSpecificOccurencesFromPlaylist() {
        removeSpecificOccurencesFromPlaylist()
    }
    func testReplaceItemsInPlaylist() { replaceItemsInPlaylist() }

}

final class SpotifyAPIClientCredentialsFlowPlaylistsTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIPlaylistsTests
{

    static let allTests = [
        ("testGetCrumbPlaylist", testGetCrumbPlaylist),
        ("testGetCrumPlaylistTracks", testGetCrumbPlaylistTracks),
        ("testFilteredPlaylist", testFilteredPlaylist),
        ("testOtherUserCurrentPlaylists", testOtherUserCurrentPlaylists)
    ]
    
    func testGetCrumbPlaylist() { getCrumbPlaylist() }
    func testGetCrumbPlaylistTracks() { getCrumbPlaylistTracks() }
    func testFilteredPlaylist() { filteredPlaylist() }
    func testOtherUserCurrentPlaylists() { otherUserCurrentPlaylists() }

}


