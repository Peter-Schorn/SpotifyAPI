import Foundation
import Combine

public extension SpotifyAPI {
    
    /**
     Get a show.
     
     See also `shows(_:market:)` (gets multiple shows).
     
     Reading the user’s resume points on episode objects requires the
     `userReadPlaybackPosition` scope.
     
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
             
     - Returns: The full version of a show object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/shows/get-a-show/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/se/account/overview/
     */
    func show(
        _ uri: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<Show, Error> {
        
        do {
            
            let id = try SpotifyIdentifier(
                uri: uri, ensureTypeMatches: [.show]
            ).id
            
            return self.getRequest(
                path: "/shows/\(id)",
                queryItems: ["market": market],
                requiredScopes: []
            )
            .decodeSpotifyObject(Show.self)
            

        } catch {
            return error.anyFailingPublisher(Show.self)
        }
        
    }
    
    /**
     Get multiple shows.
     
     See also `show(_:market:)` (gets a single show).
     
     Reading the user’s resume points on episode objects requires the
     `userReadPlaybackPosition` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uris: An array of show URIs. Maximum: 50.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][2].
             If a country code is specified, only shows and episodes that
             are available in that market will be returned. If a valid user
             access token is specified in the request header, the country
             associated with the user account will take priority over this
             parameter. Note: If neither market or user country are provided,
             the content is considered unavailable for the client. Users can
             view the country that is associated with their account in the
             [account settings][3].
             
     - Returns: The full versions of up to 50 show objects. Shows
           are returned in the order requested. If a show is not found,
           `nil` is returned in the appropriate position. Duplicate shows
           URIs in the request will result in duplicate shows in the response.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/shows/get-several-shows/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/se/account/overview/
     */
    func shows(
        _ uris: [SpotifyURIConvertible],
        market: String? = nil
    ) -> AnyPublisher<[Show?], Error> {
            
        do {
            
            let idsString = try SpotifyIdentifier
                .commaSeparatedIdsString(
                    uris, ensureTypeMatches: [.show]
                )
            
            return self.getRequest(
                path: "/shows",
                queryItems: [
                    "ids": idsString,
                    "market": market
                ],
                requiredScopes: []
            )
            .decodeSpotifyObject([String: [Show?]].self)
            .tryMap { dict -> [Show?] in
                if let shows = dict["shows"] {
                    return shows
                }
                throw SpotifyLocalError.topLevelKeyNotFound(
                    key: "shows", dict: dict
                )
            }
            .eraseToAnyPublisher()
            

        } catch {
            return error.anyFailingPublisher([Show?].self)
        }

    }

}
