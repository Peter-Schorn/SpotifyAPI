import Foundation


/**
 The user denied your app's authorization request or there was an error during
 the process of authorizing your app.

 This error will only be thrown during the process of requesting access and
 refresh tokens using ``AuthorizationCodeFlowBackendManager`` or
 ``AuthorizationCodeFlowPKCEBackendManager``. More specifically, it is created
 from the "error" (and possibly the "state") parameter of the query string of
 the redirect URI. It is *not* decoded from the response body of a request. Read
 more at the [Spotify web API reference][1].

 Do not confuse this with ``SpotifyAuthenticationError``. See also:
 
 * ``SpotifyError``
 * ``SpotifyPlayerError``
 * ``RateLimitedError``
 * ``SpotifyGeneralError``
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-user-authorization
 */
public struct SpotifyAuthorizationError: LocalizedError, Codable, Hashable {
    
    /**
     The reason authorization failed; for example: "access_denied".
    
     Use the ``accessWasDenied`` boolean property to check if the user denied
     access to your application.
     */
    public let error: String
    
    /// The value of the state parameter supplied in the request.
    public let state: String?
    
    /// Returns `true` if ``error`` == "access_denied". Else, `false`. If
    /// `true`, then the user denied your app's authorization request.
    public var accessWasDenied: Bool {
        return error == "access_denied"
    }
    
    public var errorDescription: String? {
        return error
    }
    
}
