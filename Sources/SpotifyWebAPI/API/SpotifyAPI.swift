import Foundation
import Logger
import Combine


/// The central class in this library.
/// It manages the authorization process and provides methods
/// for all of the endpoints.
public class SpotifyAPI: ObservableObject {
    
    // MARK: - Public Variables -
    
    /// The client id for your application
    public let clientID: String
    
    /// The client secret for your application
    public let clientSecret: String
    
    /**
     The authorization info required for the [Authorization Code Flow][1].
     Attach a subscriber to this `currentValueSubject` to be notified
     when this value changes. This will hapen every time the
     access token is refreshed and after you authorize your app
     for the first time or after you request access to additional
     scopes.
     
     Contains the following properties:
     
     * The access token
     * the refresh token
     * the expiration date for the access token
     * the scopes that have been authorized for the access token
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     */
    @Published public var authInfo: AuthInfo? = nil
    
    // MARK: - Loggers -
    
    public let spotifyAPI = Logger(label: "SpotifyAPI", level: .trace)
    public let authLogger = Logger(label: "SpotifyAuthAPI", level: .warning)
    
    private func setupDebugging() {
        
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
        self.setupDebugging()
    }
    
    
}
