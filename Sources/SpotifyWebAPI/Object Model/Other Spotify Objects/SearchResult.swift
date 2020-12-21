import Foundation

/**
 The response from the [search][1] endpoint:
 `SpotifyAPI.search(query:categories:market:limit:offset:includeExternal:)`.
 
 The search endpoint has a `categories` parameter, which specifies
 which objects will be returned in the response. Valid categories are:
 
 * `album`
 * `artist`
 * `playlist`
 * `track`
 * `show`
 * `episode`
 
 The corresponding `albums`, `artist`, `playlists`, `tracks`, `shows`,
 and `episodes` properties of this struct will be non-`nil`
 for each of the categories that were requested from the `search` endpoint.
 
 If no results were found for a category, then the `items` property of the
 property's paging object will be empty; the property itself will only
 be `nil` if it was not requested in the search.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/search/search/
 */
public struct SearchResult: Hashable {
    
    /// A `PagingObject` containing full `Artist` objects.
    public let artists: PagingObject<Artist>?

    /// A `PagingObject` containing simplified `Album` objects.
    public let albums: PagingObject<Album>?

    /// A `PagingObject` containing full `Track` objects.
    public let tracks: PagingObject<Track>?
    
    /// A `PagingObject` containing simplified `Playlist` objects.
    public let playlists: PagingObject<Playlist<PlaylistsItemsReference>>?
    
    /// A `PagingObject` containing simplified `Episode` objects.
    public let episodes: PagingObject<Episode?>?
    
    /// A `PagingObject` containing simplified `Show` objects.
    public let shows: PagingObject<Show?>?
    
    /**
     Creates the response from the [search][1] endpoint.
     
     - Parameters:
       - artists: A `PagingObject` containing full `Artist` objects.
       - albums: A `PagingObject` containing simplified `Album` objects.
       - tracks: A `PagingObject` containing full `Track` objects.
       - playlists: A `PagingObject` containing simplified `Playlist` objects.
       - episodes: A `PagingObject` containing simplified `Episode` objects.
       - shows: A `PaginObject` containing simplified `Show` objects.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/search/search/
     */
    public init(
        artists: PagingObject<Artist>? = nil,
        albums: PagingObject<Album>? = nil,
        tracks: PagingObject<Track>? = nil,
        playlists: PagingObject<Playlist<PlaylistsItemsReference>>? = nil,
        episodes: PagingObject<Episode?>? = nil,
        shows: PagingObject<Show?>? = nil
    ) {
        self.artists = artists
        self.albums = albums
        self.tracks = tracks
        self.playlists = playlists
        self.episodes = episodes
        self.shows = shows
    }

}

extension SearchResult: Codable {
    
    /// :nodoc:
    public enum CodingKeys: String, CodingKey {
        case artists
        case albums
        case tracks
        case playlists
        case episodes
        case shows
    }
}
