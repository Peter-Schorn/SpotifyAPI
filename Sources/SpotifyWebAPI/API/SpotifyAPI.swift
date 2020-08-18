import Foundation
import Logger
import Combine


/// The central class in this library.
/// It manages the authorization process and provides methods
/// for all of the endpoints.
public class SpotifyAPI {
    
    // MARK: - Public Variables -
    
    public let clientID: String
    public let clientSecret: String
    public let authInfo = CurrentValueSubject<AuthInfo?, Never>(nil)
    
    // MARK: - Loggers -
    
    public let logger = Logger(label: "SpotifyAPI")
    public let authLogger = Logger(label: "SpotifyAuthAPI")
    
    private func setupLoggers() {
        self.logger.level = .trace
        self.authLogger.level = .trace
        AuthInfo.printDebugingOutput = true
        SpotifyDecodingError.dataDumpfolder = URL(fileURLWithPath:
            "/Users/pschorn/Desktop/"
        )
    }
    
    // MARK: - Initializers -
    
    /**
     Creates a Spotify API authentication manager.
     Automatically handles the process of authentication
     and refreshing your access token when needed.
     
     After you create an instance of this class.
     create the authorization URL using
     `self.makeAuthorizationURL(redirectURI:scopes:showDialog:)`.
     Open it (usually in a browser) so that the user can
     authenticate your app.
     
     To get your client id and secret,
     see the [guide for registering your app][1].
     
     - Parameters:
       - clientID: A Spotify Client ID.
       - clientSecret: A Spotify Client Secret.
     
     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/
     */
    public init(
        clientID: String,
        clientSecret: String
    ) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.setupLoggers()
    }
    
    
}
