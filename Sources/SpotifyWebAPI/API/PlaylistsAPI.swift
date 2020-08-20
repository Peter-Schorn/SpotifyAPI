import Foundation
import Combine

// MARK: Methods for Accessing and Modifiying Playlists

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
                requiredScopes: requiredScopes,
                responseType: [String: String].self
            )
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

    
    
    /**
     Get all of the tracks in a playlist.
     Episodes in the playlist will not be returned.
     
     No scopes are required for this endpoint.
     
     Compared to the `Playlist` method, this method
     does not return any data about the playlist itself.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI for the playlist.
       - limit: *Optional*. The maximum number of items to return.
             Default: 100; minimum: 1; maximum: 100.
       - offset: *Optional*. The index of the first item to return.
             Default: 0 (the first object).
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][2]
            or the string from_token. Provide this parameter if you want
            to apply [Track Relinking][3].
     - Returns: An array of tracks wrapped inside a `PlaylistItem`
           wrapped insde a `PagingObject`.
     
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
                requiredScopes: [],
                responseType: PlaylistTracks.self
            )
        
        } catch {
            return error.anyFailingPublisher(PlaylistTracks.self)
        }
    }
    
 
    /**
     Add tracks/episodes to a playlist.
     
     Adding items to the current user’s public playlists requires
     authorization of the `playlistModifyPublic` scope; adding items
     to the current user’s private playlist (including collaborative
     playlists) requires the `playlistModifyPrivate` scope.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - playlist: The URI for a playlist.
       - uris: An Array of URIs for tracks/episodes.
             A maximum of 100 items can be added in one request.
       - position: *Optional*. The position to insert the items.
             A zero-based index. If `nil`, the items will be
             appended to the list.
     - Returns: The snapshot id of the playlist, which is an identifier for
           the current version of the playlist. Every time the playlist
           changes, a new snapshot id is generated. You can use this value
           to efficiently determine whether a playlist has changed since
           the last time you retrieved it. Can be supplied in other requests
           to target a specific playlist version:
           see [Remove tracks from a playlist][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/add-tracks-to-playlist/
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
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/playlists/remove-tracks-playlist/
     */
    func removeAllOccurencesFromPlaylist(
        _ playlist: SpotifyURIConvertible,
        uris: [SpotifyURIConvertible]
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
     
     - Parameters:
       - playlist: The URI for a playlist.
       - urisWithPostions: A collection of uris along with their positions
         in a playlist and, optionally, the snapshot id of the playlist
         you want to target.
     */
    func removeSpecificOccurencesFromPlaylist(
        _ playlist: SpotifyURIConvertible,
        urisWithPostions: URIsWithPositionsContainer
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
