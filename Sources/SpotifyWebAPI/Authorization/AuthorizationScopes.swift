import Foundation
import Logging


/**
 The Spotify authorization scopes.
 
 Read more at the [Spotify API Reference][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
 */
public enum Scope: String, Codable, Hashable {
    
    // MARK: Images

    /**
     Write access to user-provided images.
     
     Required for the following endpoints:
     
     * ``SpotifyAPI/uploadPlaylistImage(_:imageData:)``
     */
    case ugcImageUpload = "ugc-image-upload"
    
    // MARK: Playback
   
    /**
     Read access to a user’s player state.
     
     Required for the following endpoints:
     
     * ``SpotifyAPI/availableDevices()``
     * ``SpotifyAPI/currentPlayback(market:)``
     * ``SpotifyAPI/queue()``
     */
    case userReadPlaybackState = "user-read-playback-state"
    
    /**
     Write access to a user’s playback state.
     
     Required for the following endpoints:
     
     - ``SpotifyAPI/addToQueue(_:deviceId:)``
     - ``SpotifyAPI/skipToNext(deviceId:)``
     - ``SpotifyAPI/skipToPrevious(deviceId:)``
     - ``SpotifyAPI/pausePlayback(deviceId:)``
     - ``SpotifyAPI/resumePlayback(deviceId:)``
     - ``SpotifyAPI/play(_:deviceId:)``
     - ``SpotifyAPI/seekToPosition(_:deviceId:)``
     - ``SpotifyAPI/setRepeatMode(to:deviceId:)``
     - ``SpotifyAPI/setVolume(to:deviceId:)``
     - ``SpotifyAPI/setShuffle(to:deviceId:)``
     - ``SpotifyAPI/transferPlayback(to:play:)``
     */
    case userModifyPlaybackState = "user-modify-playback-state"
    
    /// Read access to a user’s currently playing content.
    ///
    /// This scope is not required for any of the endpoints in this library.
    case userReadCurrentlyPlaying = "user-read-currently-playing"
    
    // MARK: Spotify Connect
    
    /**
     Control playback of a Spotify track.
    
     This scope is currently available to the [Web Playback SDK][1]. The user
     must have a Spotify Premium account.
     
     [1]: https://developer.spotify.com/documentation/web-playback-sdk/
     */
    case streaming
    
    /**
     Remote control playback of Spotify.
    
     This scope is currently available to the Spotify [iOS][1] and [Android][2]
     SDKs.
     
     [1]: https://developer.spotify.com/documentation/ios/
     [2]: https://developer.spotify.com/documentation/android/
     */
    case appRemoteControl = "app-remote-control"
    
    // MARK: Users
    
    /**
     Read access to a user’s email address.
     
     Required for the ``SpotifyAPI/currentUserProfile()`` endpoint in order to
     retrieve the ``SpotifyUser/email`` property of the returned
     ``SpotifyUser``.
     */
    case userReadEmail = "user-read-email"
    
    /**
     Read access to the user’s subscription details (type of user account).
     
     May be required for the following endpoints, depending on the parameters
     specified and data desired in the response:
     
     * ``SpotifyAPI/search(query:categories:market:limit:offset:includeExternal:)``
     * ``SpotifyAPI/currentUserProfile()``
     */
    case userReadPrivate = "user-read-private"
    
    // MARK: Playlists
    
    /**
     Include collaborative playlists when requesting a user's playlists.
     
     Required for the following endpoints when targeting a *collaborative*
     playlist:
     
     * ``SpotifyAPI/currentUserPlaylists(limit:offset:)``
     * ``SpotifyAPI/userPlaylists(for:limit:offset:)``
     */
    case playlistReadCollaborative = "playlist-read-collaborative"
    
    /**
     Write access to a user's public playlists.
     
     Required for the following endpoints when targeting a *public* playlist:
     
     * ``SpotifyAPI/followPlaylistForCurrentUser(_:publicly:)``
     * ``SpotifyAPI/unfollowPlaylistForCurrentUser(_:)``
     * ``SpotifyAPI/addToPlaylist(_:uris:position:)``
     * ``SpotifyAPI/changePlaylistDetails(_:to:)``
     * ``SpotifyAPI/createPlaylist(for:_:)``
     * ``SpotifyAPI/removeAllOccurrencesFromPlaylist(_:of:snapshotId:)``
     * ``SpotifyAPI/removeSpecificOccurrencesFromPlaylist(_:of:)``
     * ``SpotifyAPI/reorderPlaylistItems(_:body:)``
     * ``SpotifyAPI/replaceAllPlaylistItems(_:with:)``
     * ``SpotifyAPI/uploadPlaylistImage(_:imageData:)``
     */
    case playlistModifyPublic = "playlist-modify-public"

