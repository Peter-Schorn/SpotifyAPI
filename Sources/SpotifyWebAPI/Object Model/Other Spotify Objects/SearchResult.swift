import Foundation

/**
 The Response from the [search][1] endpoint.
 
 The search endpoint has a `types` parameter, which specifies
 which objects will be returned in the response.
 Valid types are:
 
 * album
 * artist
 * playlist
 * track
 * show
 * episode
 
 The corresponding `albums`, `artist`, `playlists`, `tracks`, `shows`,
 and `episodes` properties of this struct will be non-nil
 for each of the types that were requested from the `search` endpoint.
 
 If no results were found for a type, then the `items` property of the
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
    public let episodes: PagingObject<Episode>?
    
    /// A `PaginObject` containing simplified `Show` objects.
    public let shows: PagingObject<Show>?
    
}

extension SearchResult: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case artists
        case albums
        case tracks
        case playlists
        case episodes
        case shows
    }
}
