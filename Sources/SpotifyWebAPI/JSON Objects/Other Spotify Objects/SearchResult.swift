import Foundation

/**
 The json response from the [search][1] endpoint.
 
 **Beta Note**: Currently only supports artists, albums, and tracks.
 
 The search endpoint has a `types` parameter, which specifies
 which objects will be returned in the response.
 Valid types:
 
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
 be nil if it was not requested in the search.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/search/search/
 */
public struct SearchResult: Hashable {
 
    /// A Paging object containing full `artist` objects.
    public let artists: PagingObject<Artist>?

    /// A Paging object containing simplified `album` objects.
    public let albums: PagingObject<Album>?

    /// A Paging object containing full `artist` objects.
    public let tracks: PagingObject<Track>?
    
    
}

extension SearchResult: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case artists, albums, tracks
    }
}
