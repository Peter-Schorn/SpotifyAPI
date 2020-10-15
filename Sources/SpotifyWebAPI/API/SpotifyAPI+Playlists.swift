import Foundation
import Combine

private extension SpotifyAPI {
    
    /// Use for post/put/delete requests to the "/playlists/{playlistId}/tracks"
    /// endpoint in which the response is the snapshot id of the playlist.
    func modifyPlaylist<Body: Encodable>(
        _ playlist: SpotifyURIConvertible,
        httpMethod: String,
        queryItems: [String: LosslessStringConvertible?],
        body: Body,
        requiredScopes: Set<Scope>
    ) -> AnyPublisher<String, Error> {
    
        do {
    
            let playlistId = try SpotifyIdentifier(
                uri: playlist, ensureCategoryMatches: [.playlist]
            ).id
            
            return self.apiRequest(
                path: "/playlists/\(playlistId)/tracks",
                queryItems: queryItems,
                httpMethod: httpMethod,
                makeHeaders: Headers.bearerAuthorizationAndContentTypeJSON(_:),
                body: body,
                requiredScopes: requiredScopes
            )
            .decodeSpotifyObject([String: String].self)
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
            return error.anyFailingPublisher()
        }
    
    }
    
    func _playlistItems(
        _ playlist: SpotifyURIConvertible,
        filters: String?,
        limit: Int?,
        offset: Int?,
        market: String?,
        additionalTypes: [IDCategory]
    ) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        
        do {
            
            let playlistId = try SpotifyIdentifier(
                uri: playlist, ensureCategoryMatches: [.playlist]
            ).id
            
            let fixedAdditionalTypes = try self.validateAdditionalTypes(
                additionalTypes
            )?.commaSeparatedString()
        
            return self.getRequest(
                path: "/playlists/\(playlistId)/tracks",
                queryItems: [
                    "fields": filters,
                    "limit": limit,
                    "offset": offset,
                    "market": market,
                    "additional_types": fixedAdditionalTypes
                ],
                requiredScopes: []
            )
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Ensure that `additionalTypes` only contains `track` or `episode`.
     Else, throw an error. If `additionalTypes` is empty, then return
     `nil` so that when it is converted to a query parameter using
     `commaSeparatedString()`, `nil` is returned instead of an empty string.
     If the value for the "additional_types" query parameter is an empty
     string, then Spotify will return a "Bad search type field" error.
     */
    func validateAdditionalTypes(
        _ additionalTypes: [IDCategory]
    ) throws -> [IDCategory]? {
     
        let validTypes: [IDCategory] = [.track, .episode]
        
        if additionalTypes.isEmpty {
            return nil
        }
        else {
            guard additionalTypes.allSatisfy({ validTypes.contains($0) }) else {
                throw SpotifyLocalError.other(
                    """
                    Valid types for 'additionalTypes' are \
                    \(validTypes.map(\.rawValue)), \
                    but recieved: \(additionalTypes.map(\.rawValue)).
                    """
                )
            }
            return additionalTypes
        }
        
    }
    
}

public extension SpotifyAPI {

    // MARK: Playlists

    /// This method has been renamed to
    /// `filteredPlaylist(_:filters:additionalTypes:market:)`.
    @available(*, deprecated, renamed: "filteredPlaylist(_:filters:additionalTypes:market:)")
    func filteredPlaylistRequest(
        _ playlist: SpotifyURIConvertible,
        filters: String,
        additionalTypes: [IDCategory],
        market: String? = nil
    ) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
    
        return self.filteredPlaylist(
            playlist,
            filters: filters,
            additionalTypes: additionalTypes,
            market: market
        )
    
    }
    
