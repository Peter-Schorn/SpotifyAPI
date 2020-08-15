import Foundation
import Combine
import Logger

// MARK: The methods for retrieving music content (e.g., songs, albums, artists)

public extension SpotifyAPI {
    
    /**
     Gets a single artist.
     
     No scopes are required for this endpoint.
    
     See also `getArtists(uris:)` (gets several artists).

     Read more at the [web API reference][1].
    
     - Parameter uri: The uri for the artist.
     - Returns: The full version of a Spotify [artist object][2].

     [1]: https://developer.spotify.com/documentation/web-api/reference/artists/get-artist/
     [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-full
     */
    func getArtist<URI: SpotifyURIConvertible>(
        uri: URI
    ) -> AnyPublisher<Artist, Error>  {
        
        do {
            let id = try SpotifyIdentifier(uri: uri.uri).id
            
            logger.trace("uri: \(uri)")
            return self.getRequest(
                endpoint: Endpoints.apiEndpoint("/artists/\(id)"),
                requiredScopes: [],
                responseType: Artist.self
            )
            
        } catch {
            return error.anyFailingPublisher(Artist.self)
        }
        
    }
    
    /**
     Gets several artists.
     
     No scopes are required for this endpoint.

     Objects are returned in the order requested.
     If an object is not found, a nill value is returned in the
     appropriate position.
     Duplicate ids in the query will result in duplicate objects in the response.
     
     See also `getArtist(uri:)` (gets a single artist).
     
     - Parameter uri: The uri for the artist.
     - Returns: An array of the full versions of [artist objects][2].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/artists/get-several-artists/
     [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-full
     */
    func getArtists<URI: SpotifyURIConvertible>(
        uris: [URI]
    ) -> AnyPublisher<[Artist?], Error> {
        
        do {

            let idsString = try SpotifyIdentifier
                    .commaSeparatedIdsString(uris)
            
            return self.getRequest(
                endpoint: Endpoints.apiEndpoint(
                    "/artists",
                    queryItems: ["ids": idsString]
                ),
                requiredScopes: [],
                responseType: [String: [Artist?]].self
            )
            .tryMap { dict -> [Artist?] in
                if let artists = dict["artists"] {
                    return artists
                }
                let msg = """
                    SpotifyAPI: getArtists: artists key for
                    top-level dict was missing. raw data:\n
                    \(dict)
                    """
                self.logger.critical("\(msg)")
                throw SpotifyLocalError.other(msg)
            }
            .eraseToAnyPublisher()
            
            
        } catch {
            return error.anyFailingPublisher([Artist?].self)
        }
        
    }
    
    /**
     Get Spotify Catalog information about albums, artists,
     playlists, tracks, shows or episodes that match a keyword string.
     
     No scopes are required for this endpoint—unless the `market`
     parameter is set to "from_token", in which case
     the `userReadPrivate` scope is required.
     
     # Keyword matching
     
     Matching of search keywords is not case-sensitive.
     Operators, however, should be specified in uppercase.
     Unless surrounded by double quotation marks,
     keywords are matched in any order. For example:
     `q=roadhouse blues` matches both "Blues Roadhouse" and
     "Roadhouse of the Blues". `q="roadhouse blues"` matches
     "My Roadhouse Blues" but not "Roadhouse of the Blues".
     
     Searching for playlists returns results where the query keyword(s)
     match any part of the playlist’s name or description.
     Only popular public playlists are returned.
     
     # Operator
     
     The operator NOT can be used to exclude results.
     
     For example: `q=roadhouse NOT blues` returns items that match "roadhouse"
     but excludes those that also contain the keyword “blues”.
     Similarly, the OR operator can be used to broaden the search:
     `q=roadhouse OR blues` returns all the results that include
     either of the terms. Only one OR operator can be used in a query.
     
     *Note:** Operators must be specified in uppercase.
     Otherwise, they are handled as normal keywords to be matched.
     
     # Field filters
     
     By default, results are returned when a match is found
     in any field of the target object type. Searches can be
     made more specific by specifying an album, artist or track
     field filter. To limit the results to a particular year,
     use the field filter year with album, artist, and
     track searches. For example: `bob year:2014` Or with a date range.
     For example: `bob year:1980-2020`. To retrieve only albums released
     in the last two weeks, use the field filter tag:new in album searches.
     
     To retrieve only albums with the lowest 10% popularity, use the
     field filter tag:hipster in album searches. Note: This field filter
     only works with album searches. Depending on object types being
     searched for, other field filters, include genre (applicable to tracks
     and artists), upc, and isrc. Use double quotation marks
     around the genre keyword string if it contains spaces.
     
     - Parameters:
       - query: *Required*. A query string.
       - types: *Required*. An array of id categories. Valid types: `album`,
             `artist`, `playlist`, `track`, `show`, `episode`.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][1]
             or the string "from_token". If a country code is specified,
             only artists, albums, and tracks with content
             that is playable in that market is returned.
             **Note:** Playlist results are not affected by the
             market parameter. If market is set to from_token,
             and a valid access token is specified in the request header,
             only content playable in the country associated with the
             user account, is returned. Users can view the country
             that is associated with their account in the
             [account settings][2]. A user must grant access to the
             `userReadPrivate` scope prior to when the access
             token is issued.
       - limit: *Optional*. Maximum number of results to return.
             Default: 20; Minimum: 1; Maximum: 50. **Note:** The limit is
             applied within each type, not on the total response.
             For example, if the limit value is 3 and the types are
             `artist` and `album`, the response contains up to
             3 artists and 3 albums.
       - offset: *Optional*. The index of the first result to return.
             Default: 0 (the first result). Maximum offset
             (including limit): 2,000. Use with limit to get the
             next page of search results.
       - includeExternal: *Optional*. Possible values: "audio".
         if this is specified, the response will include any relevant
         audio content that is hosted externally. By default external
         content is filtered out from responses.
     
     [1]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [2]: https://www.spotify.com/se/account/overview/
     */
    func search(
        query: String,
        types: [IDCategory],
        market: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        includeExternal: String? = nil
    ) -> Any {
        
        do {
            let validTypes: [IDCategory] = [
                .album, .artist, .playlist, .track, .show, .episode
            ]
            guard types.allSatisfy({ validTypes.contains($0) }) else {
                throw SpotifyLocalError.other(
                    "Valid types for the search endpoint are " +
                    "\(validTypes), but recieved \(types)."
                )
            }
        
            let x = limit.map(String.init)
            
            let queryDict = [
                "q": query,
                "type": types.commaSeparatedString(),
                "market": market,
                "limit": limit.map(String.init),
                "offset": offset.map(String.init),
                "include_external": includeExternal
            ]
            //
            // return self.getRequest(
            //     endpoint: Endpoints.apiEndpoint(
            //         "/search",
            //         queryItems: <#T##[String : String]?#>
            //     ),
            //     requiredScopes: <#T##Set<Scope>#>,
            //     responseType: <#T##CustomDecodable.Protocol#>
            // )
        
        } catch {
            // return error.anyFailingPublisher(<#type#>.self)
        }
        
        fatalError("not implemented")
        
    }
    

}
