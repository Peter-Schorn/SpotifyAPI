import Foundation
import Logger


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
    
    /// The path for requesting refresh and access tokens.
    /// ```
    /// "/api/token"
    /// ```
    static let getTokens = "/api/token"
    
    /// Used to retrieve refresh and access tokens
    /// and to refresh an access token.
    ///
    /// ```
    /// "https://accounts.spotify.com/api/token"
    /// ```
    static let getRefreshAndAccessTokensURL = URL(
        scheme: "https",
        host: Endpoints.accountsBase,
        path: Endpoints.getTokens
    )!
    
    
    /**
     Use this method to make all of the endpoints
     other than those for authorizing the apps and
     retrieving/refreshing the tokens.
     
     Makes an endpoint beginning with:
     ```
     "https://api.spotify.com/v1"
     ```
     Do not forget to add a leading `/` to the path component.
     
     - Parameters:
       - path: A path to append to the url.
       - queryItems: Query items to add to the url.
     - Returns: The endpoint with the provided path and
           query items appended to it.
     */
    static func apiEndpoint(
        _ path: String,
        queryItems: [String: String]
    ) -> URL {

        return URL(
            scheme: "https",
            host: apiBase,
            path: apiVersion1 + path,
            queryItems: queryItems
        )!
        
    }
    
    
}




