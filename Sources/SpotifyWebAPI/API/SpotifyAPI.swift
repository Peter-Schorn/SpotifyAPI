import Foundation
import Logging
import Combine

/**
 The central class in this library. Provides methods for all of the Spotify
 web API endpoints and contains an authorization manager for managing the
 authorization process of your application.
 
 The methods that require authorization scopes and/or an access token that was
 issued on behalf of a user are declared in conditional conformances where
 `AuthorizationManager` conforms to `SpotifyScopeAuthorizationManager`.
 This protcol requires conforming types to support authorization scopes.
 This strategy provides a compile-time guarantee that you cannot call methods
 that require authorization scopes if you are using an authorization manager
 that doesn't support them.
 
 `AuthorizationCodeFlowManager` and `AuthorizationCodeFlowPKCEManager`
 conform to `SpotifyScopeAuthorizationManager`. `ClientCredentialsFlowManager`
 is not a conforming type because it does not support authorization scopes.
 
 All of the endpoints are documented at the the [web API reference][2].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
 [2]: https://developer.spotify.com/documentation/web-api/reference/
 */
public class SpotifyAPI<AuthorizationManager: SpotifyAuthorizationManager>: Codable {
    
    // MARK: - Authorization -

    /**
     Manages the authorization process for your application and contains all the
     authorization information.
     
     It is this property that you should encode to data using a `JSONEncoder`
     in order to save it to persistent storage. See this [article][1] for more
     information.
     
     [1]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
     */
    public var authorizationManager: AuthorizationManager {
        didSet {
            self.assertNotOnUpdateAuthInfoDispatchQueue()
            
            self.authDidChangeLogger.trace(
                "did set authorizationManager"
            )
            
            self.authManagerDidChangeCancellable =
                self.authorizationManager.didChange
                    .handleEvents(receiveOutput: { _ in
                        self.assertNotOnUpdateAuthInfoDispatchQueue()
                    })
                    .subscribe(authorizationManagerDidChange)
            
            self.authDidChangeLogger.trace(
                "authorizationManagerDidChange.send()"
            )
            self.authorizationManagerDidChange.send()
        }
    }

    /**
     A publisher that emits whenever `authorizationManager.didChange`
     emits, or when you assign a new instance of `AuthorizationManager`
     to `authorizationManager`.
     
     Emits after the following events occur:
     * After the access token (and possibly the refresh token as well) is
       refreshed. This occurs in
       `authorizationManager.refreshTokens(onlyIfExpired:tolerance:)`.
     * If the type of `authorizationManager` is `AuthorizationCodeFlowManager`:
         * After the access and refresh tokens are retrieved using
           `authorizationManager.requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`.
     * If the type of `authorizationManager` is `ClientCredentialsFlowManager`:
         * After the access token is retrieved using the `authorizationManager.authorize()`
           method.
     * After `authorizationManager.deauthorize()` is called.

     Subscribing to this publisher is preferred over subscribing to the
     `didChange` publisher of `authorizationManager` because it allows you
     to be notified of changes to the authorization manager even when you
     create a new instance of it and assign it to the `authorizationManager`
     property of this class.
     
     This publisher subscribes to the `didChange` publisher of
     `authorizationManager` in the `init(authorizationManager:)` method
     of this class and in the didSet block of `authorizationManager`.
     It also emits a signal in the didSet block of `authorizationManager`.
     
     # Thread Safety
     
     No guarantees are made about which thread this subject will emit on.
     Always receive on the main thread if you plan on updating the UI.
     */
    public let authorizationManagerDidChange = PassthroughSubject<Void, Never>()

    private var cancellables: Set<AnyCancellable> = []
    private var authManagerDidChangeCancellable: AnyCancellable? = nil
    
    // MARK: - Loggers -
    
    /// Logs general messages for this class.
    public lazy var logger = Logger(label: "SpotifyAPI", level: .critical)
    
