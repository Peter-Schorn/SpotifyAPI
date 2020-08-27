import Foundation


/**
 The Spotify [authentication error object][1].

 Do not confuse this with `SpotifyAuthorizationError`.

 Whenever the application makes requests related to authentication
 or authorization to Web API, such as retrieving an access token or
 refreshing an access token, the error response follows RFC 6749
 on the OAuth 2.0 Authorization Framework.
 
 [1]: https://developer.spotify.com/documentation/web-api/#authentication-error-object
 */
public struct SpotifyAuthenticationError: LocalizedError, Hashable {
    
    public let error: String
    public let description: String

    public var errorDescription: String? {
        "\(error): \(description)"
    }
    
}

extension SpotifyAuthenticationError: Codable {
    
    enum CodingKeys: String, CodingKey {
        case error
        case description = "error_description"
    }
    
}
