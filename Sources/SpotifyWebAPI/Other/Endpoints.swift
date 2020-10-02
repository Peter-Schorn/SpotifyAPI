import Foundation
import Logging


/// A namespace of endpoints and endpoint components.
enum Endpoints {
    
    // MARK: - Base -
    
    /// The base URL for the Spotify accounts service.
    /// ```
    /// "accounts.spotify.com"
    /// ```
    static let accountsBase = "accounts.spotify.com"
    
    /// The base URL for the Spotify web API.
    /// ```
    /// "api.spotify.com"
    /// ```
    static let apiBase = "api.spotify.com"
    
    /// The api version 1.
    /// ```
    /// "/v1"
    /// ```
    static let apiVersion1 = "/v1"
    
    // MARK: - Authorization -
    
    /// The path for authorizing your app.
    /// ```
    /// "/authorize"
    /// ```
    static let authorize = "/authorize"
    
    /// The path for requesting tokens.
    ///
    /// See also `getTokens`.
    /// ```
    /// "/api/token"
    /// ```
    static let token = "/api/token"
    
    /// Used to retrieve refresh and access tokens and to
    /// refresh an access token for the Authorization Code Flow,
    /// and to request an access token for the Client Credentials Flow.
    ///
    /// ```
    /// "https://accounts.spotify.com/api/token"
    /// ```
    static let getTokens = URL(
        scheme: "https",
        host: Endpoints.accountsBase,
        path: Endpoints.token
    )!
    
    
    /**
     Use this method to make all of the endpoints
     other than those for authorizing the application and
     retrieving/refreshing the tokens.
     
     Makes an endpoint beginning with:
     ```
     "https://api.spotify.com/v1"
     ```
     Do not forget to add a leading `/` to the path component.
     
     - Parameters:
       - path: A path to append to the URL.
       - queryItems: Query items to add to the URL.
     - Returns: The endpoint with the provided path and
           query items appended to it.
     */
    static func apiEndpoint(
        _ path: String,
        queryItems: [String: LosslessStringConvertible?]
    ) -> URL {

        return URL(
            scheme: "https",
            host: apiBase,
            path: apiVersion1 + path,
            queryItems: removeIfNil(queryItems)
        )!
        
    }
    
    
}




