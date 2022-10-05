import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public extension SpotifyAPI {
    
    // MARK: Albums
    
    /**
     Get an album.
     
     See also ``artistAlbums(_:groups:country:limit:offset:)`` and
     ``albums(_:market:)`` (gets multiple albums).
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - album: The URI for an album.
       - market: *An [ISO 3166-1 alpha-2 country code][2] or the
             string "from_token". Provide this parameter if you want to apply
             [Track Relinking][3].
     - Returns: The full version of an album.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-an-album
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    func album(
        _ album: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<Album, Error> {
        
        do {
            
            let albumId = try SpotifyIdentifier(
                uri: album, ensureCategoryMatches: [.album]
            ).id
            
            return self.getRequest(
                path: "/albums/\(albumId)",
                queryItems: ["market": market],
                requiredScopes: []
            )
            .decodeSpotifyObject(Album.self)
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Get multiple albums.
     
     See also ``artistAlbums(_:groups:country:limit:offset:)`` and
     ``album(_:market:)`` (gets a single album).
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - albums: An array of up to 20 URIs for albums. Passing in an empty array
             will immediately cause an empty array of results to be returned
             without a network request being made.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". Provide this parameter if you want to apply [Track
             Relinking][3].
     - Returns: An array of the full versions of up to 20 album objects.
           Albums are returned in the order requested. If an album is not found,
           `nil` is returned in the corresponding position. Duplicate albums in
           the request will result in duplicate albums in the response.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-multiple-albums
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    func albums(
        _ albums: [SpotifyURIConvertible],
        market: String? = nil
    ) -> AnyPublisher<[Album?], Error> {
        
        do {
            
            if albums.isEmpty {
                return ResultPublisher([])
                    .eraseToAnyPublisher()
            }
            
            let albumsIdsString = try SpotifyIdentifier
                .commaSeparatedIdsString(
                    albums, ensureCategoryMatches: [.album]
                )
            
            return self.getRequest(
                path: "/albums",
                queryItems: ["ids": albumsIdsString],
                requiredScopes: []
            )
            .decodeSpotifyObject([String: [Album?]].self)
            .tryMap { dict -> [Album?] in
                if let albums = dict["albums"] {
                    return albums
                }
                throw SpotifyGeneralError.topLevelKeyNotFound(
                    key: "albums", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Get the tracks for an album.
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - album: The URI for an album.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". Provide this parameter if you want to apply [Track
             Relinking][3].
       - limit: The maximum number of tracks to return. Default: 20; Minimum: 1;
             Maximum: 50.
       - offset: The index of the first track to return. Default: 0. Use with
             `limit` to get the next set of tracks.
     - Returns: An array of simplified track objects, wrapped in a paging
             object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-an-albums-tracks
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    func albumTracks(
        _ album: SpotifyURIConvertible,
        market: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<PagingObject<Track>, Error> {
        
        do {
            
            let albumId = try SpotifyIdentifier(
                uri: album, ensureCategoryMatches: [.album]
            ).id
            
            return self.getRequest(
                path: "/albums/\(albumId)/tracks",
                queryItems: [
                    "market": market,
                    "limit": limit,
                    "offset": offset
                ],
                requiredScopes: []
            )
            .decodeSpotifyObject(PagingObject<Track>.self)
            
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
}
