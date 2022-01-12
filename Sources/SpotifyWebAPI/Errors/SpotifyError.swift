import Foundation


/**
 The Regular Error Object returned by the Spotify web API.

 See also:
 
 * ``SpotifyPlayerError``
 * ``SpotifyAuthenticationError``
 * ``RateLimitedError``
 
 It has two properties:
 
 * ``message``: A short description of the cause of the error.
 * ``statusCode``: The HTTP status code that is also returned in the response
   header.
 
 The [status Codes][2]:
 
 * **400: Bad Request** - The request could not be understood by the server due
   to malformed syntax. The message body will contain more information
 * **401: Unauthorized** - The request requires user authentication or, if the
   request included authorization credentials, authorization has been refused
   for those credentials.
 * **403: Forbidden** - The server understood the request, but is refusing to
   fulfill it.
 * **404: Not Found** -  The requested resource could not be found. This error
   can be due to a temporary or permanent condition.
 * **500: Internal Server Error.** You should never receive this error because
   our clever coders catch them all.
 * **502: Bad Gateway** - The server was acting as a gateway or proxy and
   received an invalid response from the upstream server.
 * **503: Service Unavailable** - The server is currently unable to handle the
   request due to a temporary condition which will be alleviated after some
   delay. You can choose to resend the request again.
 
 Read more at the [Spotify web API reference][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/#regular-error-object
 [2]: https://developer.spotify.com/documentation/web-api/#response-status-codes
 */
public struct SpotifyError: LocalizedError, Hashable {
    
    /// A short description of the cause of the error.
    public let message: String
    
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
    
}

extension SpotifyError: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        let errorContainer = try container.nestedContainer(
            keyedBy: CodingKeys.Error.self, forKey: .error
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
        try errorContainer.encode(self.statusCode, forKey: .statusCode)
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case error
        enum Error: String, CodingKey {
            case message
            case statusCode = "status"
        }
    }
    
}
