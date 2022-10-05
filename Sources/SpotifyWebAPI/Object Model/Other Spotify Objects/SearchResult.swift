import Foundation

/**
 The response from the search endpoint:
 ``SpotifyAPI/search(query:categories:market:limit:offset:includeExternal:)``.

 The search endpoint has a `categories` parameter, which specifies which objects
 will be returned in the response. Valid categories are:
 
 * ``IDCategory/album``
 * ``IDCategory/artist``
 * ``IDCategory/playlist``
 * ``IDCategory/track``
 * ``IDCategory/show``
 * ``IDCategory/episode``
 * ``IDCategory/audiobook``
 
 The corresponding ``albums``, ``artists``, ``playlists``, ``tracks``,
 ``shows``, ``episodes``, and ``audiobooks`` properties of this struct will be
 non-`nil` for each of the categories that were requested from the
 ``SpotifyAPI/search(query:categories:market:limit:offset:includeExternal:)``
 endpoint.

 If no results were found for a category, then the ``PagingObject/items``
 property of the property's paging object will be empty; the property itself
 will only be `nil` if it was not requested in the search.
 
 Read more at the [Spotify web API reference][1].

 [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/search
 */
public struct SearchResult: Hashable {
    
    /// A ``PagingObject`` containing full ``Artist`` objects.
    public let artists: PagingObject<Artist>?

    /// A ``PagingObject`` containing simplified ``Album`` objects.
    public let albums: PagingObject<Album>?

    /// A ``PagingObject`` containing full ``Track`` objects.
    public let tracks: PagingObject<Track>?
    
    /// A ``PagingObject`` containing simplified ``Playlist`` objects.
    public let playlists: PagingObject<Playlist<PlaylistItemsReference>>?
    
    /// A ``PagingObject`` containing simplified ``Episode`` objects.
    public let episodes: PagingObject<Episode?>?
    
    /// A ``PagingObject`` containing simplified ``Show`` objects.
    public let shows: PagingObject<Show?>?
    
    /// A ``PagingObject`` containing simplified ``Audiobook`` objects.
    public let audiobooks: PagingObject<Audiobook?>?

    /**
     Creates the response from the search endpoint.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - artists: A ``PagingObject`` containing full ``Artist`` objects.
       - albums: A ``PagingObject`` containing simplified ``Album`` objects.
       - tracks: A ``PagingObject`` containing full ``Track`` objects.
       - playlists: A ``PagingObject`` containing simplified ``Playlist``
             objects.
       - episodes: A ``PagingObject`` containing simplified ``Episode`` objects.
       - shows: A ``PagingObject`` containing simplified ``Show`` objects.
       - audiobooks: A ``PagingObject`` containing simplified ``Audiobook``
             objects.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/search
     */
    public init(
        artists: PagingObject<Artist>? = nil,
        albums: PagingObject<Album>? = nil,
        tracks: PagingObject<Track>? = nil,
        playlists: PagingObject<Playlist<PlaylistItemsReference>>? = nil,
        episodes: PagingObject<Episode?>? = nil,
        shows: PagingObject<Show?>? = nil,
        audiobooks: PagingObject<Audiobook?>? = nil
    ) {
        self.artists = artists
        self.albums = albums
        self.tracks = tracks
        self.playlists = playlists
        self.episodes = episodes
        self.shows = shows
        self.audiobooks = audiobooks
    }

}

extension SearchResult: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case artists
        case albums
        case tracks
        case playlists
        case episodes
        case shows
        case audiobooks
    }
}

extension SearchResult: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.

     Dates are compared using `timeIntervalSince1970`, so they are considered
     floating point properties for the purposes of this method.

     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
     
        return self.artists == other.artists &&
                self.playlists == other.playlists &&
                self.albums.isApproximatelyEqual(to: other.albums) &&
                self.tracks.isApproximatelyEqual(to: other.tracks) &&
                self.episodes.isApproximatelyEqual(to: other.episodes) &&
                self.shows.isApproximatelyEqual(to: other.shows)  &&
                self.audiobooks.isApproximatelyEqual(to: other.audiobooks)

    }

}
