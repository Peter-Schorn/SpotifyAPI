import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public extension SpotifyAPI {

    // MARK: Episodes
    
    /**
     Get an episode.

     See also ``episodes(_:market:)`` (gets multiple episodes).
     
     Reading the user’s resume points on episode objects requires the
     ``Scope/userReadPlaybackPosition`` scope. Otherwise, no scopes are
     required.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uri: The URI of an episode.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". If a country code is specified, the episode will only
             be returned if it is available in that market. If the access token
             was granted on behalf of a user (i.e., if you authorized your
             application using the authorization code flow or the authorization
             code flow with proof key for code exchange), the country associated
             with the user account will take priority over this parameter. Users
             can view the country that is associated with their account in the
             [account settings][3]. **Note: If neither market or user country**
             **are provided, the episode is considered unavailable for the**
             **client and Spotify will return a 404 error with the message**
             **"non existing id". Therefore, if you authorized your**
             **application using the client credentials flow, you must provide**
             **a value for this parameter.**
     - Returns: The full version of an ``Episode`` object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-an-episode
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func episode(
        _ uri: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<Episode, Error> {
        
        do {
        
            let id = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.episode]
            ).id
            
            return self.getRequest(
                path: "/episodes/\(id)",
                queryItems: ["market": market],
                requiredScopes: []
            )
            .decodeSpotifyObject(Episode.self)
    
        } catch {
            return error.anyFailingPublisher()
        }

    }
    
    /**
     Get multiple episodes.
     
     See also ``episode(_:market:)`` (gets a single episode).
     
     Reading the user’s resume points on episode objects requires the
     ``Scope/userReadPlaybackPosition`` scope. Otherwise, no scopes are
     required.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uris: An array of episode URIs. Maximum: 50. Passing in an empty array
             will immediately cause an empty array of results to be returned
             without a network request being made.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". If a country code is specified, only episodes that
             are available in that market will be returned. If the access token
             was granted on behalf of a user (i.e., if you authorized your
             application using the authorization code flow or the authorization
             code flow with proof key for code exchange), the country associated
             with the user account will take priority over this parameter. Users
             can view the country that is associated with their account in the
             [account settings][3]. **Note: If neither market or user country**
             **are provided, the episodes are considered unavailable for the**
             **client and Spotify will return** `nil` **for all of the**
             **episodes. Therefore, if you authorized your application using**
             **the client credentials flow, you must provide a value for this**
             **parameter.**
     - Returns: The full versions of up to 50 episode objects. Episodes are
           returned in the order requested. If an episode is not found or is
           unavailable in the specified market/country, `nil` is returned in the
           appropriate positions. Duplicate episode URIs in the request will
           result in duplicate episodes in the response.

     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-multiple-episodes
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func episodes(
        _ uris: [SpotifyURIConvertible],
        market: String? = nil
    ) -> AnyPublisher<[Episode?], Error> {
            
        do {
            
            if uris.isEmpty {
                return ResultPublisher([])
                    .eraseToAnyPublisher()
            }
            
            let idsString = try SpotifyIdentifier
                .commaSeparatedIdsString(
                    uris, ensureCategoryMatches: [.episode]
                )
            
            return self.getRequest(
                path: "/episodes",
                queryItems: [
                    "ids": idsString,
                    "market": market
                ],
                requiredScopes: []
            )
            .decodeSpotifyObject([String: [Episode?]].self)
            .tryMap { dict -> [Episode?] in
                if let shows = dict["episodes"] {
                    return shows
                }
                throw SpotifyGeneralError.topLevelKeyNotFound(
                    key: "episodes", dict: dict
                )
            }
            .eraseToAnyPublisher()

        } catch {
            return error.anyFailingPublisher()
        }

    }
    
}
