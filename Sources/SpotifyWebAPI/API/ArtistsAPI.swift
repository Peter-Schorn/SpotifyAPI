import Foundation
import Combine

// MARK: Artists

public extension SpotifyAPI {
    
    /**
     Get a single artist.
     
     No scopes are required for this endpoint.
    
     See also `artists(uris:)` (gets several artists).

     Read more at the [Spotify web API reference][1].
    
     - Parameter artist: The URI for the artist.
     - Returns: The full version of an [artist][2].

     [1]: https://developer.spotify.com/documentation/web-api/reference/artists/get-artist/
     [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-full
     */
    func artist(
        _ artist: SpotifyURIConvertible
    ) -> AnyPublisher<Artist, Error>  {
        
        do {
            let artistId = try SpotifyIdentifier(uri: artist).id
            
            return self.getRequest(
                path: "/artists/\(artistId)",
                queryItems: [:],
                requiredScopes: []
            )
            .spotifyDecode(Artist.self)
            
        } catch {
            return error.anyFailingPublisher(Artist.self)
        }
        
    }
    
    /**
     Get several artists.
     
     No scopes are required for this endpoint.

     See also `artist(uri:)` (gets a single artist).

     Objects are returned in the order requested.
     If an object is not found, a nill value is returned in the
     appropriate position. Duplicate ids in the query will result
     in duplicate objects in the response.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter artists: An array of up to 20 URIs for artists.
     - Returns: An array of the full versions of [artists][2].
           Artists are returned in the order requested. If an artist
           is not found, `nil` is returned in the corresponding position.
           Duplicate artists in the request will result in duplicate artists
           in the response.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/artists/get-several-artists/
     [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-full
     */
    func artists(
        _ artists: [SpotifyURIConvertible]
    ) -> AnyPublisher<[Artist?], Error> {
        
        do {

            let albumIdsString = try SpotifyIdentifier
                    .commaSeparatedIdsString(artists)
            
            return self.getRequest(
                path: "/artists",
                queryItems: ["ids": albumIdsString],
                requiredScopes: []
            )
            .spotifyDecode([String: [Artist?]].self)
            .tryMap { dict -> [Artist?] in
                if let artists = dict["artists"] {
                    return artists
                }
                throw SpotifyLocalError.topLevelKeyNotFound(
                    key: "artists", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher([Artist?].self)
        }
        
    }
    

    /**
     Get an artist's albums
     
     See also `album(_:market:)` (gets a single album) and
     `albums(_:market:)` (gets several albums).
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - artist: The URI of an artist.
       - groups: *Optional*. The types of albums to return.
             Possible values are `album`, `single`, `appearsOn`, and
             `compilation`. If `nil`, then all types will be returned.
       - country: *Optional*. An [ISO 3166-1 alpha-2 country code][2] or the
             string "from_token". Supply this parameter to limit the response to
             one particular geographical market. For example, for albums available
             in Sweden: "SE". If not given, results will be returned for all
             countries and you are likely to get duplicate results per album,
             one for each country in which the album is available!
       - limit: *Optional*. The number of album objects to return.
             Default: 20; Minimum: 1; Maximum: 50.
       - offset: *Optional*. The index of the first album to return.
             Default: 0. Use with `limit` to get the next set of albums
     - Returns: An array of simplified album objects wrapped in a paging
           object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/artists/get-artists-albums/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func artistAlbums(
        _ artist: SpotifyURIConvertible,
        groups: [AlbumGroup]? = nil,
        country: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<PagingObject<Album>, Error> {
        
        do {
            
            let artistId = try SpotifyIdentifier(uri: artist).id
            
            return self.getRequest(
                path: "/artists/\(artistId)/albums",
                queryItems: [
                    "include_groups": groups?.commaSeparatedString(),
                    "country": country,
                    "limit": limit,
                    "offset": offset
                ],
                requiredScopes: []
            )
            .spotifyDecode(PagingObject<Album>.self)
            
        } catch {
            return error.anyFailingPublisher(PagingObject<Album>.self)
        }
        
    }
    
    /**
     Get the top tracks for an artist.

     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - artist: The URI of an artist.
       - country: *Required*. An [ISO 3166-1 alpha-2 country code][2]
             or the string "from_token".
     - Returns: The full versions of up to ten tracks.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/artists/get-artists-top-tracks/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func artistTopTracks(
        _ artist: SpotifyURIConvertible,
        country: String
    ) -> AnyPublisher<[Track], Error> {
        
        do {
            
            let artistId = try SpotifyIdentifier(uri: artist).id
            
            return self.getRequest(
                path: "/artists/\(artistId)/top-tracks",
                queryItems: ["country": country],
                requiredScopes: []
            )
            .spotifyDecode([String: [Track]].self)
            .tryMap { dict -> [Track] in
                if let tracks = dict["tracks"] {
                    return tracks
                }
                throw SpotifyLocalError.topLevelKeyNotFound(
                    key: "tracks", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher([Track].self)
        }
        
    }
    
    /**
     Get the related artists for an artist.
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter artist: The URI of an artist.
     - Returns: The full versions of up to 20 artists.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/artists/get-related-artists/
     */
    func relatedArtists(
        _ artist: SpotifyURIConvertible
    ) -> AnyPublisher<[Artist], Error> {
        
        do {
            
            let artistId = try SpotifyIdentifier(uri: artist).id
            
            return self.getRequest(
                path: "/artists/\(artistId)/related-artists",
                queryItems: [:],
                requiredScopes: []
            )
            .spotifyDecode([String: [Artist]].self)
            .tryMap { dict -> [Artist] in
                if let artists = dict["artists"] {
                    return artists
                }
                throw SpotifyLocalError.topLevelKeyNotFound(
                    key: "artists", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher([Artist].self)
        }
        
    }
    
}
