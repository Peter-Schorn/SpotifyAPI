import Foundation

/// The tracks in a playlist.
public typealias PlaylistTracks = PagingObject<PlaylistItemContainer<Track>>

/// The episodes and tracks in a playlist.
public typealias PlaylistItems = PagingObject<PlaylistItemContainer<PlaylistItem>>
