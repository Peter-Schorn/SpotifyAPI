import Foundation
import Combine

// MARK: Episodes

public extension SpotifyAPI {
    
    /**
     Get an episode.

     See also `episodes(_:market:)` (gets multiple episodes).
     
     Reading the user’s resume points on episode objects requires the
     `userReadPlaybackPosition` scope. Otherwise, no scopes are
     required.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uri: The URI of an episode.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][2].
             If a country code is specified, only shows and episodes that
             are available in that market will be returned. If a valid user
             access token is specified in the request header, the country
             associated with the user account will take priority over this
             parameter. Note: If neither market or user country are provided,
             the content is considered unavailable for the client. Users can
             view the country that is associated with their account in the
             [account settings][3].
             
     - Returns: The full version of an episode object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/episodes/get-an-episode/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/se/account/overview/
     */
    func episode(
        _ uri: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<Episode, Error> {
        
        do {
        
            let id = try SpotifyIdentifier(
                uri: uri, ensureTypeMatches: [.episode]
            ).id
            
            return self.getRequest(
                path: "/episodes/\(id)",
                queryItems: ["market": market],
                requiredScopes: []
            )
            .decodeSpotifyObject(Episode.self)
    
        } catch {
            return error.anyFailingPublisher(Episode.self)
        }

    }
    
    /**
     Get multiple episodes.
     
     See also `episode(_:market:)` (gets a single episode).
     
     Reading the user’s resume points on episode objects requires the
     `userReadPlaybackPosition` scope. Otherwise, no scopes are
     required.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uris: An array of episode URIs. Maximum: 50.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][2].
             If a country code is specified, only shows and episodes that
             are available in that market will be returned. If a valid user
             access token is specified in the request header, the country
             associated with the user account will take priority over this
             parameter. Note: If neither market or user country are provided,
             the content is considered unavailable for the client. Users can
             view the country that is associated with their account in the
             [account settings][3].
             
     - Returns: The full versions of up to 50 episode objects. Episodes
           are returned in the order requested. If an episode is not found,
           `nil` is returned in the appropriate position. Duplicate episode
           URIs in the request will result in duplicate episodes in the response.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/episodes/get-several-episodes/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/se/account/overview/
     */
    func episodes(
        _ uris: [SpotifyURIConvertible],
        market: String? = nil
    ) -> AnyPublisher<[Episode?], Error> {
            
        do {
            
            let idsString = try SpotifyIdentifier
                .commaSeparatedIdsString(
                    uris, ensureTypeMatches: [.episode]
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
                throw SpotifyLocalError.topLevelKeyNotFound(
                    key: "episodes", dict: dict
                )
            }
            .eraseToAnyPublisher()

        } catch {
            return error.anyFailingPublisher([Episode?].self)
        }

    }
    
}
