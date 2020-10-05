import Foundation


/**
 The [Regular Error Object][1] returned by the Spotify web API.

 The [Response Status Codes][2]:
 
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
 
 [1]: https://developer.spotify.com/documentation/web-api/#regular-error-object
 [2]: https://developer.spotify.com/documentation/web-api/#response-status-codes
 */
public struct SpotifyError: LocalizedError, Hashable {
    
    /// A short description of the cause of the error.
    public let message: String
    
    /// The HTTP status code that is also returned in the response header.
    /// For further information, see [Response Status Codes][1].
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#response-status-codes
    public let statusCode: Int
    
    public var errorDescription: String? {
        "\(message) (status code: \(statusCode))"
    }
    
}


extension SpotifyError: Decodable {
    
    public init(from decoder: Decoder) throws {
        
        let topLevelContainer = try decoder.container(
            keyedBy: CodingKeys.self
        )

        let container = try topLevelContainer.nestedContainer(
            keyedBy: CodingKeys.self, forKey: .error
        )
        self.message = try container.decode(
            String.self, forKey: .message
        )
        self.statusCode = try container.decode(
            Int.self, forKey: .statusCode
        )
        
    }
    
    enum CodingKeys: String, CodingKey {
        case error
        case message
        case statusCode = "status"
    }
    
}
