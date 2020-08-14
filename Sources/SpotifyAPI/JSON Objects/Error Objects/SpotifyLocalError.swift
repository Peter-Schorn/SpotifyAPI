import Foundation


/// This struct encapsulates errors that are encountered
/// before any requests are made to the SpotifyAPI.
///
/// For example, if you try to access an endpoint that
/// your app has not been authorized for, this will be detected
/// before any network requests are made because
/// the required scopes for an endpoint are known ahead of time.
enum SpotifyLocalError: Error, LocalizedError {
    
    /// You tried to access an endpoint that requires authorization,
    /// but you have not authorized your app yet.
    ///
    /// See [makeAuthorizationURL(redirectURI:scopes:showDialog)][1]
    /// and [requestAccessAndRefreshTokens(redirectURIWithQuery:)][2]
    ///
    /// [1]: x-source-tag://makeAuthorizationURL
    /// [2]: x-source-tag://requestAccessAndRefreshTokens-redirectURIWithQuery
    case unauthorized(String)
    
    /// A Spotify identifier of a specific type could not be parsed.
    /// The message will contain more information.
    case identifierParsingError(String)

    /**
     You tried to access an endpoint that
     your app does not have the required scopes for.
     
     - requiredScopes: The scopes that are required for this endpoint.
     - authorizedScopes: The scopes that your app is authroized for.
     */
    case insufficientScope(
        requiredScopes: Set<Scope>, authorizedScopes: Set<Scope>
    )
    
    /// The data from the web api could not be decoded.
    ///
    /// This is almost always due to an error in this library.
    /// Report a bug if you get this error.
    case decodingError(
        rawData: Data?,
        reponseObject: Any.Type,
        statusCode: Int?
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
            case .decodingError(
                let rawData, let responseObject, let statusCode
            ):
                var dataString =
                    "the data could not be decoded into a string"
                if let data = rawData,
                        let string = String(data: data, encoding: .utf8) {
                    dataString = string
                }
                let statusCodeString = statusCode.map(String.init)
                        ?? "no status code"
                        
                return """
                    The data from the web api could not be \
                    decoded into "\(responseObject)".
                    http status code: \(statusCodeString). raw data:
                    
                    \(dataString)
                    """
            case .other(let message):
                return message
        }
    }
    
    
    // /// Use when decoding data from a url request fails.
    // init(
    //     rawData: String?,
    //     reponseObject: Any.Type,
    //     statusCode: Int?
    // ) {
    //     var errorDescription =
    //         "Could not decode the data returned by Spotify into '\(reponseObject)'."
    //     if let statusCode = statusCode {
    //         errorDescription += "\nHTTP status code: \(statusCode)\n"
    //     }
    //     if let rawData = rawData {
    //         errorDescription += "below is the raw data\n\n\(rawData)"
    //     }
    //
    //     self.errorDescription = errorDescription
    //     self.statusCode = statusCode
    // }
}
