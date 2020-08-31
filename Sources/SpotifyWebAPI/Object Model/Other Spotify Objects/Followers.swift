import Foundation

/// A Spotify [followers object][1].
///
/// [1]: https://developer.spotify.com/documentation/web-api/reference/object-model/#followers-object
public struct Followers: Codable, Hashable {
    
    /**
     A link to the Spotify web API endpoint providing full details of
     the followers; `nil` if not available. **Please note that this will**
     always be set to nil**, as the Web API does not support it at the moment.
     
     Use `getHref(_:responseType:)`, passing in `Followers` as the
     response type to retrieve the results.
     */
    public let href: String?

    /// The total number of followers.
    public let total: Int

}
