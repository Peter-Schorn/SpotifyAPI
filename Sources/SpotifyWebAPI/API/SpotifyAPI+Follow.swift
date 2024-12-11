import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

private extension SpotifyAPI where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{
    
    /// Check if the current user is following the specified artists/users.
    func currentUserFollowingContains(
        uris: [SpotifyURIConvertible],
        type: IDCategory
    ) -> AnyPublisher<[Bool], Error> {
        
        do {
            
            if uris.isEmpty {
                return ResultPublisher([])
                    .eraseToAnyPublisher()
            }

            let idsString = try SpotifyIdentifier
                .commaSeparatedIdsString(
                    uris, ensureCategoryMatches: [type]
                )
            
            return self.getRequest(
                path: "/me/following/contains",
                queryItems: [
                    "type": type.rawValue,
                    "ids": idsString
                ],
                requiredScopes: [.userFollowRead]
            )
            .decodeSpotifyObject(
                [Bool].self,
                maxRetryDelay: self.maxRetryDelay
            )

        } catch {
            return error.anyFailingPublisher()
        }

    }

    /// Follow and unfollow artists and users.
    func modifyCurrentUserFollowing(
        uris: [SpotifyURIConvertible],
        type: IDCategory,
        httpMethod: String
    ) -> AnyPublisher<Void, Error> {
        
        do {
            
            if uris.isEmpty {
                return ResultPublisher(())
                    .eraseToAnyPublisher()
            }

            let ids = try SpotifyIdentifier.idsArray(
                uris,
                ensureCategoryMatches: [type]
            )
            let body = ["ids": ids]
            
            return self.apiRequest(
                path: "/me/following",
                queryItems: ["type": type.rawValue],
                httpMethod: httpMethod,
                makeHeaders: Headers.bearerAuthorizationAndContentTypeJSON(_:),
                body: body,
                requiredScopes: [.userFollowModify]
            )
            .decodeSpotifyErrors()
            .map { _, _ in }
            .eraseToAnyPublisher()
            
            
        } catch {
            return error.anyFailingPublisher()
        }

    }
    
}

public extension SpotifyAPI where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{

    // MARK: Follow (Requires Authorization Scopes)
    
    /**
     Check if the current user follows a specified playlist.

     See also ``currentUserFollowsArtists(_:)`` and
     ``currentUserFollowsUsers(_:)``.

     Checking if the user follows a public playlist doesn’t require any scopes.
     Checking if the user follows a private playlist requires the
     ``Scope/playlistReadPrivate`` scope. If your app is not authorized for this
     scope, then this endpoint will *always* return `false` for private
     playlists.

     If the user has created the playlist themself (or you created it for them)
     and it shows up in their Spotify client, then that also means that they are
     following it. See also [Following and Unfollowing a Playlist][1].

     Read more at the [Spotify web API reference][2].

     - Parameter uri: The URI for a playlist.
     - Returns: A boolean value indicating whether or not the user is following
           the playlist.

     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#following-and-unfollowing-a-playlist
     [2]: https://developer.spotify.com/documentation/web-api/reference/#/operations/check-if-user-follows-playlist
     */
    func currentUserFollowsPlaylist(
        _ uri: SpotifyURIConvertible
    ) -> AnyPublisher<Bool, Error> {

        do {

            let playlistId = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.playlist]
            ).id

