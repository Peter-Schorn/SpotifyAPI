import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public extension SpotifyAPI {

    // MARK: Artists
    
    /**
     Get a single artist.
     
     No scopes are required for this endpoint.
    
     See also ``artists(_:)`` - gets multiple artists

     Read more at the [Spotify web API reference][1].
    
     - Parameter uri: The URI for the artist.
     - Returns: The full version of an artist.

     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-an-artist
     */
    func artist(
        _ uri: SpotifyURIConvertible
    ) -> AnyPublisher<Artist, Error>  {
        
        do {
            let id = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.artist]
            ).id
            
            return self.getRequest(
                path: "/artists/\(id)",
                queryItems: [:],
                requiredScopes: []
            )
            .decodeSpotifyObject(Artist.self)
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Get multiple artists.
     
     No scopes are required for this endpoint.

     See also: ``artist(_:)`` - gets a single artist

     Read more at the [Spotify web API reference][1].
     
     - Parameter uris: An array of up to 20 URIs for artists. Passing in an
           empty array will immediately cause an empty array of results to be
           returned without a network request being made.
     - Returns: An array of the full versions of artists. Artists are
           returned in the order requested. If an artist is not found, `nil` is
           returned in the corresponding position. Duplicate artists in the
           request will result in duplicate artists in the response.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-multiple-artists
     */
    func artists(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<[Artist?], Error> {
        
        do {

            if uris.isEmpty {
                return ResultPublisher([])
                    .eraseToAnyPublisher()
            }
            
            let idsString = try SpotifyIdentifier
                .commaSeparatedIdsString(
                    uris, ensureCategoryMatches: [.artist]
                )
            
            return self.getRequest(
                path: "/artists",
                queryItems: ["ids": idsString],
                requiredScopes: []
            )
            .decodeSpotifyObject([String: [Artist?]].self)
            .tryMap { dict -> [Artist?] in
                if let artists = dict["artists"] {
                    return artists
                }
                throw SpotifyGeneralError.topLevelKeyNotFound(
                    key: "artists", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Get an artist's albums.
     
     See also:
     
     * ``album(_:market:)`` - gets a single album
     * ``albums(_:market:)`` - gets multiple albums
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - artist: The URI of an artist.
       - groups: The types of albums to return. Possible values are
             ``AlbumType/album``, ``AlbumType/single``, ``AlbumType/appearsOn``,
             and ``AlbumType/compilation``. If `nil`, then all types will be
             returned.
       - country: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". Supply this parameter to limit the response to one
             particular geographical market. For example, for albums available
             in Sweden: "SE". If not given, results will be returned for all
             countries and you are likely to get duplicate results per album,
             one for each country in which the album is available!
       - limit: The number of album objects to return. Default: 20; Minimum: 1;
             Maximum: 50.
       - offset: The index of the first album to return. Default: 0. Use with
             `limit` to get the next set of albums.
     - Returns: An array of simplified album objects wrapped in a paging object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-an-artists-albums
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func artistAlbums(
        _ artist: SpotifyURIConvertible,
        groups: [AlbumType]? = nil,
        country: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<PagingObject<Album>, Error> {
        
        do {
            
            let artistId = try SpotifyIdentifier(
                uri: artist, ensureCategoryMatches: [.artist]
            ).id
            
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
            .decodeSpotifyObject(PagingObject<Album>.self)
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Get the top tracks for an artist.

     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - artist: The URI of an artist.
       - country: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token".
     - Returns: The full versions of up to ten tracks.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-an-artists-top-tracks
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func artistTopTracks(
        _ artist: SpotifyURIConvertible,
        country: String
    ) -> AnyPublisher<[Track], Error> {
        
        do {
            
            let artistId = try SpotifyIdentifier(
                uri: artist, ensureCategoryMatches: [.artist]
            ).id
            
            return self.getRequest(
                path: "/artists/\(artistId)/top-tracks",
                queryItems: ["country": country],
                requiredScopes: []
            )
            .decodeSpotifyObject([String: [Track]].self)
            .tryMap { dict -> [Track] in
                if let tracks = dict["tracks"] {
                    return tracks
                }
                throw SpotifyGeneralError.topLevelKeyNotFound(
                    key: "tracks", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Get the related artists for an artist.
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter artist: The URI of an artist.
     - Returns: The full versions of up to 20 artists.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-an-artists-related-artists
     */
    func relatedArtists(
        _ artist: SpotifyURIConvertible
    ) -> AnyPublisher<[Artist], Error> {
        
        do {
            
            let artistId = try SpotifyIdentifier(
                uri: artist, ensureCategoryMatches: [.artist]
            ).id
            
            return self.getRequest(
                path: "/artists/\(artistId)/related-artists",
                queryItems: [:],
                requiredScopes: []
            )
            .decodeSpotifyObject([String: [Artist]].self)
            .tryMap { dict -> [Artist] in
                if let artists = dict["artists"] {
                    return artists
                }
                throw SpotifyGeneralError.topLevelKeyNotFound(
                    key: "artists", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
}
