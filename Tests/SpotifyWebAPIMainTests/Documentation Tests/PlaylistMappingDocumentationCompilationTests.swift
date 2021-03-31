import Foundation
import SpotifyWebAPI

// These methods exist to ensure that they compile.
// They are not meant to be called.

private extension SpotifyAPI {
    
    func _testPlaylistMapping() {
        
        _ = self.playlist("")
            .sinkIgnoringCompletion{ (playlist: Playlist<PlaylistItems>) in
                let playlistItems: [PlaylistItem] = playlist.items.items.compactMap(\.item)
                _ = playlistItems
            }
        
    }
    
    func _testPlaylistTracksMapping() {
        
        _ = self.playlistTracks("")
            .sinkIgnoringCompletion { (playlistTracks: PlaylistTracks) in
                let tracks: [Track] = playlistTracks.items.compactMap(\.item)
                _ = tracks
            }
        
    }
    
    func _testPlaylistItemsMapping() {
        
        _ = self.playlistItems("")
            .sinkIgnoringCompletion { (playlistItems: PlaylistItems) in
                let items: [PlaylistItem] = playlistItems.items.compactMap(\.item)
                _ = items
            }
        
    }
    
    func _testUserPlaylistsMapping() {
        
        _ = self.userPlaylists(for: "")
            .sinkIgnoringCompletion { (playlists: PagingObject<Playlist<PlaylistItemsReference>>) in
                let uris: [String] = playlists.items.map(\.uri)
                _ = uris
            }

    }
    
}

private extension SpotifyAPI where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{

    func _testCurrentUserPlaylistsMapping() {
        
        _ = self.currentUserPlaylists()
            .sinkIgnoringCompletion { (playlists: PagingObject<Playlist<PlaylistItemsReference>>) in
                let uris: [String] = playlists.items.map(\.uri)
                _ = uris
            }

    }
    
    
}