            return self.getRequest(
                path: "/playlists/\(playlistId)/followers/contains",
                queryItems: [:],
                requiredScopes: []
            )
            .decodeSpotifyObject(
                [Bool].self,
                maxRetryDelay: self.maxRetryDelay
            )
            .tryMap { bools -> Bool in
                if bools.isEmpty {
                    throw SpotifyGeneralError.other(
                        "invalid JSON response: empty array"
                    )
                }
                return bools[0]
            }
            .eraseToAnyPublisher()



        } catch {
            return error.anyFailingPublisher()
        }

    }


    /**
     Get the current user’s followed artists.
     
     See also ``currentUserFollowsArtists(_:)``.
     
     This endpoint requires the ``Scope/userFollowRead`` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - artist: the URI of the last artist from the previous request. Use this
             parameter to retrieve the next set of artists after this artist.
       - limit: The maximum number of items to return. Default: 20; Minimum: 1;
             Maximum: 50.
     - Returns: An array of artist objects wrapped in a ``CursorPagingObject``.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-followed
     */
    func currentUserFollowedArtists(
        after artist: SpotifyURIConvertible? = nil,
        limit: Int? = nil
    ) -> AnyPublisher<CursorPagingObject<Artist>, Error> {
        
        do {
            
            let artistId = try artist.map { artist in
                try SpotifyIdentifier(
                    uri: artist, ensureCategoryMatches: [.artist]
                ).id
            }
            
            return self.getRequest(
                path: "/me/following",
                queryItems: [
                    "type": "artist",
                    "after": artistId,
                    "limit": limit
                ],
                requiredScopes: [.userFollowRead]
            )
            .decodeSpotifyObject(
                CursorPagingObject<Artist>.self,
                maxRetryDelay: self.maxRetryDelay
            )
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Check if the current user follows the specified artists.
     
     See also ``SpotifyAPI/currentUserFollowedArtists(after:limit:)``.
     
     This endpoint requires the ``Scope/userFollowRead`` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uris: An array of artist URIs. Maximum: 50. Passing in
           duplicates will result in a 502 "Failed to check following status"
           error. Passing in an empty array will immediately cause an empty
           array of results to be returned without a network request being made.
     - Returns: An array of `true` or `false` values, in the order requested,
           indicating whether the user is following each artist.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/check-current-user-follows
     */
    func currentUserFollowsArtists(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<[Bool], Error> {
        
        return self.currentUserFollowingContains(
            uris: uris, type: .artist
        )

    }

    /**
     Add the current user as a follower of one or more artists.
     
     See also ``followUsersForCurrentUser(_:)`` and
     ``followPlaylistForCurrentUser(_:publicly:)``.
     
     This endpoint requires the ``Scope/userFollowModify`` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uris: An array of artist URIs. Maximum: 50. Passing in an empty
           array will prevent a network request from being made.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/follow-artists-users
     */
    func followArtistsForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {
        
        return self.modifyCurrentUserFollowing(
            uris: uris, type: .artist, httpMethod: "PUT"
        )

    }
    
    /**
     Unfollow one or more artists for the current user.

     See also ``unfollowUsersForCurrentUser(_:)`` and
     ``unfollowPlaylistForCurrentUser(_:)``.
     
     This endpoint requires the ``Scope/userFollowModify`` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uris: An array of artist URIs. maximum: 50. Passing in an empty
           array will prevent a network request from being made.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/unfollow-artists-users
     */
    func unfollowArtistsForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {
        
        return self.modifyCurrentUserFollowing(
            uris: uris, type: .artist, httpMethod: "DELETE"
        )
        
    }
    
    /**
     Check if the current user follows the specified users.
     
     See also ``currentUserFollowsArtists(_:)`` and
     ``currentUserFollowsPlaylist(_:)``.

     This endpoint requires the ``Scope/userFollowRead`` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uris: An array of user URIs. Maximum: 50. Passing in duplicates
           will result in a 502 "Failed to check following status" error.
           Passing in an empty array will immediately cause an empty array of
           results to be returned without a network request being made.
     - Returns: An array of `true` or `false` values, in the order requested,
           indicating whether the user is following each user.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/check-current-user-follows
     */
    func currentUserFollowsUsers(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<[Bool], Error> {
        
        return self.currentUserFollowingContains(
            uris: uris, type: .user
        )

    }

    /**
     Add the current user as a follower of one or more users.
     
     See also ``followArtistsForCurrentUser(_:)`` and
     ``followPlaylistForCurrentUser(_:publicly:)``.
     
     This endpoint requires the ``Scope/userFollowModify`` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uris: An array of user URIs. Maximum: 50. Passing in an empty
           array will prevent a network request from being made.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/follow-artists-users
     */
    func followUsersForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {
        
        return self.modifyCurrentUserFollowing(
            uris: uris, type: .user, httpMethod: "PUT"
        )

    }
    
    /**
     Unfollow one or more users for the current user.

     See also ``unfollowArtistsForCurrentUser(_:)`` and
     ``unfollowPlaylistForCurrentUser(_:)``.
     
     This endpoint requires the ``Scope/userFollowModify`` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uris: An array of user URIs. maximum: 50. Passing in an empty
           array will prevent a network request from being made.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/unfollow-artists-users
     */
    func unfollowUsersForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {
        
        return self.modifyCurrentUserFollowing(
            uris: uris, type: .user, httpMethod: "DELETE"
        )
        
    }
    
    /**
     Follow a playlist for the current user.

     See also ``followArtistsForCurrentUser(_:)`` and
     ``followUsersForCurrentUser(_:)``.

     Following a playlist publicly requires authorization of the
     ``Scope/playlistModifyPublic`` scope; following it privately requires the
     ``Scope/playlistModifyPrivate`` scope.

     Note that the scopes you provide relate only to whether the current user is
     following the playlist publicly or privately (i.e. showing others what they
     are following), not whether the playlist itself is public or private.

     See also the guide for [working with playlists][1].
     
     Read more at the [Spotify web API reference][2].
     
     - Parameters:
       - uri: The URI for a playlist.
       - publicly: Defaults to `true`. If `true`, the playlist will be included
             in the user’s public playlists, if `false`, it will remain private.
             To be able to follow playlists privately, the user must have
             granted the ``Scope/playlistModifyPrivate`` scope.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/
     [2]: https://developer.spotify.com/documentation/web-api/reference/#/operations/follow-playlist
     */
    func followPlaylistForCurrentUser(
        _ uri: SpotifyURIConvertible,
        publicly: Bool = true
    ) -> AnyPublisher<Void, Error> {
        
        do {
            
            let playlistId = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.playlist]
            ).id
            
            return self.apiRequest(
                path: "/playlists/\(playlistId)/followers",
                queryItems: [:],
                httpMethod: "PUT",
                makeHeaders: Headers.bearerAuthorizationAndContentTypeJSON(_:),
                body: ["public": publicly],
                requiredScopes: []
            )
            .decodeSpotifyErrors()
            .map { _, _ in }
            .eraseToAnyPublisher()

        } catch {
            return error.anyFailingPublisher()
        }

    }
    
    /**
     Unfollow a playlist for the current user.

     See also ``unfollowArtistsForCurrentUser(_:)`` and
     ``unfollowUsersForCurrentUser(_:)``.

     Spotify has no concept of deleting playlists. When a user deletes a
     playlist in their Spotify client, they are actually just unfollowing it.
     The playlist can always be retrieved again given a valid URI.

     Unfollowing a publicly followed playlist for a user requires authorization
     of the ``Scope/playlistModifyPublic`` scope; unfollowing a privately
     followed playlist requires the ``Scope/playlistModifyPrivate`` scope.

     Note that the scopes you provide relate only to whether the current user is
     following the playlist publicly or privately (i.e. showing others what they
     are following), not whether the playlist itself is public or private.

     See also the guide for [working with playlists][1].

     Read more at the [Spotify web API reference][2].
     
     - Parameters:
       - uri: The URI for a playlist.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#following-and-unfollowing-a-playlist
     [2]: https://developer.spotify.com/documentation/web-api/reference/#/operations/follow-playlist
     */
    func unfollowPlaylistForCurrentUser(
        _ uri: SpotifyURIConvertible
    ) -> AnyPublisher<Void, Error> {
        
        do {
            
            let playlistId = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.playlist]
            ).id
            
            return self.apiRequest(
                path: "/playlists/\(playlistId)/followers",
                queryItems: [:],
                httpMethod: "DELETE",
                makeHeaders: Headers.bearerAuthorizationAndContentTypeJSON(_:),
                bodyData: nil,
                requiredScopes: []
            )
            .decodeSpotifyErrors()
            .map { _, _ in }
            .eraseToAnyPublisher()

        } catch {
            return error.anyFailingPublisher()
        }

    }
    
}
