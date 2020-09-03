import Foundation
import Combine

// MARK: User Profile

public extension SpotifyAPI {
    
    /**
     Get the profile of the current user.
     
     See also `userProfile(_:)`.
     
     Reading the user’s email address requires the `userReadEmail` scope;
     reading country and product subscription level requires the
     `userReadPrivate` scope. If the application is not authorized for
     these scopes, then these properties will be `nil`.
     
     Read more at the [Spotify web API reference][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/
     */
    func currentUserProfile() -> AnyPublisher<SpotifyUser, Error> {
        
        return self.getRequest(
            path: "/me",
            queryItems: [:],
            requiredScopes: []
        )
        .decodeSpotifyObject(SpotifyUser.self)
        
    }

    /**
     Get the *public* profile information for a user.
     
     See also `currentUserProfile()`.
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uri: The URI of a Spotify user.

     [1]: https://developer.spotify.com/documentation/web-api/reference/users-profile/get-users-profile/
     */
    func userProfile(
        _ uri: SpotifyURIConvertible
    ) -> AnyPublisher<SpotifyUser, Error> {
        
        do {
            
            let userId = try SpotifyIdentifier(
                uri: uri, ensureTypeMatches: [.user]
            ).id
            
            return self.getRequest(
                path: "/users/\(userId)",
                queryItems: [:],
                requiredScopes: []
            )
            .decodeSpotifyObject(SpotifyUser.self)
            
        } catch {
            return error.anyFailingPublisher(SpotifyUser.self)
        }
        

    }
    
    
}
