import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif


public extension SpotifyAPI {
    
    // MARK: User Profile
    
    /**
     Get the *public* profile information for a user.
     
     See also `currentUserProfile()`.
     
     No scopes are required for this endpoint.
     
     The `country`, `email`, `product`, `allowsExplicitContent`, and
     `explicitContentSettingIsLocked` properties of `SpotifyUser` will always be
     `nil` even if the URI of the current user is provided and the application
     is authorized for the `userReadPrivate` and `userReadEmail` scopes. You
     must use `currentUserProfile()` to retrieve these properties.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uri: The URI of a Spotify user.

     [1]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-users-profile
     */
    func userProfile(
        _ uri: SpotifyURIConvertible
    ) -> AnyPublisher<SpotifyUser, Error> {
        
        do {
            
            let userId = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.user]
            ).id
            
            return self.getRequest(
                path: "/users/\(userId)",
                queryItems: [:],
                requiredScopes: []
            )
            .decodeSpotifyObject(SpotifyUser.self)
            
        } catch {
            return error.anyFailingPublisher()
        }

    }
    
}

public extension SpotifyAPI where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{
    // MARK: User Profile (Requires Authorization Scopes)
    
    /**
     Get the profile of the current user.
     
     See also `userProfile(_:)`.
     
     The access token must have been issued on behalf of a user.

     The `allowsExplicitContent`, `explicitContentSettingIsLocked`, `country`,
     and `product` properties of `SpotifyUser` require the `userReadPrivate`
     scope.

     `SpotifyUser.email` requires the `userReadEmail` scope.

     If the application is not authorized for these scopes, then these
     properties will be `nil`.
     
     Read more at the [Spotify web API reference][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#endpoint-get-current-users-profile
     */
    func currentUserProfile() -> AnyPublisher<SpotifyUser, Error> {
        
        return self.getRequest(
            path: "/me",
            queryItems: [:],
            requiredScopes: []
        )
        .decodeSpotifyObject(SpotifyUser.self)
        
    }
    
}
