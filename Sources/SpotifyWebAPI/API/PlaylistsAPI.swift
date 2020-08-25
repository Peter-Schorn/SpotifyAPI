import Foundation
import Combine

// MARK: Playlists

extension SpotifyAPI {
    
    /// Use for post/put/delete requests to the "/playlists/{playlistId}/tracks"
    /// endpoint in which the response is the snapshot id of the playlist.
    /// Can't be used for get requests. Use `self.getRequest` instead.
    func modifyPlaylist<Body: Encodable>(
        _ playlist: SpotifyURIConvertible,
        httpMethod: String,
        queryItems: [String: LosslessStringConvertible?],
        body: Body,
        requiredScopes: Set<Scope>
    ) -> AnyPublisher<String, Error> {
    
        do {
    
            let playlistId = try SpotifyIdentifier(uri: playlist.uri).id
    
            func makeHeaders(accessToken: String) -> [String: String] {
                return Headers.bearerAuthorization(accessToken) +
                    Headers.acceptApplicationJSON
            }
            
            return self.apiRequest(
                path: "/playlists/\(playlistId)/tracks",
                queryItems: queryItems,
                httpMethod: httpMethod,
                makeHeaders: makeHeaders(accessToken:),
                body: body,
                requiredScopes: requiredScopes
            )
            .spotifyDecode([String: String].self)
            .tryMap { dict -> String in
                if let snapshotId = dict["snapshot_id"] {
                    return snapshotId
                }
                throw SpotifyLocalError.topLevelKeyNotFound(
                    key: "snapshot_id", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher(String.self)
        }
    
    }

}

// MARK: - Public methods -

public extension SpotifyAPI {

    // MARK: - GET -
    
    /**
     Gets a playlist, including its tracks and additional
     information about it.
     
     **Beta Note**: Currently, only the tracks from the playlist
     will be included (podcast episodes will not be returned).
     
     In contrast to `playlistTracks(_:limit:offset:market:)`,
     additional data about the playlist itself will be
     retrieved, including its name and any images associated with
     it. See also `getPlaylistCoverImage(_:)`.
     
     No scopes are required for this endpoint. Both Public and
     Private playlists belonging to any user can be retrieved.
     
     # Returns:
     ```
     Playlist<PagingObject<PlaylistItemContainer<Track>>>
     ```
     
     The full version of the playlist and tracks will be returned.
     
     To access just the tracks, use:
     ```
     playlist.items.items.map(\.item)
     ```
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][2]
             or the string "from_token". Provide this parameter if you want
             to apply [Track Relinking][3].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    func playlist(
        _ playlist: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<Playlist<PlaylistTracks>, Error> {
        
        do {
            
            let playlistId = try SpotifyIdentifier(uri: playlist).id

            return self.getRequest(
                path: "/playlists/\(playlistId)",
                queryItems: [
                    "market": market,
                    "additional_types": IDCategory.track.rawValue
                ],
                requiredScopes: []
            )
            .spotifyDecode(Playlist<PlaylistTracks>.self)
            
        } catch {
            return error.anyFailingPublisher(
                Playlist<PlaylistTracks>.self
            )
        }
        
        
    }
    
    /**
     Get the current images associated with a specific playlist.
     
     See also `playlist(_:market:)`.
     
     Read more at the [Spotify web API reference][1].

     - Parameter playlist: A Spotify playlist.
     - Returns: An array of image objects, which contain the url for
           the image and its dimensions.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist-cover/
     */
    func getPlaylistCoverImage(
        _ playlist: SpotifyURIConvertible
    ) -> AnyPublisher<[SpotifyImage], Error> {
        
        do {
            
            let playlistId = try SpotifyIdentifier(uri: playlist).id
            
            return self.getRequest(
                path: "/playlists/\(playlistId)/images",
                queryItems: [:],
                requiredScopes: []
            )
            .spotifyDecode([SpotifyImage].self)
    
        } catch {
            return error.anyFailingPublisher([SpotifyImage].self)
        }
        
    }
    
    /**
     Get all of the tracks in a playlist.
     Episodes in the playlist will not be returned.
     
     See also `playlist(_:market:)`, which retrieves additional
     information about the playlist itself, such as its name and
     any images associated with it, whereas this method only
     retrieves the tracks from the playlist.
     
     No scopes are required for this endpoint. Tracks from both Public
     and Private playlists belonging to any user can be retrieved.
     
     Compared to the `Playlist` method, this method
     does not return any data about the playlist itself.
     
     # Returns:
     ```
     PagingObject<PlaylistItemContainer<Track>>
     ```
     The full versions of the tracks will be returned.

     To get an array of just the tracks, use:
     
     ```
     playlistTracks.items.map(\.item)
     ```
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - limit: *Optional*. The maximum number of items to return.
             Default: 100; minimum: 1; maximum: 100.
       - offset: *Optional*. The index of the first item to return.
             Default: 0. Use with `limit` to get the next set of tracks.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][2]
            or the string "from_token". Provide this parameter if you want
            to apply [Track Relinking][3].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlists-tracks/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    func playlistTracks(
        _ playlist: SpotifyURIConvertible,
        limit: Int? = nil,
        offset: Int? = nil,
        market: String? = nil
    ) -> AnyPublisher<PlaylistTracks, Error> {
        
        do {
            
            let playlistId = try SpotifyIdentifier(uri: playlist).id
        
            return self.getRequest(
                path: "/playlists/\(playlistId)/tracks",
                queryItems: [
                    "limit": limit,
                    "offset": offset,
                    "market": market,
                    // restrict response to only tracks.
                    "additional_types": IDCategory.track.rawValue
                ],
                requiredScopes: []
            )
            .spotifyDecode(PlaylistTracks.self)
        
        } catch {
            return error.anyFailingPublisher(PlaylistTracks.self)
        }
    }
    
    
    /**
     Get a list of the current user's playlists, including those
     that they are following.
     
     See also `userPlaylists(for:limit:offset:)`.
     
     No scopes are required for retrieving the user's public playlists.
     Requires the `playlistReadPrivate` scope for retrieving private
     playlists. The `playlistReadCollaborative` scope is required to
     retrieve collarborative playlists, even though these are also
     always private. See also [Working with Playlists][1].

     # Returns:
     ```
     PagingObject<Playlist<TracksEpisodesReference>
     ```
     
     The simplified versions of the playlists will be returned.
     
     A `TracksEpisodesReference` simply contains a link to all of the
     tracks/episodes and the total number in the playlist. However,
     to get all of the tracks in each playlist, you should use
     `playlistTracks(_:limit:offset:market:)` instead, passing in
     the uri of each of the playlists. To get all of the uris, use:
     ```
     playlists.items.map(\.uri)
     ```
     
     Read more at the [Spotify web API reference][2].

     - Parameters:
       - limit: *Optional*. The maximum number of playlists to return.
             Default: 20; Minimum: 1; Maximum: 50.
       - offset: *Optional*. The index of the first playlist to return.
             Default: 0; Maximum: 100,000. Use with `limit` to get the next
             set of playlists.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/
     [2]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-a-list-of-current-users-playlists/
     */
    func currentUserPlaylists(
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<PagingObject<Playlist<TracksEpisodesReference>>, Error> {
        
        return self.getRequest(
            path: "/me/playlists",
            queryItems: [
                "limit": limit,
                "offset": offset
            ],
            requiredScopes: []
        )
        .spotifyDecode(PagingObject<Playlist<TracksEpisodesReference>>.self)
        
    }
    
    
    /**
     Get a list of the playlists for a user, including those that
     they are following.
     
     See also `currentUserPlaylists(limit:offset:)`
     
     Private playlists are only retrievable for the current user and requires
     the `playlistReadPrivate` scope to have been authorized by the user.
     Note that this scope alone will not return collaborative playlists,
     even though they are always private. Collaborative playlists are only
     retrievable for the current user and requires the
     `playlistReadCollaborative` scope to have been authorized by the user.
     See also [Working with Playlists][1].
     
     # Returns:
     ```
     PagingObject<Playlist<TracksEpisodesReference>
     ```
     
     The simplified versions of the playlists will be returned.
     
     A `TracksEpisodesReference` simply contains a link to all of the
     tracks/episodes and the total number in the playlist. However,
     to get all of the tracks in each playlist, you should use
     `playlistTracks(_:limit:offset:market:)` instead, passing in
     the uri of each of the playlists. To get all of the uris, use:
     ```
     playlists.items.map(\.uri)
     ```
     
     Read more at the [Spotify web API reference][2].
     
     - Parameters:
       - userURI: the URI of a Spotify user.
       - limit: *Optional*. The maximum number of playlists to return.
             Default: 20; Minimum: 1; Maximum: 50.
       - offset: *Optional*. The index of the first playlist to return.
             Default: 0; Maximum: 100,000. Use with `limit` to get the next
             set of playlists.
     
     [1]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/
     [2]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-list-users-playlists/
     */
    func userPlaylists(
        for userURI: SpotifyURIConvertible,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<PagingObject<Playlist<TracksEpisodesReference>>, Error> {
        
        do {
            
            let userId = try SpotifyIdentifier(uri: userURI).id
        
            return self.getRequest(
                path: "/users/\(userId)/playlists",
                queryItems: [
                    "limit": limit,
                    "offset": offset
                ],
                requiredScopes: []
            )
            .spotifyDecode(PagingObject<Playlist<TracksEpisodesReference>>.self)
    
        } catch {
            return error.anyFailingPublisher(
                PagingObject<Playlist<TracksEpisodesReference>>.self
            )
        }
        
        
    }
    
 
    // MARK: - POST -
    
    /**
     Add tracks/episodes to a playlist.
     
     Adding items to the current user’s public playlists requires
     authorization of the `playlistModifyPublic` scope; adding items
     to the current user’s private playlist (including collaborative
     playlists) requires the `playlistModifyPrivate` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - uris: An Array of URIs for tracks/episodes.
             A maximum of 100 items can be added in one request.
       - position: *Optional*. The position to insert the items.
             A zero-based index. If `nil`, the items will be
             appended to the list.
     - Returns: The [snapshot id][2] of the playlist, which is an identifier for
           the current version of the playlist. Every time the playlist
           changes, a new snapshot id is generated. You can use this value
           to efficiently determine whether a playlist has changed since
           the last time you retrieved it. Can be supplied in other requests
           to target a specific playlist version.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/add-tracks-to-playlist/
     [2]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    func addToPlaylist(
        _ playlist: SpotifyURIConvertible,
        uris: [SpotifyURIConvertible],
        position: Int? = nil
    ) -> AnyPublisher<String, Error> {
       
        let urisDict = URIsDictWithInsertionIndex (
            uris: uris, postion: position
        )
        
        return self.modifyPlaylist(
            playlist,
            httpMethod: "POST",
            queryItems: [:],
            body: urisDict,
            // we can't know in advance which playlist the items
            // will be added to.
            requiredScopes: []
        )
        
    }
    
    /**
     Create a playlist for a Spotify user. The playlist will be empty
     until you add tracks.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - userURI: The URI of a user. **The access token must have been
           issued on behalf of this user.**
       - playlistDetails: The details of the playlist.
     - Returns: The playlist.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/create-playlist/
     */
    func createPlaylist(
        for userURI: SpotifyURIConvertible,
        _ playlistDetails: PlaylistDetails
    ) -> AnyPublisher<Playlist<PlaylistTracks>, Error> {
        
        do {
            
            let userId = try SpotifyIdentifier(uri: userURI).id
            
            func makeHeaders(accessToken: String) -> [String: String] {
                return Headers.bearerAuthorization(accessToken) +
                    Headers.acceptApplicationJSON
            }
            
            return self.apiRequest(
                path: "/users/\(userId)/playlists",
                queryItems: [:],
                httpMethod: "POST",
                makeHeaders: makeHeaders(accessToken:),
                body: playlistDetails,
                requiredScopes: []
            )
            .spotifyDecode(Playlist<PlaylistTracks>.self)
            
        } catch {
            return error.anyFailingPublisher(Playlist<PlaylistTracks>.self)
        }
        
        
    }
    
    // MARK: - PUT -
    
    /**
     Reorders the tracks/episodes in a playlist.
     
     See also ``removeSpecificOccurencesFromPlaylist(_:urisWithPostions:)`,
     `removeAllOccurencesFromPlaylist(_:uris:)`, and
     `replaceAllPlaylistItems(_:with:)`.
     
     
     Reordering items in the current user’s public playlists requires
     authorization of the `playlistModifyPublic` scope; reordering items
     in the current user’s private playlist (including collaborative playlists)
     requires the `playlistModifyPrivate` scope.
     
     The body of the request contains the following properties:
     
     * rangeStart: The position of the first item to be reordered.
     * rangeLength: The amount of items to be reordered. Defaults to 1.
     * insertBefore: The position where the items should be inserted.
     * snapshotId: *Optional*. The version identifier for the current playlist.
     
     # Examples:
     
     To reorder the first item to the last position in a playlist with 10 items,
     set `rangeStart` to 0, set `rangeLength` to 0 (default) and
     `insertBefore` to 10.
     
     To reorder the last item in a playlist with 10 items to the start of
     the playlist, set `rangeStart` to 9, set `rangeLength` to 0 (default)
     and set `insertBefore` to 0.
     
     To move the items at index 9-10 to the start of the playlist,
     set `rangeStart` to 9, set `rangeLength` to 2, and set
     `insertBefore` to 0.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - body: An instance of `ReorderPlaylistItems.` See above.
     - Returns: The [snapshot id][2] of the playlist, which is an identifier for
           the current version of the playlist. Every time the playlist
           changes, a new snapshot id is generated. You can use this value
           to efficiently determine whether a playlist has changed since
           the last time you retrieved it. Can be supplied in other requests
           to target a specific playlist version.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/reorder-playlists-tracks/
     [2]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    func reorderPlaylistItems(
        _ playlist: SpotifyURIConvertible,
        body: ReorderPlaylistItems
    ) -> AnyPublisher<String, Error> {
        
        return self.modifyPlaylist(
            playlist,
            httpMethod: "PUT",
            queryItems: [:],
            body: body,
            // we can't know in advance which playlist
            // is being modified.
            requiredScopes: []
        )
        
    }
    
    /**
     Replace all the tracks/episodes in a playlist with new items.
     
     See also `removeSpecificOccurencesFromPlaylist(_:urisWithPostions:)`,
     `removeAllOccurencesFromPlaylist(_:uris:)`, and
     `reorderPlaylistItems(_:body:)`.
     
     Setting items in the current user’s public playlists requires
     authorization of the `playlistModifyPublic` scope; setting items in
     the current user’s private playlist (including collaborative playlists)
     requires the `playlistModifyPrivate` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - newItems: The new items to replace all of the current items with.
             **Pass in an empty array to remove all of the items from
             the playlist**.
     - Returns: The [snapshot id][2] of the playlist, which is an identifier for
           the current version of the playlist. Every time the playlist
           changes, a new snapshot id is generated. You can use this value
           to efficiently determine whether a playlist has changed since
           the last time you retrieved it. Can be supplied in other requests
           to target a specific playlist version.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/replace-playlists-tracks/
     [2]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    func replaceAllPlaylistItems(
        _ playlist: SpotifyURIConvertible,
        with newItems: [SpotifyURIConvertible]
    ) -> AnyPublisher<String, Error> {
        
        let body = ["uris": newItems.map(\.uri)]
        
        return self.modifyPlaylist(
            playlist,
            httpMethod: "PUT",
            queryItems: [:],
            body: body,
            requiredScopes: []
        )
        
    }
    
    /**
     Change the details of a playlist.
     
     Changing a public playlist for a user requires authorization of
     the `playlistModifyPublic` scope; changing a private playlist
     requires the `playlistModifyPrivate` scope.
     
     The details of the playlist that can be changed are:
     
     * name: The new name for the playlist.
     * isPublic: If `true` the playlist will be public;
           if `false` it will be private.
     * collaborative: If `true`, the playlist will become collaborative
           and other users will be able to modify the playlist in their
           Spotify client. **Note**: You can only set collaborative to `true`
           on non-public playlists.
     * description: A new playlist description as displayed in
           Spotify Clients and in the Web API.
     
     All of the properties are optional. The value of each non-`nil` property
     will be used update the details of the playlist.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - newDetails: The new details to update the playlist with.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/change-playlist-details/
     */
    func changePlaylistDetails(
        _ playlist: SpotifyURIConvertible,
        to newDetails: PlaylistDetails
    ) -> AnyPublisher<Void, Error> {
        
        do {
            
            let playlistId = try SpotifyIdentifier(uri: playlist.uri).id
    
            func makeHeaders(accessToken: String) -> [String: String] {
                return Headers.bearerAuthorization(accessToken) +
                    Headers.acceptApplicationJSON
            }
            
            return self.apiRequest(
                path: "/playlists/\(playlistId)",
                queryItems: [:],
                httpMethod: "PUT",
                makeHeaders: makeHeaders(accessToken:),
                body: newDetails,
                requiredScopes: []
            )
            .map { _ in }
            .eraseToAnyPublisher()
        
        } catch {
            return error.anyFailingPublisher(Void.self)
        }
        
    }
    
    
    /**
     Upload an image for a playlist.
     
     This endpoint requires the `ugcImageUpload` scope.
     In addition, the `playlistModifyPublic` scope is required
     for public playlists, and the `playlistModifyPrivate` scope
     is required for private playlists.
     
     To convert a `UIImage` to base64-encoded jpeg data, use.
     ```
     let jpegData = uiImage.jpegData(
         compressionQuality: 0.5
     )!
     let base64EncodedData = jpegData.base64EncodedData()
     ```
     Adjust the compression quality as needed to ensure the size
     is below 256 KB.
     
     The process of uploading the image may take some time,
     so performing a request for this playlist may not immediately
     return the image.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - imageData: Base64-encoded JPEG image data.
             **Maximum size is 256 KB.**

     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/upload-custom-playlist-cover/
     */
    func uploadPlaylistImage(
        _ playlist: SpotifyURIConvertible,
        imageData: Data
    ) -> AnyPublisher<Void, Error> {
        
        let thisFunction = #function
        
        do {

            if imageData.count >= 256_000 {
                
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useKB]
                formatter.countStyle = .file
                let size = formatter.string(
                    fromByteCount: Int64(imageData.count)
                )
                print(
                    """
                    --------------------------------------------------------
                    SpotifyAPI.uploadPlaylistImage: WARNING:
                    the size of the image that you are uploading (\(size))
                    is larger than Spotify's limit of 256 KB.
                    You may experience errors, such as those indicating you
                    lost connection to the network.
                    --------------------------------------------------------
                    """
                )
                
            }
            
            
            let playlistId = try SpotifyIdentifier(uri: playlist).id
            
            func makeHeaders(accessToken: String) -> [String: String] {
                return Headers.bearerAuthorization(accessToken) +
                    Headers.imageJpeg
            }
            
            return self.apiRequest(
                path: "/playlists/\(playlistId)/images",
                queryItems: [:],
                httpMethod: "PUT",
                makeHeaders: makeHeaders(accessToken:),
                bodyData: imageData,
                requiredScopes: [.ugcImageUpload]
            )
            .map { data, urlResponse in
            
                let statusCode = (urlResponse as! HTTPURLResponse).statusCode
                self.spotifyAPILogger.trace(
                    "status code: \(statusCode)",
                    function: thisFunction
                )
            
            }
            .eraseToAnyPublisher()
            
            
        } catch {
            return error.anyFailingPublisher(Void.self)
        }
        
    }
    
    
    
    // MARK: - DELETE -
    
    /**
     Removes **all** occurences of the specified tracks/episodes
     from a playlist.
     
     See also
     `removeSpecificOccurencesFromPlaylist(_:urisWithPostions:)`.
     
     Removing items from a user’s public playlist requires authorization
     of the `playlistModifyPublic` scope; removing items from a
     private playlist requires the `playlistModifyPrivate` scope.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - playlist: The URI for a playlist.
       - uris: An Array of URIs for tracks/episodes.
             A maximum of 100 items can be removed at once.
     - Returns: The [snapshot id][2] of the playlist, which is an identifier for
           the current version of the playlist. Every time the playlist
           changes, a new snapshot id is generated. You can use this value
           to efficiently determine whether a playlist has changed since
           the last time you retrieved it. Can be supplied in other requests
           to target a specific playlist version.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/remove-tracks-playlist/
     [2]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    func removeAllOccurencesFromPlaylist(
        _ playlist: SpotifyURIConvertible,
        of uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<String, Error> {
        
        return self.modifyPlaylist(
            playlist,
            httpMethod: "DELETE",
            queryItems: [:],
            body: URIsDict(uris),
            // we can't know in advance which playlist
            // is being modified.
            requiredScopes: []
        )
            
    }
    
    /**
     Removes the specified tracks/episodes at the specified positions
     from a playlist. This is useful if the playlist contains duplicate
     items.
     
     See also
     `removeAllOccurencesFromPlaylist(_:uris:)`.
     
     Removing items from a user’s public playlist requires authorization
     of the `playlistModifyPublic` scope; removing items from a
     private playlist requires the `playlistModifyPrivate` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI for a playlist.
       - urisWithPostions: A collection of uris along with their positions
         in a playlist and, optionally, the snapshot id of the playlist
         you want to target.
     - Returns: The [snapshot id][2] of the playlist, which is an identifier for
           the current version of the playlist. Every time the playlist
           changes, a new snapshot id is generated. You can use this value
           to efficiently determine whether a playlist has changed since
           the last time you retrieved it. Can be supplied in other requests
           to target a specific playlist version.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/remove-tracks-playlist/
     [2]: https://developer.spotify.com/documentation/general/guides/working-with-playlists/#version-control-and-snapshots
     */
    func removeSpecificOccurencesFromPlaylist(
        _ playlist: SpotifyURIConvertible,
        of urisWithPostions: URIsWithPositionsContainer
    ) -> AnyPublisher<String, Error>{
        
        return self.modifyPlaylist(
            playlist,
            httpMethod: "DELETE",
            queryItems: [:],
            body: urisWithPostions,
            // we can't know in advance which playlist
            // is being modified.
            requiredScopes: []
        )
        
    }
    
    
    
}

