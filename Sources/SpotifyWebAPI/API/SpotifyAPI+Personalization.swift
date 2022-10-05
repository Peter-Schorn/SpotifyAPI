import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public extension SpotifyAPI where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{
    
    // MARK: Personalization (Requires Authorization Scopes)
    
    /**
     Get the current user's top artists, calculated based on affinity.
     
     See also ``currentUserTopTracks(_:offset:limit:)``.
     
     This endpoint requires the ``Scope/userTopRead`` scope.

     Affinity is a measure of the expected preference a user has for a
     particular artist. It is based on user behavior, including play history,
     but does not include actions made while in incognito mode. Light or
     infrequent users of Spotify may not have sufficient play history to
     generate a full affinity data set. As a user’s behavior is likely to shift
     over time, this preference data is available over three time spans. See
     `timeRange` below for more information. For each time range, the top 50
     artists are available for each user. In the future, it is likely that this
     restriction will be relaxed. This data is typically updated once each day
     for each user.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - timeRange: Over what time frame the affinities are computed. Valid
             values: ``TimeRange/longTerm`` (calculated from several years of
             data and including all new data as it becomes available),
             ``TimeRange/mediumTerm`` (approximately last 6 months), and
             ``TimeRange/shortTerm`` (approximately last 4 weeks). Default:
             ``TimeRange/mediumTerm``.
       - offset: The index of the first artist to return. Default: 0. Use with
             `limit` to get the next set of artists.
       - limit: The number of artists to return. Default: 20; Minimum: 1;
             Maximum: 50.
     - Returns: An array of the full versions of artist objects wrapped in a
           paging object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-users-top-artists-and-tracks
     */
    func currentUserTopArtists(
        _ timeRange: TimeRange? = nil,
        offset: Int? = nil,
        limit: Int? = nil
    ) -> AnyPublisher<PagingObject<Artist>, Error> {
        
        return self.getRequest(
            path: "/me/top/artists",
            queryItems: [
                "offset": offset,
                "limit": limit,
                "time_range": timeRange?.rawValue
            ],
            requiredScopes: [.userTopRead]
        )
        .decodeSpotifyObject(PagingObject<Artist>.self)

    }
    
    /**
     Get the current user's top tracks, calculated based on affinity.

     See also ``currentUserTopArtists(_:offset:limit:)``.

     This endpoint requires the ``Scope/userTopRead`` scope.

     Affinity is a measure of the expected preference a user has for a
     particular track. It is based on user behavior, including play history, but
     does not include actions made while in incognito mode. Light or infrequent
     users of Spotify may not have sufficient play history to generate a full
     affinity data set. As a user’s behavior is likely to shift over time, this
     preference data is available over three time spans. See time_range in the
     query parameter table for more information. For each time range, the top 50
     tracks are available for each user. In the future, it is likely that this
     restriction will be relaxed. This data is typically updated once each day
     for each user.

     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - timeRange: Over what time frame the affinities are computed. Valid
             values: ``TimeRange/longTerm`` (calculated from several years of
             data and including all new data as it becomes available),
             ``TimeRange/mediumTerm`` (approximately last 6 months), and
             ``TimeRange/shortTerm`` (approximately last 4 weeks). Default:
             ``TimeRange/mediumTerm``.
       - offset: The index of the first track to return. Default: 0. Use with
             `limit` to get the next set of tracks.
       - limit: The number of tracks to return. Default: 20; Minimum: 1;
             Maximum: 50.
     - Returns: An array of the full versions of track objects wrapped in a
           paging object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-users-top-artists-and-tracks
     */
    func currentUserTopTracks(
        _ timeRange: TimeRange? = nil,
        offset: Int? = nil,
        limit: Int? = nil
    ) -> AnyPublisher<PagingObject<Track>, Error> {
        
        return self.getRequest(
            path: "/me/top/tracks",
            queryItems: [
                "offset": offset,
                "limit": limit,
                "time_range": timeRange?.rawValue
            ],
            requiredScopes: [.userTopRead]
        )
        .decodeSpotifyObject(PagingObject<Track>.self)

    }

}
