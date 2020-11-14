import Foundation


/**
 An error that is not directly produced by the Spotify web API.
 
 For example if you try to make an API request but have not
 authorized your application yet, you will get a `.unauthorized(String)`
 error, which is thrown before any network requests are even made.
 
 Use `localizedDescription` for an error message suitable for displaying
 to the end user. Use the string representation of this instance for a more
 detailed description suitable for debugging.
 */
public enum SpotifyLocalError {
    
    /**
     You have tried to access an endpoint before authorizing your app
     or the access token needed to be refreshed but the refresh token was `nil`.
     
     See also `insufficientScope(requiredScopes:authorizedScopes:)`.
     */
    case unauthorized(String)
    
    /**
     The value provided for the state parameter when you requested
     access and refresh tokens didn't match the value returned from spotify
     in the query string of the redirect URI.
     
     - supplied: The value supplied when requesting the access and refresh
       tokens.
     - received: The value received from Spotify in the query string of
       the redirect URI.
     */
    case invalidState(supplied: String?, received: String?)
    
    
    /// A [Spotify identifier][1] (URI, ID, URL) of a specific type
    /// could not be parsed. The message will contain more information.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    case identifierParsingError(message: String)

    /**
     You tried to access an endpoint that your app does not have the required
     scopes for.
    
     - requiredScopes: The scopes that are required for this endpoint.
     - authorizedScopes: The scopes that your app is authroized for.
     */
    case insufficientScope(
        requiredScopes: Set<Scope>, authorizedScopes: Set<Scope>
    )
    
    /**
     The id category or categories didn't match one of the expected categories.
    
      - expected: The expected categories. Some endpoints allow for
        URIS from multiple categories. For example, the endpoint for
        adding items to a playlist allows for track or episode URIs.
      - received: The id category that was received. In some cases, multiple
        categories will be returned.
    
     For example, if you pass a track URI to the endpoint for retrieving
     an artist, you will get this error.
     
     See also `IDCategory`.
     */
    case invalidIdCategory(
        expected: [IDCategory], received: [IDCategory]
    )
    
    /**
     Spotify sometimes returns data wrapped in an extraneous top-level
     dictionary that the client doesn't need to care about. This error
     is thrown if the expected top level key associated with the data
     is not found.
     
     For example, adding a tracks to a playlist returns the following
     response:
     ```
     { "snapshot_id" : "3245kj..." }
     ```
     The value of the snapshot id is returned instead of the entire
     dictionary or this error is thrown if the key can't be found.
     */
    case topLevelKeyNotFound(
        key: String, dict: [AnyHashable: Any]
    )
    
    /**
     Some other error.
     
     The first string will be used for `description`.
     `localizedDescription` will be used for `errorDescription`.
     */
    case other(
        String,
        localizedDescription: String = "An unexpected error occurred."
    )
    
}

extension SpotifyLocalError: LocalizedError {
    
    /// :nodoc:
    public var errorDescription: String? {
        switch self {
             case .unauthorized(_):
                return """
                    Authorization has not been granted for this \
                    operation.
                    """
            case .invalidState(_, _):
                return """
                    The authorization request has expired or is \
                    otherwise invalid.
                    """
            case .identifierParsingError(_):
                return "An internal error occurred."
            case .insufficientScope(_, _):
                return """
                    Authorization has not been granted for this \
                    operation.
                    """
            case .invalidIdCategory(_, _):
                return "An internal error occurred"
            case .topLevelKeyNotFound(_, _):
                return "The format of the data from Spotify was invalid."
            case .other(_, let localizedDescription):
                return localizedDescription
        }
    }
    
}

extension SpotifyLocalError: CustomStringConvertible {
    
    /// :nodoc:
    public var description: String {
        switch self {
             case .unauthorized(let message):
                return "SpotifyLocalError.unauthorized: \(message)"
            case .invalidState(let supplied, let received):
                return """
                    SpotifyLocalError.invalidState: The value for the state \
                    parameter provided when requesting access and refresh \
                    tokens '\(supplied ?? "nil")' did not match the value \
                    received from Spotify in the query string of the redirect URI: \
                    '\(received ?? "nil")'
                    """
            case .identifierParsingError(let message):
                return "SpotifyLocalError.identifierParsingError: \(message)"
            case .insufficientScope(let required, let authorized):
                return """
                    SpotifyLocalError.insufficientScope: The endpoint you \
                    tried to access requires the following scopes: \
                    \(required.map(\.rawValue)) \
                    but your app is only authorized for theses scopes: \
                    \(authorized.map(\.rawValue))
                    """
            case .invalidIdCategory(let expected, let received):
                return """
                    SpotifyLocalError.invalidIdCategory: expected id categories \
                    to match the following: \(expected.map(\.rawValue)), \
                    but received \(received.map(\.rawValue))
                    """
            case .topLevelKeyNotFound(let key, let dict):
                return """
                    SpotifyLocalError.topLevelKeyNotFound: The expected top \
                    level key '\(key)' was not found in the dictionary:
                    \(dict)
                    """
            case .other(let message, _):
                return "SpotifyLocalError.other: \(message)"
        }
    }
  
}


