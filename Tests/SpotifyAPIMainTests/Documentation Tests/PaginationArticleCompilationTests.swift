import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import SpotifyWebAPI



private func testArtistAlbums<AuthorizationManager: SpotifyAuthorizationManager>(
    spotifyAPI: SpotifyAPI<AuthorizationManager>
) {
    
    var cancellables: Set<AnyCancellable> = []

    let artist = "spotify:artist:0k17h0D3J5VfsdmQ1iZtE9"

    spotifyAPI.artistAlbums(artist, country: "US", limit: 10)
        .extendPages(spotifyAPI, maxExtraPages: 2)
        .sink(
            receiveCompletion: { completion in
                print("completion: \(completion)")
            },
            receiveValue: { albumsPage in
                print(
                    """

                    received page of albums:
                    ------------------------
                    """
                )
                for album in albumsPage.items {
                    print(album.name)
                }
            }
        )
        .store(in: &cancellables)

}

#if canImport(Combine)

private func testPlaylistItems<AuthorizationManager: SpotifyAuthorizationManager>(
    spotifyAPI: SpotifyAPI<AuthorizationManager>
) {
    
    var cancellables: Set<AnyCancellable> = []

    let playlist = "spotify:playlist:37i9dQZF1DWXRqgorJj26U"

    spotifyAPI.playlistItems(playlist, limit: 5, market: "US")
        .extendPagesConcurrently(spotifyAPI, maxExtraPages: 5)
        .sink(
            receiveCompletion: { completion in
                print("completion: \(completion)")
            },
            receiveValue: { playlistItemsPage in
                print(
                    """

                    received \(playlistItemsPage.items.count) tracks:
                    ------------------------
                    """
                )
                for track in playlistItemsPage.items.compactMap(\.item) {
                    print(track.name)
                }
            }
        )
        .store(in: &cancellables)
    
}

private func testAlbumTracks<AuthorizationManager: SpotifyAuthorizationManager>(
    spotifyAPI: SpotifyAPI<AuthorizationManager>
) {
    
    var cancellables: Set<AnyCancellable> = []

    let album = "spotify:album:5iT3F2EhjVQVrO4PKhsP8c"

    spotifyAPI.albumTracks(album, market: "US", limit: 20)
        .extendPagesConcurrently(spotifyAPI)
        .collectAndSortByOffset()
        .sink(
            receiveCompletion: { completion in
                print("completion: \(completion)")
            },
            receiveValue: { tracks in
                print("received \(tracks.count) tracks:")
                for track in tracks {
                    print(track.name)
                }
            }
        )
        .store(in: &cancellables)
    
}

#endif

private func testNextHref<AuthorizationManager: SpotifyScopeAuthorizationManager>(
    spotifyAPI: SpotifyAPI<AuthorizationManager>
) {
    
    var cancellables: Set<AnyCancellable> = []

    let dispatchGroup = DispatchGroup()
    
    /// The full URL to the next page of results
    var nextHref: URL? = nil

    dispatchGroup.enter()
    spotifyAPI.currentUserTopArtists()
        .sink(
            receiveCompletion: { completion in
                print("completion: \(completion)")
                dispatchGroup.leave()
            },
            receiveValue: { artistsPage in
                print("received \(artistsPage.items.count) artists:")
                for artist in artistsPage.items {
                    print(artist.name)
                }
                // MARK: Retrieve the next property of the paging object
                nextHref = artistsPage.next
                
            }
        )
        .store(in: &cancellables)

    dispatchGroup.wait()
    
    // request the next page if `nextHref` is non-`nil`.
    if let nextHref = nextHref {
        
        print("\n\nrequesting next page of artists")
        dispatchGroup.enter()
        spotifyAPI.getFromHref(
            nextHref,
            responseType: PagingObject<Artist>.self
        )
        .sink(
            receiveCompletion: { completion in
                print("completion: \(completion)")
                dispatchGroup.leave()
            },
            receiveValue: { artistsPage in
                print("received \(artistsPage.items.count) artists:")
                for artist in artistsPage.items {
                    print(artist.name)
                }
                
            }
        )
        .store(in: &cancellables)
        dispatchGroup.wait()
        
    }
    
}