    /**
     Read access to a user's private playlists.
 
     Required for the following endpoints when targeting a *private* playlist:
     
     * ``SpotifyAPI/usersFollowPlaylist(_:userURIs:)``
     * ``SpotifyAPI/currentUserPlaylists(limit:offset:)``
     * ``SpotifyAPI/userPlaylists(for:limit:offset:)``
     */
    case playlistReadPrivate = "playlist-read-private"
    
    /**
     Write access to a user's private playlists.
     
     Required for the following endpoints when targeting a *private* playlist:
     
     * ``SpotifyAPI/followPlaylistForCurrentUser(_:publicly:)``
     * ``SpotifyAPI/unfollowPlaylistForCurrentUser(_:)``
     * ``SpotifyAPI/addToPlaylist(_:uris:position:)``
     * ``SpotifyAPI/changePlaylistDetails(_:to:)``
     * ``SpotifyAPI/createPlaylist(for:_:)``
     * ``SpotifyAPI/removeAllOccurrencesFromPlaylist(_:of:snapshotId:)``
     * ``SpotifyAPI/removeSpecificOccurrencesFromPlaylist(_:of:)``
     * ``SpotifyAPI/reorderPlaylistItems(_:body:)``
     * ``SpotifyAPI/replaceAllPlaylistItems(_:with:)``
     * ``SpotifyAPI/uploadPlaylistImage(_:imageData:)``
     */
    case playlistModifyPrivate = "playlist-modify-private"

    // MARK: Library
    
    /**
     Write/delete access to a user's "Your Music" library.
     
     Required for the following endpoints:
     
     * ``SpotifyAPI/saveAlbumsForCurrentUser(_:)``
     * ``SpotifyAPI/saveTracksForCurrentUser(_:)``
     * ``SpotifyAPI/saveEpisodesForCurrentUser(_:)``
     * ``SpotifyAPI/saveShowsForCurrentUser(_:)``
     * ``SpotifyAPI/removeSavedAlbumsForCurrentUser(_:)``
     * ``SpotifyAPI/removeSavedTracksForCurrentUser(_:)``
     * ``SpotifyAPI/removeSavedEpisodesForCurrentUser(_:)``
     * ``SpotifyAPI/removeSavedShowsForCurrentUser(_:market:)``
     */
    case userLibraryModify = "user-library-modify"
    
    /**
     Read access to a user's "Your Music" library.
     
     Required for the following endpoints:

     * ``SpotifyAPI/currentUserSavedAlbums(limit:offset:market:)``
     * ``SpotifyAPI/currentUserSavedTracks(limit:offset:market:)``
     * ``SpotifyAPI/currentUserSavedEpisodes(limit:offset:market:)``
     * ``SpotifyAPI/currentUserSavedShows(limit:offset:market:)``
     * ``SpotifyAPI/currentUserSavedAlbumsContains(_:)``
     * ``SpotifyAPI/currentUserSavedTracksContains(_:)``
     * ``SpotifyAPI/currentUserSavedEpisodesContains(_:)``
     * ``SpotifyAPI/currentUserSavedShowsContains(_:)``
     */
    case userLibraryRead = "user-library-read"
    
    // MARK: Listen History
    
    /**
     Read access to a user's top artists and tracks.
     
     Required for the following endpoints:
     
     * ``SpotifyAPI/currentUserTopArtists(_:offset:limit:)``
     * ``SpotifyAPI/currentUserTopTracks(_:offset:limit:)``
     */
    case userTopRead = "user-top-read"
    
    /**
     Read access to a user’s playback position in an episodes.
     
     Required in order to retrieve the ``ResumePoint`` from the episode and
     chapter objects returned by the following endpoints:
     
     * ``SpotifyAPI/episode(_:market:)``
     * ``SpotifyAPI/episodes(_:market:)``
     * ``SpotifyAPI/show(_:market:)``
     * ``SpotifyAPI/shows(_:market:)``
     * ``SpotifyAPI/showEpisodes(_:market:offset:limit:)``
     * ``SpotifyAPI/audiobook(_:market:)``
     * ``SpotifyAPI/audiobooks(_:market:)``
     * ``SpotifyAPI/chapter(_:market:)``
     * ``SpotifyAPI/chapters(_:market:)``
     */
    case userReadPlaybackPosition = "user-read-playback-position"
    
