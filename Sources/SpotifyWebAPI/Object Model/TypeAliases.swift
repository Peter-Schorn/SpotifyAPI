
/// The tracks in a playlist. Each ``Track`` is optional.
public typealias PlaylistTracks = PagingObject<PlaylistItemContainer<Track>>

/// The episodes and tracks in a playlist. each ``PlaylistItem`` is optional.
public typealias PlaylistItems = PagingObject<PlaylistItemContainer<PlaylistItem>>

/// A track saved in the user's "Your Music" library.
public typealias SavedTrack = SavedItem<Track>

/// An album saved in the user's "Your Music" library.
public typealias SavedAlbum = SavedItem<Album>

/// A show saved in the user's "Your Music" library.
public typealias SavedShow = SavedItem<Show>

/// An episode saved in the user's "Your Music" library.
public typealias SavedEpisode = SavedItem<Episode>