    /**
     Makes a request to the "/playlists/{playlistId}" endpoint
     and allows you to specify fields to filter the query.

     See also:
     
     * `filteredPlaylistItems(_:filters:additionalTypes:limit:offset:market:)`
     * `playlist(_:market:)`
     * `playlistItems(_:limit:offset:market:)`
     * `playlistTracks(_:limit:offset:market:)`
     * `playlistImage(_:)`
     
     No scopes are required for this endpoint. Both Public and Private
     playlists belonging to any user can be retrieved.
     
     Use the [Spotify console][1] to test your queries, then copy and paste the
     response into this [online JSON viewer][2].
     
     You are also encouraged to assign a folder to
     `SpotifyDecodingError.dataDumpFolder`—or assign a value to the environment
     variable "data_dump_folder", which is what `dataDumpFolder` is initialized
     to—so that the data will be written to a folder when the decoding fails.
     You can then upload this file to the JSON viewer. Set the `logLevel` of
     `spotifyDecodeLogger` to `trace` to print the raw data of all requests to
     the standard output.
     
     When decoding the data, use the combine operators `decodeSpotifyObject(_:)`
     or `decodeOptionalSpotifyObject(_:)` instead of `decode(type:decoder:)`,
     otherwise the above doesn't apply.
     
     Read more at the [Spotify web API reference][3].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - filters: *Required*. Filters for the query: a comma-separated list
             (no spaces) of the fields to return. If omitted, all fields are
             returned. For example, to get just the playlist’s description
             and URI: "description,uri". A dot separator can be used to specify
             non-reoccurring fields, while parentheses can be used to specify
             reoccurring fields within objects. For example, to get just the added
             date and user ID of the adder: "tracks.items(added_at,added_by.id)".
             Use multiple parentheses to drill down into nested objects, for example: "tracks.items(track(name,href,album(name,href)))". Fields can be
             excluded by prefixing them with an exclamation mark, for example:
             "tracks.items(track(name,href,album(!name,href)))".
       - additionalTypes: *Required*. An array of id categories. Valid types
             are `track` and `episode`. If you provide `[]` or `[.track]`,
             then both tracks and episodes will be returned in the `Track`
             format. In this case, trying to decode episodes into `PlaylistItem`
             or `Episode` will always fail. Instead, both tracks and episodes
             must be decoded into `Track`. If you expect the the playlist to
             have both tracks and episodes, then use `[.episode]` or
             `[.track, .episode]` and decode the tracks and episodes into
             `PlaylistItem`.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][4] or the string
             "from_token". For tracks, Provide this parameter if you want to apply
             [Track Relinking][5]. For episodes, if the access token was granted on
             behalf of a user (i.e., if you authorized your application using the
             authorization code flow or the authorization code flow with proof key
             for code exchange), the country associated with the user account will
             take priority over this parameter. Users can view the country that
             is associated with their account in the [account settings][6].
     
            **Note: If neither market or user**
             **country are provided, the episodes are considered unavailable for**
             **the client and** `nil` **will will be returned at the**
             **corresponding positions for each episode. Therefore, if you**
             **authorized your application using the client credentials flow and**
             **you want to retrieve the episodes in a playlist, you must provide**
             **a value for this parameter.**
     - Returns: The raw data and URL response from the server. Because the response
           is entirely dependent on the filters you specify, you are responsible
           for decoding the data. Use the combine operators
           `decodeSpotifyObject(_:)` or `decodeOptionalSpotifyObject(_:)` instead
           `decode(type:decoder:)`. Any error objects returned by Spotify will be
           decoded automatically and thrown as an error to downstream subscribers.
     
     [1]: https://developer.spotify.com/console/get-playlist/
     [2]: https://jsoneditoronline.org/
     [3]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist/
     [4]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [5]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     [6]: https://www.spotify.com/se/account/overview/
     */
    func filteredPlaylist(
        _ playlist: SpotifyURIConvertible,
        filters: String,
        additionalTypes: [IDCategory],
        market: String? = nil
    ) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        
        do {
            let playlistId = try SpotifyIdentifier(
                uri: playlist, ensureCategoryMatches: [.playlist]
            ).id
        
            let fixedAdditionalTypes = try self.validateAdditionalTypes(
                additionalTypes
            )?.commaSeparatedString()
            
            return self.getRequest(
                path: "/playlists/\(playlistId)",
                queryItems: [
                    "fields": filters,
                    "additional_types": fixedAdditionalTypes,
                    "market": market,
                ],
                requiredScopes: []
            )
            .decodeSpotifyErrors()
        
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Gets a playlist, including its tracks/episodes and additional
     information about it.
     
     See also:
     
     * `playlistItems(_:limit:offset:market:)`
     * `playlistTracks(_:limit:offset:market:)`
     * `filteredPlaylist(_:fields:additionalTypes:market:)`
     * `filteredPlaylistItems(_:filters:additionalTypes:limit:offset:market:)`
     * `playlistImage(_:)`
     
     In contrast to the above methods, additional data about the playlist itself will
     be retrieved, including its name and any images associated with it.

     No scopes are required for this endpoint. Both Public and Private playlists
     belonging to any user can be retrieved.
     
     # Returnss:
     ```
     Playlist<PagingObject<PlaylistItemContainer<PlaylistItem>>>
     ```
     
     The full version of the playlist will be returned.
     
     To access just the tracks/episodes, use:
     ```
     let playlistItems: [PlaylistItem] = playlist.items.items.compactMap(\.item)
     ```
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". For tracks, Provide this parameter if you want to apply
             [Track Relinking][3]. For episodes, if the access token was granted on
             behalf of a user (i.e., if you authorized your application using the
             authorization code flow or the authorization code flow with proof key
             for code exchange), the country associated with the user account will
             take priority over this parameter. Users can view the country that
             is associated with their account in the [account settings][4].
     
            **Note: If neither market or user**
             **country are provided, the episodes are considered unavailable for**
             **the client and** `nil` **will will be returned at the**
             **corresponding positions for each episode. Therefore, if you**
             **authorized your application using the client credentials flow and**
             **you want to retrieve the episodes in a playlist, you must provide**
             **a value for this parameter.**
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     [4]: https://www.spotify.com/se/account/overview/
     */
    func playlist(
        _ playlist: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<Playlist<PlaylistItems>, Error> {
        
        do {
            
            let playlistId = try SpotifyIdentifier(
                uri: playlist, ensureCategoryMatches: [.playlist]
            ).id

            let additionalTypes: [IDCategory] = [.track, .episode]
            
            return self.getRequest(
                path: "/playlists/\(playlistId)",
                queryItems: [
                    "market": market,
                    "additional_types": additionalTypes.commaSeparatedString()
                ],
                requiredScopes: []
            )
            .decodeSpotifyObject(Playlist<PlaylistItems>.self)
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Makes a request to the "/playlists/{playlistId}/tracks" endpoint
     and allows you to specify fields to filter the query.

     Unlike, `filteredPlaylist(_:filters:additionalTypes:market:)`,
     this endpoint allows you to request different pages of results.
     
     See also:
     
     * `filteredPlaylist(_:filters:additionalTypes:market:)`
     * `playlist(_:market:)`
     * `playlistItems(_:limit:offset:market:)`
     * `playlistTracks(_:limit:offset:market:)`
     * `playlistImage(_:)`
     
     No scopes are required for this endpoint. Both Public and Private
     playlists belonging to any user can be retrieved.
     
     You are also encouraged to assign a folder to
     `SpotifyDecodingError.dataDumpFolder`—or assign a value to the environment
     variable "data_dump_folder", which is what `dataDumpFolder` is initialized
     to—so that the data will be written to a folder when the decoding fails.
     You can then upload this file to the JSON viewer. Set the `logLevel` of
     `spotifyDecodeLogger` to `trace` to print the raw data of all requests to
     the standard output.
     
     When decoding the data, use the combine operators `decodeSpotifyObject(_:)`
     or `decodeOptionalSpotifyObject(_:)` instead of `decode(type:decoder:)`,
     otherwise the above doesn't apply.
     
     Read more at the [Spotify web API reference][3].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - filters: *Required*. Filters for the query: a comma-separated list
             (no spaces) of the fields to return. If omitted, all fields are
             returned. For example, to get just the playlist’s description
             and URI: "description,uri". A dot separator can be used to specify
             non-reoccurring fields, while parentheses can be used to specify
             reoccurring fields within objects. For example, to get just the added
             date and user ID of the adder: "tracks.items(added_at,added_by.id)".
             Use multiple parentheses to drill down into nested objects, for example: "tracks.items(track(name,href,album(name,href)))". Fields can be
             excluded by prefixing them with an exclamation mark, for example:
             "tracks.items(track(name,href,album(!name,href)))".
       - additionalTypes: *Required*. An array of id categories. Valid types
             are `track` and `episode`. If you provide `[]` or `[.track]`,
             then both tracks and episodes will be returned in the `Track`
             format. In this case, trying to decode episodes into `PlaylistItem`
             or `Episode` will always fail. Instead, both tracks and episodes
             must be decoded into `Track`. If you expect the the playlist to
             have both tracks and episodes, then use `[.episode]` or
             `[.track, .episode]` and decode the tracks and episodes into
             `PlaylistItem`.
       - limit: *Optional*. The maximum number of items to return.
             Default: 100; minimum: 1; maximum: 100.
       - offset: *Optional*. The index of the first item to return.
             Default: 0. Use with `limit` to get the next set of tracks.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][4] or the string
             "from_token". For tracks, Provide this parameter if you want to apply
             [Track Relinking][5]. For episodes, if the access token was granted on
             behalf of a user (i.e., if you authorized your application using the
             authorization code flow or the authorization code flow with proof key
             for code exchange), the country associated with the user account will
             take priority over this parameter. Users can view the country that
             is associated with their account in the [account settings][6].
     
            **Note: If neither market or user**
             **country are provided, the episodes are considered unavailable for**
             **the client and** `nil` **will will be returned at the**
             **corresponding positions for each episode. Therefore, if you**
             **authorized your application using the client credentials flow and**
             **you want to retrieve the episodes in a playlist, you must provide**
             **a value for this parameter.**
     - Returns: The raw data and URL response from the server. Because the response
           is entirely dependent on the filters you specify, you are responsible
           for decoding the data. Use the combine operators
           `decodeSpotifyObject(_:)` or `decodeOptionalSpotifyObject(_:)` instead
           `decode(type:decoder:)`. Any error objects returned by Spotify will be
           decoded automatically and thrown as an error to downstream subscribers.
     
     [1]: https://developer.spotify.com/console/get-playlist-tracks/
     [2]: https://jsoneditoronline.org/
     [3]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlists-tracks/
     [4]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [5]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     [6]: https://www.spotify.com/se/account/overview/
     */
    func filteredPlaylistItems(
        _ playlist: SpotifyURIConvertible,
        filters: String,
        additionalTypes: [IDCategory],
        limit: Int? = nil,
        offset: Int? = nil,
        market: String? = nil
    ) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        
        return self._playlistItems(
            playlist,
            filters: filters,
            limit: limit,
            offset: offset,
            market: market,
            additionalTypes: additionalTypes
        )
        .decodeSpotifyErrors()
        
    }
    
    /**
     Get all of the tracks in a playlist.
     
     # Warning
     
     **This endpoint does NOT return only the tracks in a playlist.**
     Instead, it returns both the tracks and episodes in `Track` format.
     You are discouraged from using this endpoint unless you are certain
     that the playlist only contains tracks. If unsure, use
     `playlistItems(_:limit:offset:market:)` instead. Use the `type` property
     of `Track` to check if it is actually a track.
     
     See also:
     
     * `playlistItems(_:limit:offset:market:)`
     * `playlist(_:market:)`
     * `filteredPlaylist(_:fields:additionalTypes:market:)`
     * `filteredPlaylistItems(_:filters:additionalTypes:limit:offset:market:)`
     * `playlistImage(_:)`
     
     No scopes are required for this endpoint. Tracks from both Public
     and Private playlists belonging to any user can be retrieved.
     
     # Returns:
     ```
     PagingObject<PlaylistItemContainer<Track>>
     ```
     The full versions of the tracks will be returned.

     To get an array of just the tracks, use:
     ```
     let tracks: [Track] = playlistTracks.items.compactMap(\.item)
     ```
     
     Read more at the [Spotify web API reference][1].
 
     - Parameters:
       - playlist: The URI of a playlist.
       - limit: *Optional*. The maximum number of items to return.
             Default: 100; minimum: 1; maximum: 100.
       - offset: *Optional*. The index of the first item to return.
             Default: 0. Use with `limit` to get the next set of tracks.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". For tracks, Provide this parameter if you want to apply
             [Track Relinking][3]. For episodes, if the access token was granted on
             behalf of a user (i.e., if you authorized your application using the
             authorization code flow or the authorization code flow with proof key
             for code exchange), the country associated with the user account will
             take priority over this parameter. Users can view the country that
             is associated with their account in the [account settings][4].
             
            **Note: If neither market or user**
             **country are provided, the episodes are considered unavailable for**
             **the client and** `nil` **will will be returned at the**
             **corresponding positions for each episode. Therefore, if you**
             **authorized your application using the client credentials flow and**
             **you want to retrieve the episodes in a playlist, you must provide**
             **a value for this parameter.**
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlists-tracks/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     [4]: https://www.spotify.com/se/account/overview/
     */
    func playlistTracks(
        _ playlist: SpotifyURIConvertible,
        limit: Int? = nil,
        offset: Int? = nil,
        market: String? = nil
    ) -> AnyPublisher<PlaylistTracks, Error> {
        
        return self._playlistItems(
            playlist,
            filters: nil,
            limit: limit,
            offset: offset,
            market: market,
            additionalTypes: [.track]
        )
        .decodeSpotifyObject(PlaylistTracks.self)

    }
    
    /**
     Get all of the episodes and tracks in a playlist.
     
     See also:
     
     * `playlistTracks(_:limit:offset:market:)`
     * `playlist(_:market:)`
     * `filteredPlaylist(_:fields:additionalTypes:market:)`
     * `filteredPlaylistItems(_:filters:additionalTypes:limit:offset:market:)`
     * `playlistImage(_:)`
     
     No scopes are required for this endpoint. Tracks from both Public
     and Private playlists belonging to any user can be retrieved.
     
     # Returns:
     ```
     PagingObject<PlaylistItemContainer<PlaylistItem>>
     ```
     
     To get an array of just the tracks/episdoes, use:
     ```
     let items: [PlaylistItem] = playlistItems.items.compactMap(\.item)
     ```

     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - limit: *Optional*. The maximum number of items to return.
             Default: 100; minimum: 1; maximum: 100.
       - offset: *Optional*. The index of the first item to return.
             Default: 0. Use with `limit` to get the next set of tracks.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". For tracks, Provide this parameter if you want to apply
             [Track Relinking][3]. For episodes, if the access token was granted on
             behalf of a user (i.e., if you authorized your application using the
             authorization code flow or the authorization code flow with proof key
             for code exchange), the country associated with the user account will
             take priority over this parameter. Users can view the country that
             is associated with their account in the [account settings][4].
     
            **Note: If neither market or user**
             **country are provided, the episodes are considered unavailable for**
             **the client and** `nil` **will will be returned at the**
             **corresponding positions for each episode. Therefore, if you**
             **authorized your application using the client credentials flow and**
             **you want to retrieve the episodes in a playlist, you must provide**
             **a value for this parameter.**
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlists-tracks/
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     [4]: https://www.spotify.com/se/account/overview/
     */
    func playlistItems(
        _ playlist: SpotifyURIConvertible,
        limit: Int? = nil,
        offset: Int? = nil,
        market: String? = nil
    ) -> AnyPublisher<PlaylistItems, Error> {
        
        return self._playlistItems(
            playlist,
            filters: nil,
            limit: limit,
            offset: offset,
            market: market,
            additionalTypes: [.track, .episode]
        )
        .decodeSpotifyObject(PlaylistItems.self)
        
    }
    
    /**
     Get a list of the playlists for a user, including those that
     they are following.
     
     See also `currentUserPlaylists(limit:offset:)`.
     
     No scopes are required for retrieving the public playlists of any
     user. Private playlists are only retrievable for the current user
     and requires the `playlistReadPrivate` scope to have been authorized
     by the user. Note that this scope alone will not return collaborative
     playlists, even though they are always private. Collaborative playlists
     are only retrievable for the current user and requires the
     `playlistReadCollaborative` scope to have been authorized by the user.
     See also [Working with Playlists][1].
     
     # Returns:
     ```
     PagingObject<Playlist<PlaylistsItemsReference>
     ```
     
     The simplified versions of the playlists will be returned.
     
     A `PlaylistsItemsReference` simply contains a link to all of the
     tracks/episodes and the total number in the playlist. To get all
     of the tracks and episodes in each playlist, you can use
     `playlistItems(_:limit:offset:market:)`, passing in the URI of
     each of the playlists. To get all of the URIs, use:
     ```
     let uris: [String] = playlists.items.map(\.uri)
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
    ) -> AnyPublisher<PagingObject<Playlist<PlaylistsItemsReference>>, Error> {
        
        do {
            
            let userId = try SpotifyIdentifier(
                uri: userURI, ensureCategoryMatches: [.user]
            ).id
        
            return self.getRequest(
                path: "/users/\(userId)/playlists",
                queryItems: [
                    "limit": limit,
                    "offset": offset
                ],
                requiredScopes: []
            )
            .decodeSpotifyObject(PagingObject<Playlist<PlaylistsItemsReference>>.self)
    
        } catch {
            return error.anyFailingPublisher()
        }
        
        
    }
    
}

public extension SpotifyAPI where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{
    // MARK: Playlists (Requires Authorization Scopes)
    
    /**
     Get a list of the current user's playlists, including those
     that they are following.
     
     See also `userPlaylists(for:limit:offset:)`.
     
     No scopes are required for retrieving the user's public playlists.
     However, the access token must have been issued on behalf of a
     user. Requires the `playlistReadPrivate` scope for retrieving private
     playlists. The `playlistReadCollaborative` scope is required to
     retrieve collarborative playlists, even though these are also
     always private. See also [Working with Playlists][1].

     # Returns:
     ```
     PagingObject<Playlist<PlaylistsItemsReference>>
     ```
     
     The simplified versions of the playlists will be returned.
     
     A `PlaylistsItemsReference` simply contains a link to all of the
     tracks/episodes and the total number in the playlist. To get all
     of the tracks and episodes in each playlist, you can use
     `playlistItems(_:limit:offset:market:)`, passing in the URI of
     each of the playlists. To get all of the URIs, use:
     ```
     let uris: [String] = playlists.items.map(\.uri)
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
    ) -> AnyPublisher<PagingObject<Playlist<PlaylistsItemsReference>>, Error> {
        
        return self.getRequest(
            path: "/me/playlists",
            queryItems: [
                "limit": limit,
                "offset": offset
            ],
            requiredScopes: []
        )
        .decodeSpotifyObject(PagingObject<Playlist<PlaylistsItemsReference>>.self)
        
    }
    
    /**
     Get the current images associated with a specific playlist.
     
     See also `playlist(_:market:)`.
     
     No scopes are required for this endpoint; the access token
     must have been issued on behalf of *a* user, but not necessarily
     the owner of this playlist.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter playlist: A Spotify playlist.
     - Returns: An array of image objects, which contain the URL for
           the image and its dimensions.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist-cover/
     */
    func playlistImage(
        _ playlist: SpotifyURIConvertible
    ) -> AnyPublisher<[SpotifyImage], Error> {
        
        do {
            
            let playlistId = try SpotifyIdentifier(
                uri: playlist, ensureCategoryMatches: [.playlist]
            ).id
            
            return self.getRequest(
                path: "/playlists/\(playlistId)/images",
                queryItems: [:],
                requiredScopes: []
            )
            .decodeSpotifyObject([SpotifyImage].self)
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /// This method has been renamed to `playlistImage(_:)`.
    @available(*, deprecated, renamed: "playlistImage(_:)")
    func getPlaylistImage(
        _ playlist: SpotifyURIConvertible
    ) -> AnyPublisher<[SpotifyImage], Error> {
        return self.playlistImage(playlist)
    }
    
    /// This method has been renamed to `playlistImage(_:)`.
    @available(*, deprecated, renamed: "playlistImage(_:)")
    func getPlaylistCoverImage(
        _ playlist: SpotifyURIConvertible
    ) -> AnyPublisher<[SpotifyImage], Error> {
        return self.playlistImage(playlist)
    }
    
    /**
     Add tracks/episodes to a playlist.
     
     Adding items to the current user’s public playlists requires
     authorization of the `playlistModifyPublic` scope; adding items
     to the current user’s private playlist (including collaborative
     playlists) requires the `playlistModifyPrivate` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - uris: An Array of URIs for tracks/episodes. A maximum of 100 items can
             be added in one request.
       - position: *Optional*. The position to insert the items.
             A zero-based index. If `nil`, the items will be
             appended to the playlist.
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
     Create a playlist for the **current** user.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - userURI: The URI of a user. **The access token must have been
           issued on behalf of this user.**
       - playlistDetails: The details of the playlist.
     - Returns: The playlist. It will be empty until you add tracks.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/create-playlist/
     */
    func createPlaylist(
        for userURI: SpotifyURIConvertible,
        _ playlistDetails: PlaylistDetails
    ) -> AnyPublisher<Playlist<PlaylistItems>, Error> {
        
        do {
            
            let userId = try SpotifyIdentifier(
                uri: userURI, ensureCategoryMatches: [.user]
            ).id
            
            return self.apiRequest(
                path: "/users/\(userId)/playlists",
                queryItems: [:],
                httpMethod: "POST",
                makeHeaders: Headers.bearerAuthorizationAndContentTypeJSON(_:),
                body: playlistDetails,
                requiredScopes: []
            )
            .decodeSpotifyObject(Playlist<PlaylistItems>.self)
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Reorders the tracks/episodes in a playlist.
     
     See also:
     
     * `removeSpecificOccurencesFromPlaylist(_:urisWithPostions:)`
     * `removeAllOccurencesFromPlaylist(_:uris:)`
     * `replaceAllPlaylistItems(_:with:)`

     Reordering items in the current user’s public playlists requires
     authorization of the `playlistModifyPublic` scope; reordering items
     in the current user’s private playlist (including collaborative playlists)
     requires the `playlistModifyPrivate` scope.
     
     The body of the request contains the following properties:
     
     * rangeStart: The position of the first item to be reordered.
     * rangeLength: The amount of items to be reordered. Defaults to 1.
       The range of items to be reordered begins from the `rangeStart` position
       (inclusive), and includes the `rangeLength` subsequent items.
       For example, if `rangeLength` is 1, then the item at index `rangeStart`
       will be inserted before the item at index `insertBefore`.
     * insertBefore: The position where the items should be inserted.
     * snapshotId: *Optional*. The version identifier for the current playlist.
     
     # Examples:
     
     To reorder the first item to the last position in a playlist with 10 items,
     set `rangeStart` to 0, set `rangeLength` to 1 (default) and
     `insertBefore` to 10.
     
     To reorder the last item in a playlist with 10 items to the start of
     the playlist, set `rangeStart` to 9, set `rangeLength` to 1 (default)
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
     
     Replace all the items in a playlist, overwriting its existing items.
     This powerful request can be useful for replacing items, re-ordering
     existing items, or clearing the playlist.
     
     See also:
     
     * `removeSpecificOccurencesFromPlaylist(_:urisWithPostions:)`
     * `removeAllOccurencesFromPlaylist(_:uris:)`
     * `reorderPlaylistItems(_:body:)`
     
     Setting items in the current user’s public playlists requires
     authorization of the `playlistModifyPublic` scope; setting items in
     the current user’s private playlist (including collaborative playlists)
     requires the `playlistModifyPrivate` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI of a playlist.
       - newItems: The new items to replace all of the current items with.
             A maximum of 100 items can be sent at once. **Pass in an empty**
             **array to remove all of the items from the playlist**.
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
            
            let playlistId = try SpotifyIdentifier(
                uri: playlist, ensureCategoryMatches: [.playlist]
            ).id
    
            return self.apiRequest(
                path: "/playlists/\(playlistId)",
                queryItems: [:],
                httpMethod: "PUT",
                makeHeaders: Headers.bearerAuthorizationAndContentTypeJSON(_:),
                body: newDetails,
                requiredScopes: []
            )
            .decodeSpotifyErrors()
            .map { _ in }
            .eraseToAnyPublisher()
        
        } catch {
            return error.anyFailingPublisher()
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
                    the size of the image that you are uploading (\(size)) \
                    is larger than Spotify's limit of 256 KB.
                    You may experience errors, such as those indicating \
                    connection to the network was lost.
                    --------------------------------------------------------
                    """
                )
                
            }
            
            let playlistId = try SpotifyIdentifier(
                uri: playlist, ensureCategoryMatches: [.playlist]
            ).id
            
            func makeHeaders(accessToken: String) -> [String: String] {
                return Headers.bearerAuthorization(accessToken) +
                    Headers.contentTypeImageJpeg
            }
            
            return self.apiRequest(
                path: "/playlists/\(playlistId)/images",
                queryItems: [:],
                httpMethod: "PUT",
                makeHeaders: makeHeaders(accessToken:),
                bodyData: imageData,
                requiredScopes: [.ugcImageUpload]
            )
            .decodeSpotifyErrors()
            .map { data, urlResponse in
            
                let statusCode = (urlResponse as! HTTPURLResponse).statusCode
                self.logger.trace(
                    "status code: \(statusCode)",
                    function: thisFunction
                )
            
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Removes **all** occurences of the specified tracks/episodes
     from a playlist.
     
     See also:
     
     * `removeSpecificOccurencesFromPlaylist(_:urisWithPostions:)`
     * `replaceAllPlaylistItems(_:with:)`
     * `reorderPlaylistItems(_:body:)`
     
     Removing items from a user’s public playlist requires authorization
     of the `playlistModifyPublic` scope; removing items from a
     private playlist requires the `playlistModifyPrivate` scope.
     
     Read more at the [Spotify web API reference][1].

     - Parameters:
       - playlist: The URI for a playlist.
       - uris: An Array of URIs for tracks/episodes. A maximum of 100 items can
             be removed at once.
       - snapshotId: The [snapshot id][2] of the playlist to target. If `nil`,
             the most recent version of the playist is targeted.
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
        of uris: [SpotifyURIConvertible],
        snapshotId: String? = nil
    ) -> AnyPublisher<String, Error> {
        
        return self.modifyPlaylist(
            playlist,
            httpMethod: "DELETE",
            queryItems: [:],
            body: URIsContainer(uris, snapshotId: snapshotId),
            // we can't know in advance which playlist
            // is being modified.
            requiredScopes: []
        )
            
    }
    
    /**
     Removes the specified tracks/episodes at the specified positions
     from a playlist. This is useful if the playlist contains duplicate
     items.
     
     See also:
     
     * `removeAllOccurencesFromPlaylist(_:uris:)`
     * `replaceAllPlaylistItems(_:with:)`
     * `reorderPlaylistItems(_:body:)`
     
     Removing items from a user’s public playlist requires authorization
     of the `playlistModifyPublic` scope; removing items from a
     private playlist requires the `playlistModifyPrivate` scope.
     
     **If a given item is not found at a given position,**
     **the entire request will fail and no edits will take place.**
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI for a playlist.
       - urisWithPostions: A collection of URIs along with their positions
         in a playlist and, optionally, the snapshot id of the playlist
         you want to target. A maximum of 100 items can be sent at once.
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
