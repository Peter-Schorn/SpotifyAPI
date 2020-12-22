import Foundation

/**
 The client id and client secret.
 
 These values are retrieved from the file at the path specified by the
 "spotify_credentials_path" environment variable. This file
 should contain JSON data that can be decoded into `SpotifyCredentials`.
 
 For example:
 ```
 {
     "client_id": "abc",
     "client_secret": "def"
 }
 ```
 */
public let spotifyCredentials: SpotifyCredentials = {
   
    guard let path = ProcessInfo.processInfo
            .environment["spotify_credentials_path"] else {
        fatalError(
            "Could not find 'spotify_credentials_path' in environment variables"
        )
    }
    let url = URL(fileURLWithPath: path)
    do {
        let data = try Data(contentsOf: url)
        let credentials = try JSONDecoder()
                .decode(SpotifyCredentials.self, from: data)
        return credentials
        
    } catch {
        fatalError(
            """
            could not retrieve Spotify credentials from '\(path)':
            \(error)
            """
        )
    }
    
    
}()

/// ```
/// "http://localhost"
/// ```
public let localHostURL = URL(string: "http://localhost")!

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
    
    public enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
    }
    
}
