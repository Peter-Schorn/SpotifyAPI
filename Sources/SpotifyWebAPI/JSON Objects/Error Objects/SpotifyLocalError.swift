import Foundation


/**
 This struct encapsulates errors that are encountered
 before any requests are made to the Spotify web API.

 For example, if you try to access an endpoint that
 your app has not been authorized for, this will be detected
 before any network requests are made because
 the required scopes for an endpoint are known ahead of time.
 */
enum SpotifyLocalError: LocalizedError {
    
    /**
     You tried to access an endpoint that requires authorization,
     but you have not authorized your app yet.
     
     See [makeAuthorizationURL(redirectURI:scopes:showDialog)][1]
     and [requestAccessAndRefreshTokens(redirectURIWithQuery:)][2]
     
     [1]: x-source-tag://makeAuthorizationURL
     [2]: x-source-tag://requestAccessAndRefreshTokens-redirectURIWithQuery
     */
    case unauthorized(String)
    
    
    /// A [Spotify identifier][1] of a specific type could not be parsed.
    /// The message will contain more information.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
    case identifierParsingError(String)

    /// You tried to access an endpoint that
    /// your app does not have the required scopes for.
    ///
    /// - requiredScopes: The scopes that are required for this endpoint.
    /// - authorizedScopes: The scopes that your app is authroized for.
    case insufficientScope(
        requiredScopes: Set<Scope>, authorizedScopes: Set<Scope>
    )
    
    /// Some other error.
    case other(String)
    
    var localizedDescription: String {
        switch self {
             case .unauthorized(let message):
                return "unauthorized: \(message)"
            case .identifierParsingError(_):
                return "\(self)"
            case .insufficientScope(let required, let authorized):
                return """
                    The endpoint you tried to access requires the \
                    following scopes:
                    \(required)
                    but your app is only authorized for theses scopes:
                    \(authorized)
                    """
            case .other(let message):
                return message
        }
    }
  
}
