import Foundation
import Logger


/// The central class in this library.
/// It manages the authorization process and provides methods
/// for all of the endpoints.
public class SpotifyAPI {
    
    // MARK: - Public Variables -
    
    public let clientID: String
    public let clientSecret: String
    
    // MARK: - Authorization Info -

    /// Used to access `self.authInfo`
    /// in a thread-safe manner.
    private let mutateAuthInfoQueue = DispatchQueue(
        label: "Peter-Schorn.mutate-authentication-info"
    )
    
    /// Do not access directly ever.
    /// Use `self.withAuthInfo(_:)` or `self.getAuthInfo()`.
    private var _authInfo: AuthInfo? = nil
    
    /**
     Use this method to mutate the authorization info
     for your app in a thread-safe manner.

     The authorization info consists of the following properties:
     
     * The access token
     * the refresh token
     * the expiration date for the access token
     * the scopes that have been authorized for the access token
     
     It also contains a method `isExpired(tolerance:)` that
     determines whether the access token is expired.
     
     If you only need to get the authorization info,
     use `self.getAuthInfo()` instead.
     
     - Parameter body: A closure that accepts
           the auth info as an inout parameter and can
           safely mutate it.
     - Throws: only if `body` throws.
     */
    public func withAuthInfo(
        _ body: (inout AuthInfo?) throws -> Void
    ) rethrows {
        try mutateAuthInfoQueue.sync {
            try body(&self._authInfo)
            didMutateAuthInfo?(self._authInfo)
        }
    }
    
    /**
     Retrieves the authorization info in a thread-safe manner.
     
     The authorization info consists of the following properties:
     
     * The access token
     * the refresh token
     * the expiration date for the access token
     * the scopes that have been authorized for the access token
     
     It also contains a method `isExpired(tolerance:)` that
     determines whether the access token is expired.
     
     If you need to mutate the authorization info, use
     `self.withAuthInfo(_:)`.
     */
    public func getAuthInfo() -> AuthInfo? {
        mutateAuthInfoQueue.sync { self._authInfo }
    }
    
    /// Called when the authorization info is mutated.
    ///
    /// Use this method to be notified when the authorization
    /// info is mutated. Note that it may be nil.
    /// For example, you could save it to
    /// persistent storage.
    public var didMutateAuthInfo: ((AuthInfo?) -> Void)? = nil
    
    /// The State parameter for the "/authorize" endpoint.
    private var stateParameter: String? = nil
    
    // MARK: - Loggers -
    
    public var logger = Logger(label: "SpotifyAPI")
    public var authLogger = Logger(label: "SpotifyAPIAuth")
    
    private func setupLoggers() {
        logger.level = .trace
        authLogger.level = .trace
        AuthInfo.printDebugingOutput = true
        
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
