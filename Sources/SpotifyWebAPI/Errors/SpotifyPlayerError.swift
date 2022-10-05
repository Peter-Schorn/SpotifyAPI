import Foundation

/**
 The Spotify player error object. This is returned when making requests
 related to the player endpoints.
 
 See also:
 
 * ``SpotifyError``
 * ``SpotifyAuthenticationError``
 * ``RateLimitedError``
 
 It is almost the same as ``SpotifyError``, except it also has a ``reason``
 property:
 
 * ``message``: A short description of the cause of the error.
 * ``reason``: A player error reason.
 * ``statusCode``: The [HTTP status code][1] that is also returned in the
   response header.
 
 [1]: https://developer.spotify.com/documentation/web-api/#response-status-codes
 */
public struct SpotifyPlayerError: LocalizedError, Hashable {
    
    /// A short description of the cause of the error.
    public let message: String

    /**
     A player error reason.
     
     * ``ErrorReason/noPreviousTrack``: The command requires a previous track,
       but there is none in   the context.
     * ``ErrorReason/noNextTrack``: The command requires a next track, but there
       is none in the   context.
     * ``ErrorReason/noSpecificTrack``: The requested track does not exist.
     * ``ErrorReason/alreadyPaused``: The command requires playback to not be
       paused.
     * ``ErrorReason/notPaused``: The command requires playback to be paused.
     * ``ErrorReason/notPlayingLocally``: The command requires playback on the
       local device.
     * ``ErrorReason/notPlayingTrack``: The command requires that a track is
       currently playing.
     * ``ErrorReason/notPlayingContext``: The command requires that a context is
       currently playing.
     * ``ErrorReason/endlessContext``: The shuffle command cannot be applied on
       an endless context.
     * ``ErrorReason/contextDisallow``: The command could not be performed on
       the context.
     * ``ErrorReason/alreadyPlaying``: The track should not be restarted if the
       same track and context is already playing, and there is a resume point.
     * ``ErrorReason/rateLimited``: The user is rate limited due to too frequent
       track play, also known as cat-on-the-keyboard spamming.
     * ``ErrorReason/remoteControlDisallow``: The context cannot be
       remote-controlled.
     * ``ErrorReason/deviceNotControllable``: Not possible to remote control the
       device.
     * ``ErrorReason/volumeControlDisallow``: Not possible to remote control the
       device’s volume.
     * ``ErrorReason/noActiveDevice``: Requires an active device and the user
       has none.
     * ``ErrorReason/premiumRequired``: The request is prohibited for
       non-premium users.
     * ``ErrorReason/unknown``: Certain actions are restricted because of
       unknown reasons. Unfortunately, there is a bug at the moment with the
       Spotify web API in which this error reason is returned for many requests
       instead of one of the more specific errors above.
     
     */
    public let reason: ErrorReason
    
    /**
     The HTTP status code that is also returned in the response header.
     
     The [status Codes][1]:
     
     * **400: Bad Request** - The request could not be understood by the server
     due to malformed syntax. The message body will contain more information
     * **401: Unauthorized** - The request requires user authentication or, if
     the request included authorization credentials, authorization has been
     refused for those credentials.
     * **403: Forbidden** - The server understood the request, but is refusing
     to fulfill it.
     * **404: Not Found** -  The requested resource could not be found. This
     error can be due to a temporary or permanent condition.
     * **500: Internal Server Error.** You should never receive this error
     because our clever coders catch them all.
     * **502: Bad Gateway** - The server was acting as a gateway or proxy and
     received an invalid response from the upstream server.
     * **503: Service Unavailable** - The server is currently unable to handle
     the request due to a temporary condition which will be alleviated after
     some delay. You can choose to resend the request again.
    
     [1]: https://developer.spotify.com/documentation/web-api/#response-status-codes
     */
    public let statusCode: Int
    
    public var errorDescription: String? {
        "\(message) (status code: \(statusCode))"
    }
    
    /// A player error reason.
    public enum ErrorReason: String, Codable, Hashable, CaseIterable {
        
        /// The command requires a previous track, but there is none in the
        /// context.
        case noPreviousTrack = "NO_PREV_TRACK"
        
        /// The command requires a next track, but there is none in the context.
        case noNextTrack = "NO_NEXT_TRACK"
        
        /// The requested track does not exist.
        case noSpecificTrack = "NO_SPECIFIC_TRACK"
        
        /// The command requires playback to not be paused.
        case alreadyPaused = "ALREADY_PAUSED"
        
        /// The command requires playback to be paused.
        case notPaused = "NOT_PAUSED"
        
        /// The command requires playback on the local device.
        case notPlayingLocally = "NOT_PLAYING_LOCALLY"
        
        /// The command requires that a track is currently playing.
        case notPlayingTrack = "NOT_PLAYING_TRACK"
        
        /// The command requires that a context is currently playing.
        case notPlayingContext = "NOT_PLAYING_CONTEXT"
        
        /// The shuffle command cannot be applied on an endless context.
        case endlessContext = "ENDLESS_CONTEXT"
        
        /// The command could not be performed on the context.
        case contextDisallow = "CONTEXT_DISALLOW"
        
        /// The track should not be restarted if the same track and context is
        /// already playing, and there is a resume point.
        case alreadyPlaying = "ALREADY_PLAYING"
        
        /// The user is rate limited due to too frequent track play, also known
        /// as cat-on-the-keyboard spamming.
        case rateLimited = "RATE_LIMITED"
        
        /// The context cannot be remote-controlled.
        case remoteControlDisallow = "REMOTE_CONTROL_DISALLOW"
        
        /// Not possible to remote control the device.
        case deviceNotControllable = "DEVICE_NOT_CONTROLLABLE"
        
        /// Not possible to remote control the device’s volume.
        case volumeControlDisallow = "VOLUME_CONTROL_DISALLOW"
        
        /// Requires an active device and the user has none.
        case noActiveDevice = "NO_ACTIVE_DEVICE"
        
        /// The request is prohibited for non-premium users.
        case premiumRequired = "PREMIUM_REQUIRED"
        
        /**
         Certain actions are restricted because of unknown reasons.
         
         Unfortunately, there is a bug at the moment with the Spotify API in
         which this error reason is returned for many requests instead of one of
         the more specific errors in this enum.
         */
        case unknown = "UNKNOWN"
        
    }
    
}

extension SpotifyPlayerError: Codable {

    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        let errorContainer = try container.nestedContainer(
            keyedBy: CodingKeys.Error.self, forKey: .error
        )
        self.reason = try errorContainer.decode(
            ErrorReason.self, forKey: .reason
        )
        self.message = try errorContainer.decode(
            String.self, forKey: .message
        )
        self.statusCode = try errorContainer.decode(
            Int.self, forKey: .statusCode
        )
        
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        var errorContainer = container.nestedContainer(
            keyedBy: CodingKeys.Error.self, forKey: .error
        )
            
        try errorContainer.encode(self.message, forKey: .message)
        try errorContainer.encode(self.reason, forKey: .reason)
        try errorContainer.encode(self.statusCode, forKey: .statusCode)
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case error
        enum Error: String, CodingKey {
            case statusCode = "status"
            case message
            case reason
        }
    }
    
}
