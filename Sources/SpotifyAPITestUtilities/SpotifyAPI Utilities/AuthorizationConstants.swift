import Foundation

/**
 The client id and client secret.
 
 These values are retrieved from one of the following locations, in the order
 listed:
 
 * They can be directly injected into the source code by running the script
   "set_credentials.sh"; they can be removed by running "rm_credentials.sh".
   These scripts will use the "SPOTIFY_SWIFT_TESTING_CLIENT_ID" and
   "SPOTIFY_SWIFT_TESTING_CLIENT_SECRET" environment variables. These scripts
   must be run with the root directory of this package as the working directory.

 * The file at the path specified by the "SPOTIFY_CREDENTIALS_PATH" environment
   variable. This file should contain JSON data that can be decoded into
   `SpotifyCredentials`. For example:
 ```
 {
     "client_id": "abc",
     "client_secret": "def"
 }
 
 ```
 
 * The "SPOTIFY_SWIFT_TESTING_CLIENT_ID" and
   "SPOTIFY_SWIFT_TESTING_CLIENT_SECRET" environment variables.
 
 If none of these values are populated, then a fatal error is thrown.
 */
public let spotifyCredentials: SpotifyCredentials = {
   
    // these properties can be populated by the "set_credentials" script
    // using the indicated environment variables:
    
    // SPOTIFY_SWIFT_TESTING_CLIENT_ID
    let __clientId__ = ""
    // SPOTIFY_SWIFT_TESTING_CLIENT_SECRET
    let __clientSecret__ = ""
    
    if !__clientId__.isEmpty && !__clientSecret__.isEmpty {
        return SpotifyCredentials(
            clientId: __clientId__,
            clientSecret: __clientSecret__
        )
    }
    
    let environment = ProcessInfo.processInfo.environment

    if let path = environment["SPOTIFY_CREDENTIALS_PATH"] ??
            environment["spotify_credentials_path"] {
        
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let credentials = try JSONDecoder().decode(
                SpotifyCredentials.self,
                from: data
            )
            return credentials
            
        } catch {
            fatalError(
                """
                could not retrieve Spotify credentials from '\(path)':
                \(error)
                """
            )
        }
        
    }
    else if let clientId = environment["SPOTIFY_SWIFT_TESTING_CLIENT_ID"],
            let clientSecret = environment["SPOTIFY_SWIFT_TESTING_CLIENT_SECRET"] {
        
        return SpotifyCredentials(
            clientId: clientId,
            clientSecret: clientSecret
        )

    }
    else {
        fatalError(
            """
            Could not find 'SPOTIFY_CREDENTIALS_PATH' or \
            'SPOTIFY_SWIFT_TESTING_CLIENT_ID' and/or \
            'SPOTIFY_SWIFT_TESTING_CLIENT_SECRET' \
            in the environment variables
            """
        )
        
    }
    
    
}()

/// ```
/// "http://localhost:8080"
/// ```
public let localHostURL = URL(string: "http://localhost:8080")!

/// The "sp_dc" cookie value, which is used by ``HeadlessBrowserAuthorizer`` to
/// authorize the application. Retrieved from the "SPOTIFY_DC" environment
/// variable.
public let spotifyDCCookieValue = ProcessInfo.processInfo
        .environment["SPOTIFY_DC"]

private func retrieveURLFromEnvironment(
    for name: String
) -> URL {
    
    guard let urlString = ProcessInfo.processInfo.environment[name] else {
        fatalError("could not find '\(name)' in the environment variables")
    }
    
    guard let url = URL(string: urlString) else {
        fatalError("could not convert to URL: '\(urlString)'")
    }
    
    return url

}

/// The URL for retrieving tokens using the authorization code flow. Retrieved
/// from the "SPOTIFY_AUTHORIZATION_CODE_FLOW_TOKENS_URL" environment variable.
public let authorizationCodeFlowTokensURL = retrieveURLFromEnvironment(
    for: "SPOTIFY_AUTHORIZATION_CODE_FLOW_TOKENS_URL"
)

/// The URL for refreshing the access token using the authorization code flow.
/// Retrieved from the "SPOTIFY_AUTHORIZATION_CODE_FLOW_REFRESH_TOKENS_URL"
/// environment variable.
public let authorizationCodeFlowRefreshTokensURL = retrieveURLFromEnvironment(
    for: "SPOTIFY_AUTHORIZATION_CODE_FLOW_REFRESH_TOKENS_URL"
)

/// The URL for retrieving tokens using the authorization code flow with proof
/// key for code exchange. Retrieved from the
/// "SPOTIFY_AUTHORIZATION_CODE_FLOW_PKCE_TOKENS_URL" environment variable.
public let authorizationCodeFlowPKCETokensURL = retrieveURLFromEnvironment(
    for: "SPOTIFY_AUTHORIZATION_CODE_FLOW_PKCE_TOKENS_URL"
)

/// The URL for refreshing the access token using the authorization code flow
/// with proof key for code exchange. Retrieved from the
/// "SPOTIFY_AUTHORIZATION_CODE_FLOW_PKCE_REFRESH_TOKENS_URL" environment
/// variable.
public let authorizationCodeFlowPKCERefreshTokensURL = retrieveURLFromEnvironment(
    for: "SPOTIFY_AUTHORIZATION_CODE_FLOW_PKCE_REFRESH_TOKENS_URL"
)

/// The URL for retrieving tokens using the client credentials flow. Retrieved
/// from the "SPOTIFY_CLIENT_CREDENTIALS_FLOW_TOKENS_URL" environment variable.
public let clientCredentialsFlowTokensURL: URL = {
    
    // this can be populated by the "set_credentials" script using the
    // 'SPOTIFY_CLIENT_CREDENTIALS_FLOW_TOKENS_URL' environment variable.
    let __clientCredentialsFlowTokensURL__ = ""

    if !__clientCredentialsFlowTokensURL__.isEmpty {
        guard let url = URL(
            string: __clientCredentialsFlowTokensURL__
        ) else {
            fatalError(
                "could not convert to URL: " +
                "'\(__clientCredentialsFlowTokensURL__)'"
            )
        }
        return url
    }
    
    return retrieveURLFromEnvironment(
        for: "SPOTIFY_CLIENT_CREDENTIALS_FLOW_TOKENS_URL"
    )

}()

/**
 Contains the client id and client secret.
 
 Can be decoded from JSON data in the following format:
 
 ```
 {
     "client_id": "abc",
     "client_secret": "def"
 }
 ```
 */
public struct SpotifyCredentials: Codable {
    
    /// The client id for the application.
    public let clientId: String
    
    /// The client secret for the application.
    public let clientSecret: String
    
    private enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
    }
    
}
