import Foundation


/// This error is used if there was an error during
/// the process of requesting refresh and access tokens.
///
/// See the [authorization process][1].
///
/// [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#example-1:~:text=If%20the%20user%20does%20not%20accept,example%20https%3A%2F%2Fexample.com%2Fcallback%3Ferror%3Daccess_denied%26state%3DSTATE%2C%20contains%20the%20following%20parameters%3A
public struct SpotifyAuthorizationError: LocalizedError, CustomCodable, Hashable {
    
    /// The reason authorization failed, for example: "access_denied".
    public let error: String
    /// The value of the state parameter supplied in the request.
    public let state: String?
    
    public var errorDescription: String? { error }
    
}
