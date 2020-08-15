import Foundation

/**
 Too Many Requests - [Rate limiting][1] has been applied.

 The `retryAfter` property specifies the number of seconds
 you must wait before you try the request again.

 Rate limiting is applied as per application based on Client ID,
 and regardless of the number of users who use the application
 simultaneously.

 To reduce the amount of requests, use endpoints that fetch
 multiple entities in one request. For example: If you often
 request single tracks, albums, or artists, use endpoints such as
 Get Several Tracks, Get Several Albums or Get Several Artists, instead.
 
 [1]: https://developer.spotify.com/documentation/web-api/#rate-limiting
 */
public struct RateLimitingError: LocalizedError, CustomCodable, Hashable {
    
    /// the number of seconds you must wait
    /// before you try the request again.
    public let retryAfter: Int?
    
    public var localizedDescription: String {
        let string = retryAfter.map(String.init) ?? "unknown"
        return "rate limiting error. Try again in \(string) seconds"
    }
    
}