    /**
     Read access to a user’s recently played tracks.
     
     Required for the following endpoint:
     
     * ``SpotifyAPI/recentlyPlayed(_:limit:)``
     */
    case userReadRecentlyPlayed = "user-read-recently-played"
    
    // MARK: Follow
    
    /**
     Read access to the list of artists and other users that the user follows.
     
     Required for the following endpoints:
     
     * ``SpotifyAPI/currentUserFollowsArtists(_:)``
     * ``SpotifyAPI/currentUserFollowsUsers(_:)``
     * ``SpotifyAPI/currentUserFollowedArtists(after:limit:)``
     */
    case userFollowRead = "user-follow-read"
    
    /**
     Write/delete access to the list of artists and other users that the user
     follows.
     
     Required for the following endpoints:
     
     * ``SpotifyAPI/followArtistsForCurrentUser(_:)``
     * ``SpotifyAPI/unfollowArtistsForCurrentUser(_:)``
     * ``SpotifyAPI/followUsersForCurrentUser(_:)``
     * ``SpotifyAPI/unfollowUsersForCurrentUser(_:)``
     */
    case userFollowModify = "user-follow-modify"
    
}

extension Scope: CaseIterable {
    
    public typealias AllCases = Set<Scope>

    // The synthesized implementation of `allCases` is an array, but a set is
    // more useful.
    /// A `Set` of all the authorization scopes.
    public static let allCases: Set<Scope> = [
        .ugcImageUpload,
        .userReadPlaybackState,
        .userModifyPlaybackState,
        .userReadCurrentlyPlaying,
        .streaming,
        .appRemoteControl,
        .userReadEmail,
        .userReadPrivate,
        .playlistReadCollaborative,
        .playlistModifyPublic,
        .playlistReadPrivate,
        .playlistModifyPrivate,
        .userLibraryModify,
        .userLibraryRead,
        .userTopRead,
        .userReadPlaybackPosition,
        .userReadRecentlyPlayed,
        .userFollowRead,
        .userFollowModify
    ]
    
}

// MARK: - convenience methods -

public extension Scope {
    
    /**
     Creates a space-separated string of scopes, which can be used for the scope
     query parameter of a Spotify endpoint.
    
     This is the opposite of ``Scope/makeSet(_:)``, which makes `Set<Scope>` from
     a string of (usually space-separated) scopes.
    
     - Parameter scopes: A variadic array of Spotify authorization scopes.
           Duplicates will be ignored.
    
     See the [Spotify API Reference][1].
    
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     */
    static func makeString(_ scopes: Scope...) -> String {
        return makeString(Set(scopes))
    }
    
    /**
     Creates a space-separated string of scopes, which can be used for the scope
     query parameter of a Spotify endpoint.
    
     This is the opposite of ``Scope/makeSet(_:)``, which makes `Set<Scope>` from
     a string of (usually space-separated) scopes.
    
     - Parameter scopes: A set of Spotify authorization scopes.
    
     See the [Spotify API Reference][1].
    
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     */
    static func makeString(_ scopes: Set<Scope>) -> String {
        return scopes.map(\.rawValue).joined(separator: " ")
    }
    
    /**
     Creates an set of scopes from a string of Spotify scopes (usually
     space-separated).
    
     If any of the scopes in the string do not match the raw value of any of the
     cases, then they are ignored.
    
     This is the opposite of `Scope.makeString(_:)`, which creates a
     space-separated string of scopes from `Set<Scope>`.
    
     - Parameter string: A string containing Spotify authorization scopes.
    
     See the [Spotify API Reference][1].
    
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     */
    static func makeSet(_ string: String) -> Set<Scope> {
        
        let stringArray = try! string.regexSplit(
            #"[^\w-]+"#, ignoreIfEmpty: true
        )
        var scopes: Set<Scope> = []
        for string in stringArray {
            if let scope = Self(rawValue: string) {
                scopes.insert(scope)
            }
        }
        return scopes
    }
    
    /**
     Returns `true` if the specified scope string matches one of the known
     scopes of this enum. Else, `false`.
    
     - Parameter scope: A Spotify authorization scope string. The string must
           contain only a single scope.
     */
    static func contains(_ scope: String) -> Bool {
        return Self.allCases.map(\.rawValue).contains(scope.strip())
    }
    
}
