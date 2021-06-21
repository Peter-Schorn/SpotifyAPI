import Foundation
import Logging


/// A namespace of endpoints and endpoint components.
public enum Endpoints {
    
    // MARK: - Base -
    
    /**
     The base URL for the Spotify accounts service.
     
     Used for authorizing your application, retrieving refresh and access
     tokens, and refreshing the access token.
    
     ```
     "accounts.spotify.com"
     ```
     */
    public static let accountsBase = "accounts.spotify.com"
    
    /**
     The base URL for the Spotify web API.
    
     This is used for all requests other than those for authorizing the
     application, retrieving tokens, and refreshing tokens.
    
     ```
     "api.spotify.com"
     ```
     */
    public static let apiBase = "api.spotify.com"
    
    /// The api version 1.
    /// ```
    /// "/v1"
    /// ```
    public static let apiVersion1 = "/v1"
    
    // MARK: - Authorization -
    
    /// The path for authorizing your app.
    /// ```
    /// "/authorize"
    /// ```
    public static let authorize = "/authorize"
    
    /**
     The path for requesting and refreshing tokens.
    
     See also ``getTokens``.
     ```
     "/api/token"
     ```
     */
    public static let token = "/api/token"
    
    /**
     The URL for retrieving refresh and access tokens, and refreshing the
     access token.
    
     ```
     "https://accounts.spotify.com/api/token"
     ```
     */
    public static let getTokens = URL(
        scheme: "https",
        host: Endpoints.accountsBase,
        path: Endpoints.token
    )!
    
    
    /**
     Use this method to make all of the endpoints other than those for
     authorizing the application and retrieving/refreshing the tokens.

     Makes an endpoint beginning with:
     ```
     "https://api.spotify.com/v1"
     ```
     Do not forget to add a leading "/" to the path component.
     
     - Parameters:
       - path: A path to append to the URL.
       - queryItems: Query items to add to the URL. Each value in the the
             dictionary that is NOT `nil` will be added to the query string.
     - Returns: The URL, created from the provided path and query items.
     */
    public static func apiEndpoint(
        _ path: String,
        queryItems: [String: LosslessStringConvertible?]
    ) -> URL {

        return URL(
            scheme: "https",
            host: apiBase,
            path: apiVersion1 + path,
            queryItems: urlQueryDictionary(queryItems)
        )!
        
    }
    
    
}
