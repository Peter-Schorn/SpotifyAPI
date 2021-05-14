import Foundation


/**
 The Spotify [authentication error object][1].

 Do not confuse this with `SpotifyAuthorizationError`.

 Used whenever there are errors related to authentication or authorization, such
 as retrieving an access token or refreshing an access token.

 The error response follows [RFC 6749][2] on the OAuth 2.0 Authorization
 Framework.
 
 See also:
 
 * `SpotifyError`
 * `SpotifyPlayerError`
 * `RateLimitedError`
 * `SpotifyGeneralError`
 
 [1]: https://developer.spotify.com/documentation/web-api/#authentication-error-object
 [2]: https://tools.ietf.org/html/rfc6749
 */
public struct SpotifyAuthenticationError: LocalizedError, Hashable {
    
    /**
     A high level description of the error as specified in [RFC 6749 Section
     5.2][1].
    
     [1]: https://tools.ietf.org/html/rfc6749#section-5.2
     */
    public let error: String
    
    /**
     A more detailed description of the error as specified in [RFC 6749 Section
     4.1.2.1][1].
     
     May be `nil` in rare cases.
     
     [1]: https://tools.ietf.org/html/rfc6749#section-4.1.2.1
     */
    public let errorDescription: String?

}

extension SpotifyAuthenticationError: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
    
}
