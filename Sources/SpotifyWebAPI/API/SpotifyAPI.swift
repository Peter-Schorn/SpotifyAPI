import Foundation
import Logging
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 The central class in this library. Provides methods for all of the Spotify
 web API endpoints and contains an authorization manager for managing the
 authorization process of your application.
 
 The methods that require authorization scopes and/or an access token that was
 issued on behalf of a user are declared in conditional conformances where
 `AuthorizationManager` conforms to `SpotifyScopeAuthorizationManager`.
 This protocol requires conforming types to support authorization scopes.
 This strategy provides a compile-time guarantee that you cannot call methods
 that require authorization scopes if you are using an authorization manager
 that doesn't support them.
 
 `AuthorizationCodeFlowManager` and `AuthorizationCodeFlowPKCEManager`
 conform to `SpotifyScopeAuthorizationManager`. `ClientCredentialsFlowManager`
 is not a conforming type because it does not support authorization scopes.
 
 All of the endpoints are documented at the the [web API reference][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/
 */
public class SpotifyAPI<AuthorizationManager: SpotifyAuthorizationManager>: Codable {

    // MARK: - Authorization -

    /**
     Manages the authorization process for your application and contains all the
     authorization information.
     
     It is this property that you should encode to data using a `JSONEncoder`
     in order to save it to persistent storage. This prevents the user from
     having to login again everytime the app is quit and relaunched. See this
     [article][1] for more information.
     
     Assigning a new authorization manager to this property causes
     `authorizationManagerDidChange` to emit a signal.
     
     [1]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
     */
    public var authorizationManager: AuthorizationManager {
        didSet {
            self.authDidChangeLogger.trace(
                "did set authorizationManager"
            )
            self.assertNotOnUpdateAuthInfoDispatchQueue()

            self.configureDidChangeSubscriptions()
            
            self.authDidChangeLogger.trace(
                "authorizationManagerDidChange.send()"
            )
            self.authorizationManagerDidChange.send()
        }
    }

    /**
     A function that gets called everytime this class—and only this
     class—needs to make a network request.
    
     Use this function if you need to use a custom networking client. The `url`
     and `httpMethod` properties of the `URLRequest` parameter are guaranteed
     to be non-`nil`. No guarentees are made about which thread this function
     will be called on. By default, `URLSession` will be used for the network
     requests.
     
     - Warning: Do not mutate this property while a network request is being
           made.
     */
    public var networkAdaptor:
        (URLRequest) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
    
    /**
     A publisher that emits whenever the authorization information
     changes.
     
     Subscribe to this subject in order to update the persistent storage of
     the authorization information. See this [article][1] for more information.
     
     Emits after any of the following events occur:

     * After the access and/or refresh tokens are retrieved.
     * After the access token (and possibly the refresh token) is refreshed.
     * After you assign a new authorization manager to the `authorizationManager`
       property of this class.
     
     This publisher subscribes to the `didChange` publisher of
    `authorizationManager` and emits whenever it emits.
     
     See also `authorizationManagerDidDeauthorize`, a publisher that emits after
     `authorizationManager.deauthorize()` is called.
     
     # Thread Safety
     
     No guarantees are made about which thread this publisher will emit on.
     Always receive on the main thread if you plan on updating the UI.
     
     [1]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
     */
    public let authorizationManagerDidChange = PassthroughSubject<Void, Never>()
    
    /**
     A publisher that emits after `authorizationManager.deauthorize()` is
     called.
     
     `authorizationManager.deauthorize()` sets the authorization information
     to `nil`.
     
     Subscribe to this publisher in order to remove the authorization
     information from persistent storage when it emits.
     
     This publisher subscribes to the `didDeauthorize` publisher of
    `authorizationManager` and emits whenever it emits.
     
     See also `authorizationManagerDidChange`.
     
     # Thread Safety
     
     No guarantees are made about which thread this publisher will emit on.
     Always receive on the main thread if you plan on updating the UI.
     */
    public let authorizationManagerDidDeauthorize = PassthroughSubject<Void, Never>()

    private var authManagerDidChangeCancellable: AnyCancellable? = nil
    private var authManagerDidDeauthorizeCancellable: AnyCancellable? = nil

    // MARK: - Loggers -
    
    /// Logs general messages for this class.
    public lazy var logger = Logger(label: "SpotifyAPI", level: .critical)
    
    /**
     Logs messages when the authorization information changes.
     
     Logs a message when the any of the following publishers emit a signal:
     
     * `authorizationManagerDidChange`
     * `authorizationManagerDidDeauthorize`
     * `authorizationManager.didChange`
     * `authorizationManager.didDeauthorize`
     
     Also logs a message in the didSet observer of `authorizationManager`.
     
     */
    public lazy var authDidChangeLogger = Logger(
        label: "authDidChange", level: .critical
    )
    
    /// Logs the URLs of the network requests made to Spotify and,
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
     
     - Parameters:
         - authorizationManager: An instance of a type that conforms to
               `SpotifyAuthorizationManager`. It Manages the authorization
               process for your application and contains all the authorization
               information. It is this property that you should encode to data
               using a `JSONEncoder` in order to save it to persistent storage.
               See this [article][2] for more information.
         - networkAdaptor: A function that gets called everytime this class—and
               only this class—needs to make a network request. The
               `authorizationManager` will **NOT** use this function. Instead,
               you must configure a network adaptor for it as well. Use this
               function if you need to use a custom networking client. The `url`
               and `httpMethod` properties of the `URLRequest` parameter are
               guaranteed to be non-`nil`. No guarentees are made about which
               thread this function will be called on. The default is `nil`,
               in which case `URLSession` will be used for the network requests.
     
     [1]: https://developer.spotify.com/dashboard/login
     [2]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
     */
    public init(
        authorizationManager: AuthorizationManager,
        networkAdaptor: (
            (URLRequest) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
        )? = nil
    )  {
        
        SpotifyAPILogHandler.bootstrap()

        self.authorizationManager = authorizationManager
        
        self.networkAdaptor = networkAdaptor ??
                URLSession.shared.defaultNetworkAdaptor(request:)
        
        self.configureDidChangeSubscriptions()
        
    }
    
    deinit {
        self.logger.notice("--- DEINIT ---")
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
        SpotifyAPILogHandler.bootstrap()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.authorizationManager = try container.decode(
            AuthorizationManager.self,
            forKey: .authorizationManager
        )
        self.networkAdaptor = URLSession.shared.defaultNetworkAdaptor(request:)
        self.configureDidChangeSubscriptions()
        
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
  
    /// :nodoc:
    public enum CodingKeys: String, CodingKey {
        case authorizationManager
    }

}

private extension SpotifyAPI {
    
    private func configureDidChangeSubscriptions() {
        
        self.authDidChangeLogger.trace("")
        
        self.authManagerDidChangeCancellable =
            self.authorizationManager.didChange
                .handleEvents(receiveOutput: { _ in
                    self.authDidChangeLogger.trace(
                        """
                        received signal from \
                        self.authorizationManager.didChange
                        """
                    )
                    self.assertNotOnUpdateAuthInfoDispatchQueue()
                })
                .subscribe(authorizationManagerDidChange)
        
        self.authManagerDidDeauthorizeCancellable =
            self.authorizationManager.didDeauthorize
                .handleEvents(receiveOutput: { _ in
                    self.authDidChangeLogger.trace(
                        """
                        received signal from \
                        self.authorizationManager.didDeauthorize
                        """
                    )
                    self.assertNotOnUpdateAuthInfoDispatchQueue()
                })
                .subscribe(authorizationManagerDidDeauthorize)
        
    }

}

// MARK: - Testing -

extension SpotifyAPI {
    
    /// This method has no stable API and may change arbitrarily.
    /// Only use it for testing purposes.
    public func setupDebugging() {
        
        // MARK: keep up to date with "Debugging" wiki page
        // https://github.com/Peter-Schorn/SpotifyAPI/wiki/Debugging
        
        self.logger.logLevel = .trace
        self.apiRequestLogger.logLevel = .trace
        self.authDidChangeLogger.logLevel = .trace
        
        AuthorizationManagerLoggers
                .authorizationCodeFlowManagerBaseLogger.logLevel = .trace
        AuthorizationManagerLoggers
                .authorizationCodeFlowManagerLogger.logLevel = .trace
        AuthorizationManagerLoggers
                .authorizationCodeFlowPKCEManagerLogger.logLevel = .trace
        AuthorizationManagerLoggers
                .clientCredentialsFlowManagerLogger.logLevel = .trace
        
        CurrentlyPlayingContext.logger.logLevel = .trace
        
        spotifyDecodeLogger.logLevel = .warning
        
        self.logger.trace("\(Self.self): did setup debugging")
        
    }
    
    func assertNotOnUpdateAuthInfoDispatchQueue() {
		authorizationManager.assertNotOnUpdateAuthInfoDispatchQueue()
    }
    
}
