import Foundation


/**
 The Spotify [authentication error object][1].

 Do not confuse this with `SpotifyAuthorizationError`.
 
 Whenever the application makes requests related to authentication
 or authorization to Web API, such as retrieving an access token
 or refreshing an access token, the error response follows RFC 6749
 on the OAuth 2.0 Authorization Framework.

 [1]: https://developer.spotify.com/documentation/web-api/#authentication-error-object:~:text=Object-,Authentication%20Error%20Object,Whenever%20the%20application%20makes%20requests%20related%20to%20authentication%20or%20authorization%20to%20Web%20API%2C%20such%20as%20retrieving%20an%20access%20token%20or%20refreshing%20an%20access%20token%2C%20the%20error%20response%20follows%20RFC%206749%20on%20the%20OAuth%202.0%20Authorization%20Framework.
 */
public struct SpotifyAuthenticationError: CustomCodable, LocalizedError, Hashable {
    
    public let error: String
    public let description: String

    public var errorDescription: String? {
        "\(error): \(description)"
    }
    
    enum CodingKeys: String, CodingKey {
        case error
        case description = "error_description"
    }
    
}
