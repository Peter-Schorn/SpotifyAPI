import Foundation

/// The tracks in a playlist. Each `Track` is optional.
public typealias PlaylistTracks = PagingObject<PlaylistItemContainer<Track>>

/// The episodes and tracks in a playlist. each `PlaylistItem` is optional.
public typealias PlaylistItems = PagingObject<PlaylistItemContainer<PlaylistItem>>
