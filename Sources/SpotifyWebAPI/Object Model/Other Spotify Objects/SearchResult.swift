import Foundation

/**
 The response from the [search][1] endpoint:
 ``SpotifyAPI/search(query:categories:market:limit:offset:includeExternal:)``.

 The search endpoint has a `categories` parameter, which specifies which objects
 will be returned in the response. Valid categories are:
 
 * ``IDCategory/album``
 * ``IDCategory/artist``
 * ``IDCategory/playlist``
 * ``IDCategory/track``
 * ``IDCategory/show``
 * ``IDCategory/episode``
 
 The corresponding ``albums``, ``artists``, ``playlists``, ``tracks``,
 ``shows``, and ``episodes`` properties of this struct will be non-`nil` for
 each of the categories that were requested from the
 ``SpotifyAPI/search(query:categories:market:limit:offset:includeExternal:)``
 endpoint.

 If no results were found for a category, then the ``PagingObject/items``
 property of the property's paging object will be empty; the property itself
 will only be `nil` if it was not requested in the search.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/search
 */
public struct SearchResult: Hashable, Paginated {
    
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
    
    /**
     The URL (href) to the next page of items or `nil` if none in this
     ``SearchResult``.
    
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in
     ``SearchResult`` to retrieve the results.
     
     See <doc:Working-with-Paginated-Results>.
     */
    public var next: URL? = nil

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
       - next: The URL (href) to the next page of items or `nil` if none.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/search
     */
    public init(
        artists: PagingObject<Artist>? = nil,
        albums: PagingObject<Album>? = nil,
        tracks: PagingObject<Track>? = nil,
        playlists: PagingObject<Playlist<PlaylistItemsReference>>? = nil,
        episodes: PagingObject<Episode?>? = nil,
        shows: PagingObject<Show?>? = nil,
        next: URL? = nil
    ) {
        self.artists = artists
        self.albums = albums
        self.tracks = tracks
        self.playlists = playlists
        self.episodes = episodes
        self.shows = shows
        self.next = next
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
        case next
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
                self.next == other.next &&
                self.albums.isApproximatelyEqual(to: other.albums) &&
                self.tracks.isApproximatelyEqual(to: other.tracks) &&
                self.episodes.isApproximatelyEqual(to: other.episodes) &&
                self.shows.isApproximatelyEqual(to: other.shows)

    }

}
