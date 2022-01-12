import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public extension SpotifyAPI {
    
    // MARK: Markets

    /**
     Get the list of markets where Spotify is available.
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].

     - Returns: A list of the countries in which Spotify is available,
           identified by their [ISO 3166-1 alpha-2 country code][2] with
           additional country codes for special territories. For example:
           `["AD", "AE", "AR", ...]`.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-available-markets
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func availableMarkets() -> AnyPublisher<[String], Error> {
        
        return self.getRequest(
            path: "/markets",
            queryItems: [:],
            requiredScopes: []
        )
        .decodeSpotifyObject([String: [String]].self)
        .tryMap { dict -> [String] in
            let key = "markets"
            if let markets = dict[key] {
                return markets
            }
            throw SpotifyGeneralError.topLevelKeyNotFound(
                key: key, dict: dict
            )
        }
        .eraseToAnyPublisher()

    }

}
