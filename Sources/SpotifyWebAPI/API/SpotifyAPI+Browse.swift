import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public extension SpotifyAPI {
    
    // MARK: Browse
    
    /**
     Get a Spotify Category.

     Use `categories(country:locale:limit:offset:)` to get an array of
     categories.

     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - id: A category id.
       - country: *Optional*. A country: an
             [ISO 3166-1 alpha-2 country code][2]. Provide this parameter
             to ensure that the category exists for a particular country.
       - locale: *Optional*. The desired language, consisting of an [ISO
             639-1][3] language code and an [ISO 3166-1 alpha-2 country
             code][2], joined by an underscore. For example: es_MX, meaning
             "Spanish (Mexico)". Provide this parameter if you want the category
             strings returned in a particular language. Note that, if this
             parameter is not supplied, or if the specified language is not
             available, the category strings returned will be in the Spotify
             default language (American English).
     - Returns: A category object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-a-category
     [2]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: http://en.wikipedia.org/wiki/ISO_639-1
     */
    func category(
        _ id: String,
        country: String? = nil,
        locale: String? = nil
    ) -> AnyPublisher<SpotifyCategory, Error> {
        
        return self.getRequest(
            path: "/browse/categories/\(id)",
            queryItems: [
                "country": country,
                "locale": locale
            ],
            requiredScopes: []
        )
        .decodeSpotifyObject(SpotifyCategory.self)

    }
    
    /**
     Get a list of categories used to tag items in Spotify (on, for example, the
     Spotify player’s "Browse" tab).

     See also `category(_:country:locale:)` (gets a single category based on an
     id).
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - country: *Optional*. A country: an [ISO 3166-1 alpha-2 country
             code][2]. Provide this parameter if you want to narrow the list of
             returned categories to those relevant to a particular country. If
             omitted, the returned items will be globally relevant.
       - locale: *Optional*. The desired language, consisting of an [ISO 639-1
             language code][3] and an [ISO 3166-1 alpha-2 country code][2],
             joined by an underscore. For example: es_MX, meaning "Spanish
             (Mexico)". Provide this parameter if you want the category metadata
             returned in a particular language. Note that, if locale is not
             supplied, or if the specified language is not available, all
             strings will be returned in the Spotify default language (American
             English). The locale parameter, combined with the country
             parameter, may give odd results if not carefully matched. For
             example, "SE" for `country` and "de_DE" for `locale` will return a
             list of categories relevant to Sweden but as German language
             strings.
       - limit: *Optional*. The maximum number of categories to return.
             Default: 20; Minimum: 1; Maximum: 50.
       - offset: *Optional.* The index of the first category to return.
             Default: 0. Use with limit to get the next set of categories.
     - Returns: An array of [category][4] objects wrapped in a paging object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-categories
     [2]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: http://en.wikipedia.org/wiki/ISO_639-1
     [4]: https://developer.spotify.com/documentation/web-api/reference/#object-categoryobject
     */
    func categories(
        country: String? = nil,
        locale: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<PagingObject<SpotifyCategory>, Error> {
        
        return self.getRequest(
            path: "/browse/categories",
            queryItems: [
                "country": country,
                "locale": locale,
                "limit": limit,
                "offset": offset
            ],
            requiredScopes: []
        )
        .decodeSpotifyObject([String: PagingObject<SpotifyCategory>].self)
        .tryMap { dict in
            if let categories = dict["categories"] {
                return categories
            }
            throw SpotifyGeneralError.topLevelKeyNotFound(
                key: "categories", dict: dict
            )
        }
        .eraseToAnyPublisher()

    }
 
    /**
     Get a list of Spotify playlists tagged with a particular category.
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - id: A category id.
       - country: *Optional*. A country: an [ISO 3166-1 alpha-2 country
             code][2].
       - limit: *Optional*. The maximum number of items to return. Default: 20;
             Minimum: 1; Maximum: 50.
       - offset: *Optional.* The index of the first playlist to return. Default:
             0. Use with limit to get the next set of playlists.
     - Returns: An array of simplified playlist objects wrapped in a paging
           object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-a-categories-playlists
     [2]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func categoryPlaylists(
        _ id: String,
        country: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<PagingObject<Playlist<PlaylistItemsReference>>, Error> {
        
        return self.getRequest(
            path: "/browse/categories/\(id)/playlists",
            queryItems: [
                "country": country,
                "limit": limit,
                "offset": offset
            ],
            requiredScopes: []
        )
        .decodeSpotifyObject(
            [String: PagingObject<Playlist<PlaylistItemsReference>>].self
        )
        .tryMap { dict in
            if let playlists = dict["playlists"] {
                return playlists
            }
            throw SpotifyGeneralError.topLevelKeyNotFound(
                key: "playlists", dict: dict
            )
        }
        .eraseToAnyPublisher()

    }

    /**
     Get a list of featured playlists (shown, for example, on a Spotify player’s
     "Browse" tab).
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - locale: *Optional*. The desired language, consisting of an [ISO 639-1
             language code][3] and an [ISO 3166-1 alpha-2 country code][2],
             joined by an underscore. For example: es_MX, meaning "Spanish
             (Mexico)". Provide this parameter if you want the results returned
             in a particular language. Note that, if locale is not supplied, or
             if the specified language is not available, all strings will be
             returned in the Spotify default language (American English). The
             locale parameter, combined with the country parameter, may give odd
             results if not carefully matched. For example, "SE" for `country`
             and "de_DE" for `locale` will return a list of playlists relevant
             to Sweden but as German language strings.
       - country: *Optional*. A country: an [ISO 3166-1 alpha-2 country
             code][2]. Provide this parameter if you want to narrow the list of
             returned categories to those relevant to a particular country. If
             omitted, the returned items will be globally relevant.
       - timestamp: *Optional*. A date, which will be converted to a
             second-precision timestamp ("yyyy-MM-ddTHH:mm:ss"). Use this
             parameter to specify the user’s local time to get results tailored
             for that specific date and time in the day. If not provided, the
             response defaults to the current UTC time. If there were no
             featured playlists (or there is no data) at the specified time, the
             response will revert to the current UTC time.
       - limit: *Optional*. The maximum number of playlists to return. Default:
             20; Minimum: 1; Maximum: 50.
       - offset: *Optional*. The index of the first playlist to return. Default:
             0. Use with limit to get the next set of playlists.
     - Returns: An array of simplified playlist objects wrapped in a paging
           object and a message that can be displayed to the user, such as "Good
           Morning", or "Editors's picks", localized based on the locale,
           country, and timestamp parameters.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-featured-playlists
     [2]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: http://en.wikipedia.org/wiki/ISO_639-1
     */
    func featuredPlaylists(
        locale: String? = nil,
        country: String? = nil,
        timestamp: Date? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<FeaturedPlaylists, Error> {
       
        let formattedTimestamp: String? = timestamp.map { timestamp in
            DateFormatter.featuredPlaylists.string(from: timestamp)
        }
                
        return self.getRequest(
            path: "/browse/featured-playlists",
            queryItems: [
                "locale": locale,
                "country": country,
                "timestamp": formattedTimestamp,
                "limit": limit,
                "offset": offset
            ],
            requiredScopes: []
        )
        .decodeSpotifyObject(FeaturedPlaylists.self)
        
    }
 
    /**
     Get a list of new album releases featured in Spotify (shown, for example,
     on a Spotify player’s "Browse" tab).
     
     No scopes are required for this endpoint.
         
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - country: *Optional*. A country: an [ISO 3166-1 alpha-2 country
             code][2]. Provide this parameter if you want the list of returned
             albums to be relevant to a particular country. If omitted, the
             albums will be relevant to all countries.
       - limit: *Optional*. The maximum number of albums to return. Default: 20;
             Minimum: 1; Maximum: 50.
       - offset: *Optional*. The index of the first album to return. Default: 0.
             Use with limit to get the next set of albums.
     - Returns: An array of simplified album objects wrapped in a paging object
           and a message that can be displayed to the user, such as "Good
           Morning", or "Editors's picks", localized based on the locale,
           country, and timestamp parameters.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-new-releases
     [2]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func newAlbumReleases(
        country: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<NewAlbumReleases, Error> {
        
        return self.getRequest(
            path: "/browse/new-releases",
            queryItems: [
                "country": country,
                "limit": limit,
                "offset": offset
            ],
            requiredScopes: []
        )
        .decodeSpotifyObject(NewAlbumReleases.self)

    }

    /**
     Get Recommendations Based on Seeds.
     
     Create a playlist-style listening experience based on seed artists, tracks
     and genres.
     
     Recommendations are generated based on the available information for a
     given seed entity and matched against similar artists and tracks. If there
     is sufficient information about the provided seeds, a list of tracks will
     be returned together with pool size details.

     For artists and tracks that are very new or obscure there might not be
     enough data to generate a list of tracks.

     Use `SpotifyAPI.recommendationGenres()` to get the available seed genres.

     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - trackAttributes: [Tunable track attributes][2].
       - limit: *Optional*. The target size of the list of recommended tracks.
             For seeds with unusually small pools or when highly restrictive
             filtering is applied, it may be impossible to generate the
             requested number of recommended tracks. Debugging information for
             such cases is available in the response. Default: 20; Minimum: 1;
             Maximum: 100.
       - market: *Optional*. [An ISO 3166-1 alpha-2 country code][3] or the
             string "from_token". Provide this parameter if you want to apply
             [Track Relinking][4]. Because minimum, maximum, and target values
             are applied to pools before relinking, the generated results may
             not precisely match the filters applied. Original, non-relinked
             tracks are available via the `linkedFrom` attribute of the
             [relinked track response][5].
     - Returns: Recommendation seeds and an array of tracks.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-recommendations
     [2]: https://developer.spotify.com/documentation/web-api/reference/#object-tuneabletrackobject
     [3]: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [4]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide
     [5]: https://developer.spotify.com/documentation/web-api/reference/#object-linkedtrackobject
     */
    func recommendations(
        _ trackAttributes: TrackAttributes,
        limit: Int? = nil,
        market: String? = nil
    ) -> AnyPublisher<RecommendationsResponse, Error> {
    
        do {
            
            let queryDict = try trackAttributes.queryDictionary()
                .merging(
                    urlQueryDictionary(["limit": limit, "market": market]),
                    uniquingKeysWith: { lhs, rhs in rhs }
                )
            
            return self.getRequest(
                path: "/recommendations",
                queryItems: queryDict,
                requiredScopes: []
            )
            .decodeSpotifyObject(RecommendationsResponse.self)

        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Retrieve a list of available genres seeds for [recommendations][1].

     No scopes are required for this endpoint.
     
     These values can be used in the `seedGenres` property of `TrackAttributes`
     when using the `recommendations(_:limit:market:)` endpoint.
     
     Read more at the [Spotify web API reference][2].
     
     - Returns: An array of genres ids.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-recommendations
     [2]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-recommendation-genres
     */
    func recommendationGenres() -> AnyPublisher<[String], Error> {
        
        return self.getRequest(
            path: "/recommendations/available-genre-seeds",
            queryItems: [:],
            requiredScopes: []
        )
        .decodeSpotifyObject([String: [String]].self)
        .tryMap { dict in
            if let genres = dict["genres"] {
                return genres
            }
            throw SpotifyGeneralError.topLevelKeyNotFound(
                key: "genres", dict: dict
            )
        }
        .eraseToAnyPublisher()
        
    }
    
}
