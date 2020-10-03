import Foundation

/**
 The client id and client secret.
 
 These values are retrieved from the file specified by the
 "spotify_credentials_path" environment variable. This file
 should contain JSON data that can be decoded into `Credentials`.
 
 For example:
 ```
 {
     "client_id": "abc",
     "client_secret": "def"
 }
 ```
 */
public let spotifyCredentials: Credentials = {
   
    guard let path = ProcessInfo.processInfo
            .environment["spotify_credentials_path"] else {
        fatalError(
            "Could not find 'spotify_credentials_path' in environment variables"
        )
    }
    let url = URL(fileURLWithPath: path)
    do {
        let data = try! Data(contentsOf: url)
        let credentials = try JSONDecoder()
                .decode(Credentials.self, from: data)
        return credentials
        
    } catch {
        fatalError("could not retrieve Spotify credentials:\n\(error)")
    }

}()

public let clientId = spotifyCredentials.clientId
public let clientSecret = spotifyCredentials.clientSecret

/// "http://localhost".
public let localHostURL = URL(string: "http://localhost")!


/// Contains the client id and client secret.
public struct Credentials: Codable {
    
    public let clientId: String
    public let clientSecret: String
    
    public enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
    }
    
}
