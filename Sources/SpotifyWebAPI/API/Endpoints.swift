//
//  File.swift
//  
//
//  Created by Peter Schorn on 8/12/20.
//

import Foundation
import Logger


/// The components of the endpoints.
enum Endpoints {
    
    // MARK: - Base -
    
    /// The base URL for the Spotify accounts service.
    /// ```
    /// "accounts.spotify.com"
    /// ```
    static let accountsBase = "accounts.spotify.com"
    /// The base URL for the web API.
    /// ```
    /// "api.spotify.com"
    /// ```
    static let apiBase = "api.spotify.com"
    /// The api version.
    /// ```
    /// "/v1"
    /// ```
    static let apiVersion = "/v1"
    
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
    static let getRefreshAndAccessTokens = "/api/token"
    
    /// Use this method to make all of the endpoints
    /// other than the authorization endpoints.
    ///
    /// Makes an endpoint beginning with:
    /// ```
    /// "api.spotify.com/v1"
    /// ```
    ///
    /// Do not forget to add a leading `/` to the path component.
    ///
    /// - Parameters:
    ///   - path: A path to append to the url.
    ///   - queryItems: Query items to add to the url.
    ///
    /// - Returns: The endpoint with the provided path and
    ///       query items appended to it.
    static func apiEndpoint(
        _ path: String,
        queryItems: [String: String]? = nil
    ) -> URL {

        return URL(
            scheme: "https",
            host: apiBase,
            path: apiVersion + path,
            queryItems: queryItems
        )!
        
    }
    
    
}




