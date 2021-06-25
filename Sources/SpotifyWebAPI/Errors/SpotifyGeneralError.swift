import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 An error originating from this library that is not represented by any of the
 other error types.
 
 See also:
 
 * ``SpotifyAuthorizationError``
 * ``SpotifyAuthenticationError``
 * ``SpotifyError``
 * ``SpotifyPlayerError``
 * ``RateLimitedError``
 */
public enum SpotifyGeneralError {
    
    /**
     You have tried to access an endpoint before authorizing your app or the
     access token needed to be refreshed but the refresh token was `nil`.
     
     See also ``insufficientScope(requiredScopes:authorizedScopes:)``.
     */
    case unauthorized(String)
    
    /**
     The value provided for the state parameter when you requested access and
     refresh tokens didn't match the value returned from Spotify in the query
     string of the redirect URI.
     
     - supplied: The value supplied when requesting the access and refresh
           tokens.
     - received: The value received from Spotify in the query string of the
           redirect URI.
     */
    case invalidState(supplied: String?, received: String?)
    
    
    /// A [Spotify identifier][1] (URI, id, URL) of a specific type
    /// could not be parsed. The message will contain more information.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    case identifierParsingError(message: String)

    /**
     You tried to access an endpoint that your app does not have the required
     scopes for.
    
     - requiredScopes: The scopes that are required for this endpoint.
     - authorizedScopes: The scopes that your app is authorized for.
     */
    case insufficientScope(
        requiredScopes: Set<Scope>, authorizedScopes: Set<Scope>
    )
    
    /**
     The id category or categories didn't match one of the expected categories.
    
      - expected: The expected categories. Some endpoints allow for URIS from
            multiple categories. For example, the endpoint for adding items to a
            playlist allows for track or episode URIs.
      - received: The id category that was received. In some cases, multiple
            categories will be returned. It is not necessarily the case that all
            of these categories are invalid. For example, if you provide a
            collection of artist, track, and episode URIS to the endpoint for
            adding items to a playlist, then `expected` will be `[track,
            episode]` and `received` will be `[track, episode, artist]`,
            representing all of the provided categories, not just the invalid
            ones.
     
     For example, if you pass a track URI to the endpoint for retrieving an
     artist, you will get this error.
     
     See also ``IDCategory``.
     */
    case invalidIdCategory(
        expected: [IDCategory], received: [IDCategory]
    )
    
    /**
     Spotify sometimes returns data wrapped in an extraneous top-level
     dictionary that the client doesn't need to care about. This error is thrown
     if the expected top level key associated with the data is not found.

     For example, adding a tracks to a playlist returns the following response:
     ```
     { "snapshot_id" : "3245kj..." }
     ```
     The value of the snapshot id is returned instead of the entire dictionary
     or this error is thrown if the key can't be found.
     */
    case topLevelKeyNotFound(
        key: String, dict: [AnyHashable: Any]
    )
    
    /**
     The http request returned a response with a status code in the 4xx (client
     error) or 5xx (server error) range, and the response body could not be
     decoded into any of the other errors types (``SpotifyAuthenticationError``,
     ``SpotifyError``, ``SpotifyPlayerError``).
     
     Contains the body data and http response metadata from the server.
     */
    case httpError(Data, HTTPURLResponse)

    /// Some other error.
    case other(
        String,
        localizedDescription: String = "An unexpected error occurred."
    )
    
}

extension SpotifyGeneralError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
             case .unauthorized(_):
                return """
                    Authorization has not been granted for this request.
                    """
            case .invalidState(_, _):
                return """
                    The authorization request has expired or is otherwise \
                    invalid.
                    """
            case .identifierParsingError(_):
                return "An internal error occurred."
            case .insufficientScope(_, _):
                return """
                    The permissions required for this request have not been \
                    granted
                    """
            case .invalidIdCategory(_, _):
                return "An internal error occurred"
            case .topLevelKeyNotFound(_, _):
                return "The format of the data from Spotify was invalid."
            case .httpError(_, let response):
                return HTTPURLResponse.localizedString(
                    forStatusCode: response.statusCode
                )
            case .other(_, let localizedDescription):
                return localizedDescription
        }
    }
    
}

extension SpotifyGeneralError: CustomStringConvertible {
    
    public var description: String {
        switch self {
             case .unauthorized(let message):
                return """
                    \(Self.self).unauthorized("\(message)")
                    """
            case .invalidState(let supplied, let received):
                return """
                    \(Self.self).invalidState(supplied: \(supplied as Any), \
                    received: \(received as Any))
                    """
            case .identifierParsingError(let message):
                return """
                    \(Self.self).identifierParsingError:("\(message)")
                    """
            case .insufficientScope(let required, let authorized):
                return """
                    \(Self.self).insufficientScope(required: \
                    \(required.map(\.rawValue)), authorized: \
                    \(authorized.map(\.rawValue)))
                    """
            case .invalidIdCategory(let expected, let received):
                return """
                    \(Self.self).invalidIdCategory(expected: \
                    \(expected.map(\.rawValue)), received: \
                    \(received.map(\.rawValue)))
                    """
            case .topLevelKeyNotFound(let key, let dict):
                // Prevent the description of `dict` from containing
                // `AnyHashable("value")` for each key by transforming the top
                // level keys to `String`. Instead, it will just be `"value"`.
                let topLevelStringDict: [String: Any] = dict.reduce(
                    into: [:]
                ) { dict, item in
                    let keyString = String(describing: item.key)
                    dict[keyString] = item.value
                }
                return """
                    \(Self.self).topLevelKeyNotFound(key: "\(key)", \
                    dict: \(topLevelStringDict))
                    """
            case .httpError(let data, let response):
                let dataString = String(data: data, encoding: .utf8)
                    .map({ #""\#($0)""# }) ?? "\(data)"
                return """
                    \(Self.self).httpError(HTTPURLResponse: \(response), \
                    Data: \(dataString))
                    """
            case .other(let message, let localizedDescription):
                return """
                    \(Self.self).other("\(message)", localizedDescription: \
                    "\(localizedDescription)")
                    """
        }
    }
  
}
