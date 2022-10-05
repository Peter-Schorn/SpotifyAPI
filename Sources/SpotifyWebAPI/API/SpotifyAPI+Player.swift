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
    // MARK: Player (Requires Authorization Scopes)
    
    /**
     Get the user's available devices.
     
     Note that an available device is not the same as an active device.
     
     This endpoint requires the ``Scope/userReadPlaybackState`` scope.

     You can use this endpoint to determine which devices are currently active
     by checking each device's ``Device/isActive`` property.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Returns: An array of device objects.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-a-users-available-devices
     */
    func availableDevices() -> AnyPublisher<[Device], Error> {
        
        return self.getRequest(
            path: "/me/player/devices",
            queryItems: [:],
            requiredScopes: [.userReadPlaybackState]
        )
        .decodeSpotifyObject([String: [Device]].self)
        .tryMap { dict -> [Device] in
            if let devices = dict["devices"] {
                return devices
            }
            throw SpotifyGeneralError.topLevelKeyNotFound(
                key: "devices", dict: dict
            )
        }
        .eraseToAnyPublisher()
        
    }
    
    /**
     Get information about the user's current playback, including the currently
     playing track or episode, progress, and active device.
     
     See also ``availableDevices()`` and ``recentlyPlayed(_:limit:)``.
     
     This endpoint requires the ``Scope/userReadPlaybackState`` scope.
     
     The notable details that are returned are:
     
     * The track or episode that is currently playing
     * The context, such as a playlist, that it is playing in
     * The progress into the currently playing track/episode
     * The current shuffle and repeat state
     
     The information returned is for the last known state, which means an
     inactive device could be returned if it was the last one to execute
     playback. When no available devices are found, `nil` is returned. Always
     use ``availableDevices()`` instead if you just need to get the available
     and active devices. Note that an available device is not the same as an
     active device.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter market: An [ISO 3166-1 alpha-2 country code][2] or the string
           "from_token". Provide this parameter if you want to apply [Track
           Relinking][3].

     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-information-about-the-users-current-playback
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    func currentPlayback(
        market: String? = nil
    ) -> AnyPublisher<CurrentlyPlayingContext?, Error> {
        
        return self.getRequest(
            path: "/me/player",
            queryItems: [
                "additional_types": "track,episode",
                "market": market
            ],
            requiredScopes: [.userReadPlaybackState]
        )
        .decodeOptionalSpotifyObject(CurrentlyPlayingContext.self)
        
    }
 
    /**
     Get the current user's recently played tracks.
     
     See also ``availableDevices()`` and ``currentPlayback(market:)``.
     
     This endpoint requires the ``Scope/userReadRecentlyPlayed`` scope.
     
     **Currently doesn’t support podcast episodes.**
     
     Returns the most recent 50 tracks played by a user. Note that a track
     currently playing will not be visible in play history until it has
     completed. **A track must be played for more than 30 seconds to be
     included** **in the play history.**

     Any tracks listened to while the user had “Private Session” enabled in
     their client will not be returned in the list of recently played tracks.

     This endpoint uses a bidirectional cursor for paging. Follow the next field
     with the before parameter to move back in time, or use the after parameter
     to move forward in time. If you supply no before or after parameter, the
     endpoint will return the most recently played tracks, and the next link
     will page back in time.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - timeReference: A reference to a period of time before or after a
             specified date. For example, `.before(Date())` refers to the period
             of time before the current date. This is used to filter the
             response. See the ``SpotifyCursor/before`` and
             ``SpotifyCursor/after`` properties of ``SpotifyCursor`` (which is
             part of the returned ``CursorPagingObject``). Dates will be
             converted to millisecond-precision timestamps. Only results that
             are within the specified time period will be returned. If `nil`,
             the most recently played tracks will be returned.
       - limit: The maximum number of items to return. Default: 20; Minimum: 1;
             Maximum: 50.
     - Returns: An array of simplified tracks wrapped in a
           ``CursorPagingObject``.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-recently-played
     */
    func recentlyPlayed(
        _ timeReference: TimeReference? = nil,
        limit: Int? = nil
    ) -> AnyPublisher<CursorPagingObject<PlayHistory>, Error> {
        
        var query: [String: LosslessStringConvertible?] =
                timeReference?.asQueryItem() ?? [:]
        
        query["limit"] = limit
        
        return self.getRequest(
            path: "/me/player/recently-played",
            queryItems: query,
            requiredScopes: [.userReadRecentlyPlayed]
        )
        .decodeSpotifyObject(CursorPagingObject<PlayHistory>.self)
        
    }
    
    /**
     Get the user's queue and the currently playing track/episode.
     
     This endpoint requires the ``Scope/userReadPlaybackState`` scope.
     
     See also ``addToQueue(_:deviceId:)``.
     
     Read more at the [Spotify web API reference][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-queue
     */
    func queue() -> AnyPublisher<SpotifyQueue, Error> {
        
        return self.getRequest(
            path: "/me/player/queue",
            queryItems: [:],
            requiredScopes: [.userReadPlaybackState]
        )
        .decodeSpotifyObject(SpotifyQueue.self)

    }
    
    /**
     Add a track or episode to the user's playback queue.
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     When performing an action that is restricted, a ``SpotifyPlayerError`` will
     be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A player error reason.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also ``queue()`` and <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uri: The URI for either a track or an episode.
       - deviceId: The id of the device to target. See ``availableDevices()``.
             It is highly recommended that you leave this as `nil` (default) to
             target the active device. If you provide the id of a device that is
             not active, you may get a 403 "Player command failed: Restriction
             violated" error. If you want to add to the queue for a non-active
             device, call ``transferPlayback(to:play:)`` first.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/add-to-queue
     */
    func addToQueue(
        _ uri: SpotifyURIConvertible,
        deviceId: String? = nil
    ) -> AnyPublisher<Void, Error> {
        
        return self.apiRequest(
            path: "/me/player/queue",
            queryItems: [
                "uri": uri.uri,
                "device_id": deviceId
            ],
            httpMethod: "POST",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()
        
    }
    
    /**
     Skip the user's playback to the next track/episode.
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     When performing an action that is restricted, a ``SpotifyPlayerError`` will
     be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A player error reason.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - deviceId: The id of the device to target. See ``availableDevices()``.
             It is highly recommended that you leave this as `nil` (default) to
             target the active device. If you provide the id of a device that is
             not active, you may get a 403 "Player command failed: Restriction
             violated" error. If you want to skip to the next item on a
             non-active device, call ``transferPlayback(to:play:)`` first.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/skip-users-playback-to-next-track
     */
    func skipToNext(
        deviceId: String? = nil
    ) -> AnyPublisher<Void, Error> {
        
        return self.apiRequest(
            path: "/me/player/next",
            queryItems: ["device_id": deviceId],
            httpMethod: "POST",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()
        
    }
    
    /**
     Skip the user's playback to the previous track/episode.
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     When performing an action that is restricted, a ``SpotifyPlayerError`` will
     be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A player error reason.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - deviceId: The id of the device to target. See ``availableDevices()``.
             It is highly recommended that you leave this as `nil` (default) to
             target the active device. If you provide the id of a device that is
             not active, you may get a 403 "Player command failed: Restriction
             violated" error. If you want to skip to the previous item on a
             non-active device, call ``transferPlayback(to:play:)`` first.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/skip-users-playback-to-previous-track
     */
    func skipToPrevious(
        deviceId: String? = nil
    ) -> AnyPublisher<Void, Error> {
        
        return self.apiRequest(
            path: "/me/player/previous",
            queryItems: ["device_id": deviceId],
            httpMethod: "POST",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()
    
        
    }
    
    /**
     Pause the user's current playback.
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     **If playback is already paused, then you will get a 403 "Player command**
     **failed: Restriction violated" error.**
     
     When performing an action that is restricted, a ``SpotifyPlayerError``
     will be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A [player error reason][1], modeled by
     ``SpotifyPlayerError/ErrorReason``.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - deviceId: The id of the device to target. See ``availableDevices()``.
               It is highly recommended that you leave this as `nil` (default)
               to target the active device. If you provide the id of a device
               that is not active, you may get a 403 "Player command failed:
               Restriction violated" error. If you want to pause playback on a
               non-active device, call ``transferPlayback(to:play:)`` first.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/pause-a-users-playback
     */
    func pausePlayback(
        deviceId: String? = nil
    ) -> AnyPublisher<Void, Error> {
        
        return self.apiRequest(
            path: "/me/player/pause",
            queryItems: ["device_id": deviceId],
            httpMethod: "PUT",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()
        
    }
    
    /**
     Resume the current user's current playback.
     
     See also:
     
     * ``play(_:deviceId:)`` - play specific content
     * ``transferPlayback(to:play:)`` - transfer playback to a different device
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     **If content is already playing, then you will get a 403 “Player command**
     **failed: Restriction violated” error.**
     
     When performing an action that is restricted, a ``SpotifyPlayerError`` will
     be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A player error reason.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter deviceId: The id of the device to target. See
           ``availableDevices()``. It is highly recommended that you leave this
           as `nil` (default) to target the active device. If you provide the id
           of a device that is not active, you may get a 403 "Player command
           failed: Restriction violated" error. If you want to resume playback
           on a non-active device, call ``transferPlayback(to:play:)`` first.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/start-a-users-playback
     */
    func resumePlayback(
        deviceId: String? = nil
    ) -> AnyPublisher<Void, Error> {
        
        return self.apiRequest(
            path: "/me/player/play",
            queryItems: ["device_id": deviceId],
            httpMethod: "PUT",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()

    }
    
    /**
     Play content for the current user.
     
     See also:
     
     * ``resumePlayback(deviceId:)`` - resume the user's current playback
     * ``transferPlayback(to:play:)`` - transfer the user's playback to a
       different device
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     The `playbackRequest` has the following parameters:
     
     * context: The context in which to play the content.
       One of the following:
     
       * `contextURI(SpotifyURIConvertible)`: A URI for the context in which to
         play the content. Must be in one of the following categories:
         * Album
         * Artist
         * Show
         * Playlist
     
       * `uris([SpotifyURIConvertible])`: An array of track/episode URIs.
     
     * offset: Indicates where in the context playback should start.
       One of the following:
     
       * `position(Int)`: The index of the item in the context at which to
         start playback. Cannot be used if the context is an artist.
       *  `uri(SpotifyURIConvertible)`: The URI of the item to start playback
          at.
     
     * positionMS: Indicates from what position to start playback in
       milliseconds. If `nil`, then the track/episode will start from the
       beginning. Passing in a position that is greater than the length of the
       track/episode will cause the player to start playing the next item.
     
     When performing an action that is restricted, a ``SpotifyPlayerError`` will
     be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A player error reason.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - deviceId: The id of the device to target. See ``availableDevices()``.
             **Unlike other player endpoints, you can provide the id of a**
             **non-active device, which will cause the given content to be**
             **played on that device**. Leave as `nil` to target the active
             device. If there are no active devices, then you must provide a
             device id, otherwise you will get a "Player command failed: No
             active device found" error.
       - playbackRequest: A request to play content for the user. See above.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/start-a-users-playback
     */
    func play(
        _ playbackRequest: PlaybackRequest,
        deviceId: String? = nil
    ) -> AnyPublisher<Void, Error> {
        
        return self.apiRequest(
            path: "/me/player/play",
            queryItems: ["device_id": deviceId],
            httpMethod: "PUT",
            makeHeaders: Headers.bearerAuthorizationAndContentTypeJSON(_:),
            body: playbackRequest,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()

    }
    
    /**
     Seek to position in the currently playing track/episode.
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     When performing an action that is restricted, a ``SpotifyPlayerError`` will
     be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A player error reason.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - positionMS: The position in milliseconds to seek to. Must be a positive
             number. Passing in a position that is greater than the length of
             the track will cause the player to start playing the next song.
       - deviceId: The id of the device to target. See ``availableDevices()``.
             It is highly recommended that you leave this as `nil` (default) to
             target the active device. If you provide the id of a device that is
             not active, you may get a 403 "Player command failed: Restriction
             violated" error. If you want to seek to a position on a non-active
             device, call ``transferPlayback(to:play:)`` first.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/seek-to-position-in-currently-playing-track
     */
    func seekToPosition(
        _ positionMS: Int,
        deviceId: String? = nil
    ) -> AnyPublisher<Void, Error> {
     
        return self.apiRequest(
            path: "/me/player/seek",
            queryItems: [
                "position_ms": positionMS,
                "device_id": deviceId
            ],
            httpMethod: "PUT",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()
        
        
    }
    
    /**
     Set the repeat mode for the user's playback.
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     When performing an action that is restricted, a ``SpotifyPlayerError`` will
     be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A player error reason.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - repeatMode: Either ``RepeatMode/track``, ``RepeatMode/context`` or
             ``RepeatMode/off``. ``RepeatMode/track`` will repeat the current
             track. ``RepeatMode/context`` will repeat the current context.
             ``RepeatMode/off`` will turn repeat off.
       - deviceId: The id of the device to target. See ``availableDevices()``.
             It is highly recommended that you leave this as `nil` (default) to
             target the active device. If you provide the id of a device that is
             not active, you may get a 403 "Player command failed: Restriction
             violated" error. If you want to set the repeat mode on a non-active
             device, call ``transferPlayback(to:play:)`` first.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/set-repeat-mode-on-users-playback
     */
    func setRepeatMode(
        to repeatMode: RepeatMode,
        deviceId: String? = nil
    ) -> AnyPublisher<Void, Error> {
     
        return self.apiRequest(
            path: "/me/player/repeat",
            queryItems: [
                "state": repeatMode.rawValue,
                "device_id": deviceId
            ],
            httpMethod: "PUT",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()
        
        
    }
    
    /**
     Set the volume for the user's playback.
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     **You can not set the volume for the Spotify iOS app.**
     
     When performing an action that is restricted, a ``SpotifyPlayerError`` will
     be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A player error reason.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - percent: The volume to set. Must be in the range 0...100.
       - deviceId: The id of the device to target. See ``availableDevices()``.
             It is highly recommended that you leave this as `nil` (default) to
             target the active device. If you provide the id of a device that is
             not active, you may get a 403 "Player command failed: Restriction
             violated" error. If you want to set the volume on a non-active
             device, call ``transferPlayback(to:play:)`` first.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/set-volume-for-users-playback
     */
    func setVolume(
        to percent: Int,
        deviceId: String? = nil
    ) -> AnyPublisher<Void, Error> {
        
        return self.apiRequest(
            path: "/me/player/volume",
            queryItems: [
                "volume_percent": percent,
                "device_id": deviceId
            ],
            httpMethod: "PUT",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()
        
    }
        
    /**
     Set the shuffle mode for the user's playback.
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     When performing an action that is restricted, a ``SpotifyPlayerError`` will
     be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A player error reason.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - mode: `true` to turn shuffle on; `false` to turn if off.
       - deviceId: The id of the device to target. See ``availableDevices()``.
             It is highly recommended that you leave this as `nil` (default) to
             target the active device. If you provide the id of a device that is
             not active, you may get a 403 "Player command failed: Restriction
             violated" error. If you want to set the shuffle mode on a
             non-active device, call ``transferPlayback(to:play:)`` first.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/toggle-shuffle-for-users-playback
     */
    func setShuffle(
        to mode: Bool,
        deviceId: String? = nil
    ) -> AnyPublisher<Void, Error> {
        
        return self.apiRequest(
            path: "/me/player/shuffle",
            queryItems: [
                "device_id": deviceId,
                "state": mode
            ],
            httpMethod: "PUT",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()

    }
    
    /**
     Transfer the user's playback to a different device.
     
     After you transfer playback to a different device, that device will be
     considered active.
     
     See also ``resumePlayback(deviceId:)`` and ``play(_:deviceId:)``.
     
     This endpoint requires the ``Scope/userModifyPlaybackState`` scope.
     
     When performing an action that is restricted, a ``SpotifyPlayerError`` will
     be returned. It contains the following properties:
     
     * ``SpotifyPlayerError/message``: A short description of the cause of the
       error.
     * ``SpotifyPlayerError/reason``: A player error reason.
     * ``SpotifyPlayerError/statusCode``: The HTTP status code that is also
       returned in the response header.
     
     See also <doc:Using-the-Player-Endpoints>.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - deviceId: The id of a device to transfer the playback to. Must be one
             of the devices returned by ``availableDevices()``.
       - play: If `true`, ensure playback happens on the new device. If `false`,
             keep the current playback state. Note that a value of `false` will
             **NOT** pause playback. To ensure that playback is paused on the
             new device you should call ``pausePlayback(deviceId:)`` (and wait
             for completion) *before* transferring playback to the new device.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/transfer-a-users-playback
     */
    func transferPlayback(
        to deviceId: String,
        play: Bool
    ) -> AnyPublisher<Void, Error> {
        
        let body = TransferPlaybackRequest(
            deviceIds: [deviceId], play: play
        )
        
        return self.apiRequest(
            path: "/me/player",
            queryItems: [:],
            httpMethod: "PUT",
            makeHeaders: Headers.bearerAuthorizationAndContentTypeJSON(_:),
            body: body,
            requiredScopes: [.userModifyPlaybackState]
        )
        .decodeSpotifyErrors()
        .map { _, _ in }
        .eraseToAnyPublisher()
        
    }
    
}
