import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public extension SpotifyAPI {
    
    // MARK: Search
    
    /**
     Get Spotify Catalog information about albums, artists, playlists, tracks,
     shows or episodes that match a keyword string.

     No scopes are required for this endpoint—unless the `market` parameter is
     set to "from_token", in which case the ``Scope/userReadPrivate`` scope is
     required.

     **Keyword matching**

     Matching of search keywords is not case-sensitive. Operators, however,
     should be specified in uppercase. Unless surrounded by double quotation
     marks, keywords are matched in any order. For example: `roadhouse blues`
     matches both "Blues Roadhouse" and "Roadhouse of the Blues". `"roadhouse
     blues"` (with quotes) matches "My Roadhouse Blues" but not "Roadhouse of
     the Blues".

     Searching for playlists returns results where the query keyword(s) match
     any part of the playlist’s name or description. Only popular public
     playlists are returned.

     **Operator**

     The operator NOT can be used to exclude results.

     For example: `roadhouse NOT blues` returns items that match "roadhouse" but
     excludes those that also contain the keyword “blues”. Similarly, the OR
     operator can be used to broaden the search: `roadhouse OR blues` returns
     all the results that include either of the terms. Only one OR operator can
     be used in a query.

     **Note:** Operators must be specified in uppercase. Otherwise, they are
     handled as normal keywords to be matched.

     **Field filters**

     By default, results are returned when a match is found in any field of the
     target object type. Searches can be made more specific by specifying an
     album, artist or track field filter. To limit the results to a particular
     year, use the field filter year with album, artist, and track searches. For
     example: `query: "bob year:2014"` Or with a date range. For example:
     `query: "bob year:1980-2020"`. To retrieve only albums released in the last
     two weeks, use the field filter "tag:new" in album searches.

     To retrieve only albums with the lowest 10% popularity, use the field
     filter "tag:hipster" in album searches. Note: This field filter only works
     with album searches. Depending on object types being searched for, other
     field filters, include genre (applicable to tracks and artists), upc, and
     isrc. Use double quotation marks around the genre keyword string if it
     contains spaces.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - query: A query, which can also include filters, as specified above.
             **Maximum characters: 100**. Do NOT percent encode it yourself. It
             will be percent-encoded automatically.
       - categories: An array of id categories. Only results that
             match the specified categories will be returned. Valid types:
             ``IDCategory/album``, ``IDCategory/artist``,
             ``IDCategory/playlist``, ``IDCategory/track``, ``IDCategory/show``,
             ``IDCategory/episode``, and ``IDCategory/audiobook``. **Warning:**
             **There is a bug in the web API in which you cannot specify both**
             ``IDCategory/show`` **and** ``IDCategory/audiobook``**.**
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". If a country code is specified, only content that is
             playable in that market is returned. **Note: Playlist results are**
             **not affected by the market parameter**. If market is set to
             "from_token", and the access token was granted on behalf of a user
             (i.e., if you authorized your application using the authorization
             code flow or the authorization code flow with proof key for code
             exchange), only content playable in the country associated with the
             user account, is returned. Users can view the country that is
             associated with their account in the [account settings][3].
             **Note: If neither market or user country are provided, the shows**
             **and episodes are considered unavailable for the client and**
             **Spotify will return** `nil` **for all of the shows and**
             **episodes. Therefore, if you authorized your application using**
             **the client credentials flow, you must provide a value for this**
             **parameter in order to retrieve shows and episodes.**
       - limit: Maximum number of results to return. Default: 20; Minimum: 1;
             Maximum: 50. **Note:** The limit is applied within each type, not
             on the total response. For example, if the limit value is 3 and the
             types are ``IDCategory/artist`` and ``IDCategory/album``, the
             response contains up to 3 artists and 3 albums.
       - offset: The index of the first result to return. Default: 0 Maximum
             offset (including limit): 2,000. Use with `limit` to get the next
             page of search results.
       - includeExternal: Possible values: "audio". If this is specified, the
             response will include any relevant audio content that is hosted
             externally. By default, external content is filtered out from
             responses.
     - Returns: A ``SearchResult``. The ``SearchResult/albums``,
           ``SearchResult/artists``, ``SearchResult/playlists``,
           ``SearchResult/tracks``, ``SearchResult/shows``,
           ``SearchResult/episodes``, and ``SearchResult/audiobooks`` properties
           of this struct will be non-`nil` for each of the categories that were
           requested from the search endpoint. If no results were found for a
           category, then the ``PagingObject/items`` property of the property's
           paging object will be empty; the property itself will only be `nil`
           if the category was not requested in the search. The simplified
           versions of all these objects will be returned.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/search
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func search(
        query: String,
        categories: [IDCategory],
        market: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        includeExternal: String? = nil
    ) -> AnyPublisher<SearchResult, Error> {
        
        do {
            
            let validCategories: [IDCategory] = [
                .album, .artist, .playlist, .track, .show, .episode, .audiobook
            ]
            guard !categories.isEmpty &&
                    categories.allSatisfy(validCategories.contains) else {
                throw SpotifyGeneralError.invalidIdCategory(
                    expected: validCategories, received: categories
                )
            }
            
            let requiredScopes: Set<Scope> = market == "from_token" ?
                    [.userReadPrivate] : []
            
            func makeQueryItems(
                offset: Int?
            ) -> [String : LosslessStringConvertible?] {
                return [
                    "q": query,
                    "type": categories.commaSeparatedString(),
                    "market": market,
                    "limit": limit,
                    "offset": offset,
                    "include_external": includeExternal
                ]
            }

            return self.getRequest(
                path: "/search",
                queryItems: makeQueryItems(offset: offset),
                requiredScopes: requiredScopes
            )
            .decodeSpotifyObject(SearchResult.self)
        
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
}