    public lazy var authDidChangeLogger = Logger(
        label: "authDidChange", level: .critical
    )
    
    /// Logs the urls of the requests made to Spotify and,
    /// if present, the body of the requests by converting the raw
    /// data to a string.
    public lazy var apiRequestLogger = Logger(label: "APIRequest", level: .critical)
    
    // MARK: - Initializers -

    /**
     Creates an instance of `SpotifyAPI`, which contains
     all the methods for making requests to the Spotify web API.
     
     To get a client id and client secret, go to the
     [Spotify Developer Dashboard][1] and create an app.
     see the README in the root directory of this package for more information.
     
     - Parameter authorizationManager: An instance of a type that
           conforms to `SpotifyAuthorizationManager`. It Manages the authorization
           process for your application and contains all the authorization
           information. It is this property that you should encode to data using a
           `JSONEncoder` in order to save it to persistent storage. See this
           [article][2] for more information.
     
     [1]: https://developer.spotify.com/dashboard/login
     [2]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
     */
    public init(authorizationManager: AuthorizationManager)  {
        self.authorizationManager = authorizationManager
        
        self.authManagerDidChangeCancellable =
            self.authorizationManager.didChange
                .handleEvents(receiveOutput: { _ in
                    self.assertNotOnUpdateAuthInfoDispatchQueue()
                })
                .subscribe(authorizationManagerDidChange)
        
        SpotifyAPILogHandler.bootstrap()
    }
    
    deinit {
        self.logger.notice("\n--- \(self): DEINIT ---\n")
    }
    
    // MARK: - Codable -
    
    /**
     Creates a new instance by decoding from the given decoder.
     
     `authorizationManager` is the **only** property that is decoded.
     
     This initializer throws an error if reading from the decoder fails, or
     if the data read is corrupted or otherwise invalid.
     
     - Parameter decoder: The decoder to read data from.
     */
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.authorizationManager = try container.decode(
            AuthorizationManager.self,
            forKey: .authorizationManager
        )
        SpotifyAPILogHandler.bootstrap()
    }
    
    /**
     Encodes this value into the given encoder.
     
     `authorizationManager` is the **only** property that is encoded.
     
     If the value fails to encode anything, `encoder` will encode an empty
     keyed container in its place.
     
     This function throws an error if any values are invalid for the given
     encoder's format.
     
     - Parameter encoder: The encoder to write data to.
     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(
            self.authorizationManager, forKey: .authorizationManager
        )
    }
  
    public enum CodingKeys: String, CodingKey {
        case authorizationManager
    }

}

// MARK: - Testing -

extension SpotifyAPI {
    
    /// This function has no stable API and may change arbitrarily.
    /// Only use it for testing purposes.
    public func setupDebugging() {

        self.logger.logLevel = .trace
        self.apiRequestLogger.logLevel = .trace
        self.authDidChangeLogger.logLevel = .trace
        
        AuthorizationCodeFlowManagerBase.baseLogger.logLevel = .trace
        AuthorizationCodeFlowManager.logger.logLevel = .trace
        AuthorizationCodeFlowPKCEManager.logger.logLevel = .trace
        ClientCredentialsFlowManager.logger.logLevel = .trace
        
        CurrentlyPlayingContext.logger.logLevel = .trace
        
        spotifyDecodeLogger.logLevel = .warning
        
        SpotifyAPILogHandler.allLoggersAssertOnCritical = true
        
        self.logger.trace("\(Self.self): did setup debugging")
        
    }
    
    func assertNotOnUpdateAuthInfoDispatchQueue() {
        if let authManager = self.authorizationManager as? AuthorizationCodeFlowManagerBase {
            authManager.assertNotOnUpdateAuthInfoDispatchQueue()
        }
        else if let authManager = self.authorizationManager as? ClientCredentialsFlowManager {
            authManager.assertNotOnUpdateAuthInfoDispatchQueue()
        }
    }
    
}

