import Foundation
import Logger


/// The central class in this library.
/// It manages the authorization process and provides methods
/// for all of the endpoints.
public class SpotifyAPI {
    
    // MARK: - Public Variables -
    
    public let clientID: String
    public let clientSecret: String
    
    /// Used to access `self.authInfo`
    /// in a thread-safe manner.
    private let mutateAuthInfoQueue = DispatchQueue(
        label: "Peter-Schorn.mutate-authentication-info"
    )
    
    private var _authInfo: AuthInfo? = nil
    
    /**
     Use this method to access and/or mutate
     the authentication info for your app in a
     thread-safe manner.
     
     The 
     */
    public func mutateAuthInfo(
        _ work: (inout AuthInfo?) throws -> Void
    ) rethrows {
        try mutateAuthInfoQueue.sync {
            try work(&self._authInfo)
        }
    }
    
    // MARK: - Private Variables -
    
    /// The State parameter for the "/authorize" endpoint.
    private var stateParameter: String? = nil
    
    // MARK: - Loggers -
    
    public var logger = Logger(label: "SpotifyAPI")
    public var authLogger = Logger(label: "SpotifyAPIAuth")
    
    private func setupLoggers() {
        logger.level = .trace
        authLogger.level = .trace
        AuthInfo.printDebugOutput = true
        
        self.authInfo!.accessToken
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
