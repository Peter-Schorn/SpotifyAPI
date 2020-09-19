import Foundation
import Logger
import Combine

/**
 The central class in this library. Provides methods for all of the Spotify
 web API endpoints and contains an authorization manager for managing the
 authorization/authentication process of your application.
 
 The methods that require authorization scopes and/or an access token that was
 issued on behalf of a user are declared in conditional conformances where
 `AuthorizationManager` conforms to `SpotifyScopeAuthorizationManager`.
 This protcol requires conforming types to support authorization scopes.
 This strategy provides a compile-time guarantee that you cannot call methods
 that require authorization scopes if you are using an authorization manager
 that doesn't support them.
 
 Currently, only `AuthorizationCodeFlowManager` conforms to
 `SpotifyScopeAuthorizationManager` but a future version of this library will
 support the [Authorization Code Flow with Proof Key for Code Exchange][1],
 which will also conform to this protocol.
 
 `ClientCredentialsFlowManager` is not a conforming type because it
 does not support authorization scopes.
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
 */
public class SpotifyAPI<AuthorizationManager: SpotifyAuthorizationManager>: Codable {
    
    // MARK: - Authorization -
    
    /// Manages the authorization process for your application.
    public var authorizationManager: AuthorizationManager {
        didSet {
            self.authDidChangeLogger.trace(
                "did set authorizationManager"
            )
            
            self.authManagerDidChangeCancellable =
                    self.authorizationManager.didChange
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
    public let logger = Logger(label: "SpotifyAPI", level: .critical)
    
    public let authDidChangeLogger = Logger(
        label: "authDidChange", level: .critical
    )
    
    /// Logs the urls of the requests made to Spotify and,
    /// if present, the body of the requests by converting the raw
    /// data to a string.
    public let apiRequestLogger = Logger(label: "APIRequest", level: .critical)
    
    // MARK: - Initializers -

    /**
     Creates an instance of `SpotifyAPI`, which contains
     all the methods for making requests to the Spotify web API.
     
     To get your client id and secret,
     see the [guide for registering your app][1].
     
     - Parameter authorizationManager: An instance of a type that
           conforms to `SpotifyAuthorizationManager`.
     
     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/
     */
    public init(authorizationManager: AuthorizationManager)  {
        self.authorizationManager = authorizationManager
        
        self.authManagerDidChangeCancellable =
                self.authorizationManager.didChange
                    .subscribe(authorizationManagerDidChange)
        
    }
    
    deinit {
        self.logger.notice("\n\n\(self): DEINIT\n\n")
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
    func setupDebugging() {

        self.logger.level = .trace
        self.apiRequestLogger.level = .trace
        self.authDidChangeLogger.level = .trace
        
        AuthorizationCodeFlowManager.logger.level = .trace
        ClientCredentialsFlowManager.logger.level = .trace
        CurrentlyPlayingContext.logger.level = .trace
        
        for logger in Logger.allLoggers {
            logger.logMsgFormatter =
                    assertOnCriticalLogMessageFormatter
        }
        
    }
    
}


