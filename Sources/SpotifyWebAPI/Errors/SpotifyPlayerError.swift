import Foundation

/**
 The Spotify [player error object][1]. This is returned when making
 requests related to the player endpoints.
 
 See also:
 
 * `SpotifyError`
 * `SpotifyAuthenticationError`
 * `RateLimitedError`
 
 It is almost the same as `SpotifyError`, except it also has a `reason`
 property:
 
 * `message`: A short description of the cause of the error.
 * `reason`: One of the [player error reasons][2] presented below.
 * `statusCode`: The HTTP status code that is also returned in the response header.
 
 The player [error reasons][2]:
 
 * **NO_PREV_TRACK**: The command requires a previous track, but there is none in
   the context.
 * **NO_NEXT_TRACK**: The command requires a next track, but there is none in the
   context.
 * **NO_SPECIFIC_TRACK**: The requested track does not exist.
 * **ALREADY_PAUSED**: The command requires playback to not be paused.
 * **NOT_PAUSED**: The command requires playback to be paused.
 * **NOT_PLAYING_LOCALLY**: The command requires playback on the local device.
 * **NOT_PLAYING_TRACK**: The command requires that a track is currently playing.
 * **NOT_PLAYING_CONTEXT**: The command requires that a context is currently 
   playing.
 * **ENDLESS_CONTEXT**: The shuffle command cannot be applied on an endless
   context.
 * **CONTEXT_DISALLOW**: The command could not be performed on the context.
 * **ALREADY_PLAYING**: The track should not be restarted if the same track and
   context is already playing, and there is a resume point.
 * **RATE_LIMITED**: The user is rate limited due to too frequent track play,
   also known as cat-on-the-keyboard spamming.
 * **REMOTE_CONTROL_DISALLOW**: The context cannot be remote-controlled.
 * **DEVICE_NOT_CONTROLLABLE**: Not possible to remote control the device.
 * **VOLUME_CONTROL_DISALLOW**: Not possible to remote control the device’s
   volume.
 * **NO_ACTIVE_DEVICE**: Requires an active device and the user has none.
 * **PREMIUM_REQUIRED**: The request is prohibited for non-premium users.
 * **UNKNOWN**: Certain actions are restricted because of unknown reasons
   (a common reason for this error is passing in the id of a non-active device).
 
 The [status Codes][3]:
 
 * **400: Bad Request** - The request could not be understood by the server due to
   malformed syntax. The message body will contain more information
 * **401: Unauthorized** - The request requires user authentication or, if the
   request included authorization credentials, authorization has been refused for
   those credentials.
 * **403: Forbidden** - The server understood the request, but is refusing to
   fulfill it.
 * **404: Not Found** -  The requested resource could not be found. This error
   can be due to a temporary or permanent condition.
 * **500: Internal Server Error.** You should never receive this error because
   our clever coders catch them all.
 * **502: Bad Gateway** - The server was acting as a gateway or proxy and
   received an invalid response from the upstream server.
 * **503: Service Unavailable** - The server is currently unable to handle the
   request due to a temporary condition which will be alleviated after some delay.
   You can choose to resend the request again.
 
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#player-error-object
 [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#player-error-reasons
 [3]: https://developer.spotify.com/documentation/web-api/#response-status-codes
 */
public struct SpotifyPlayerError: LocalizedError, Hashable {
    
    /// A short description of the cause of the error.
    public let message: String

    /**
     A [player error reason][1].
     
     * **NO_PREV_TRACK**: The command requires a previous track, but there is none in
       the context.
     * **NO_NEXT_TRACK**: The command requires a next track, but there is none in the
       context.
     * **NO_SPECIFIC_TRACK**: The requested track does not exist.
     * **ALREADY_PAUSED**: The command requires playback to not be paused.
     * **NOT_PAUSED**: The command requires playback to be paused.
     * **NOT_PLAYING_LOCALLY**: The command requires playback on the local device.
     * **NOT_PLAYING_TRACK**: The command requires that a track is currently playing.
     * **NOT_PLAYING_CONTEXT**: The command requires that a context is currently
       playing.
     * **ENDLESS_CONTEXT**: The shuffle command cannot be applied on an endless
       context.
     * **CONTEXT_DISALLOW**: The command could not be performed on the context.
     * **ALREADY_PLAYING**: The track should not be restarted if the same track and
       context is already playing, and there is a resume point.
     * *
     ATE_LIMITED**: The user is rate limited due to too frequent track play,
       also known as cat-on-the-keyboard spamming.
     * **REMOTE_CONTROL_DISALLOW**: The context cannot be remote-controlled.
     * **DEVICE_NOT_CONTROLLABLE**: Not possible to remote control the device.
     * **VOLUME_CONTROL_DISALLOW**: Not possible to remote control the device’s
       volume.
     * **NO_ACTIVE_DEVICE**: Requires an active device and the user has none.
     * **PREMIUM_REQUIRED**: The request is prohibited for non-premium users.
     * **UNKNOWN**: Certain actions are restricted because of unknown reasons
       (a common reason for this error is passing in the id of a non-active device).
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#player-error-reasons
     */
    public let reason: String
    
    /**
     The HTTP status code that is also returned in the response header.
     
     The [Response Status Codes][1]:
     
     * **400: Bad Request** - The request could not be understood by the server due to
       malformed syntax. The message body will contain more information
     * **401: Unauthorized** - The request requires user authentication or, if the
       request included authorization credentials, authorization has been refused for
       those credentials.
     * **403: Forbidden** - The server understood the request, but is refusing to
       fulfill it.
     * **404: Not Found** -  The requested resource could not be found. This error
       can be due to a temporary or permanent condition.
     * **500: Internal Server Error.** You should never receive this error because
       our clever coders catch them all.
     * **502: Bad Gateway** - The server was acting as a gateway or proxy and
       received an invalid response from the upstream server.
     * **503: Service Unavailable** - The server is currently unable to handle the
       request due to a temporary condition which will be alleviated after some delay.
       You can choose to resend the request again.
    
     [1]: https://developer.spotify.com/documentation/web-api/#response-status-codes
     */
    public let statusCode: Int
    
    public var errorDescription: String? {
        "\(message) (status code: \(statusCode))"
    }
    
}

extension SpotifyPlayerError: Codable {

    public init(from decoder: Decoder) throws {
        
        let topLevelContainer = try decoder.container(
            keyedBy: TopLevelCodingKeys.self
        )

        let container = try topLevelContainer.nestedContainer(
            keyedBy: CodingKeys.self, forKey: .error
        )
        self.reason = try container.decode(
            String.self, forKey: .reason
        )
        self.message = try container.decode(
            String.self, forKey: .message
        )
        self.statusCode = try container.decode(
            Int.self, forKey: .statusCode
        )
        
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var topLevelContainer = encoder.container(
            keyedBy: TopLevelCodingKeys.self
        )
        var container = topLevelContainer.nestedContainer(
            keyedBy: CodingKeys.self, forKey: .error
        )
            
        try container.encode(self.message, forKey: .message)
        try container.encode(self.reason, forKey: .reason)
        try container.encode(self.statusCode, forKey: .statusCode)
        
    }
    
    enum TopLevelCodingKeys: String, CodingKey {
        case error
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case statusCode = "status"
        case reason
    }
    
}
