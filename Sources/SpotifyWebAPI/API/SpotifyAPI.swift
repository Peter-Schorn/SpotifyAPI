import Foundation
import Logger
import Combine

/**
 The central class in this library.
 
 It provides methods for all of the Spotify web API endpoints
 and contains an authorization manager for managing the
 authorization/authentication process of your application.
 */
public class SpotifyAPI<AuthorizationManager: SpotifyAuthorizationManager> {
    
    // MARK: - Authorization -
    
    /// Manages the authorization process for your application.
    public var authorizationManager: AuthorizationManager {
        didSet {
            self.authDidChangeLogger.trace(
                "did set authorizationManager"
            )
            
            self.authorizationManager.didChange
                .subscribe(authorizationManagerDidChange)
                .store(in: &cancellables)
            
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
     
     Subscribing to this publisher is preferred over subscribing to the
     `didChange` publisher of `authorizationManager`.
     
     This publisher subscribes to the `didChange` publisher of
     `authorizationManager` in the `init(authorizationManager:)` method
     of this class and in the didSet block of `authorizationManager`.
     It also emits a signal in the didSet block of `authorizationManager`.
     
     This publisher allows you to be notified of changes to
     the authorization manager even when you create a new instance of it
     and assign it to the `authorizationManager` property of this class.
     
     # Thread Safety
     No guarantees are made about which thread this subject will emit on.
     Always receive on the main thread if you plan on updating the UI.
     */
    public let authorizationManagerDidChange = PassthroughSubject<Void, Never>()

    private var cancellables: Set<AnyCancellable> = []
    
    /// Logs general messages for this class.
    /// :nodoc:
    public let logger = Logger(label: "SpotifyAPI", level: .critical)
    
    public let authDidChangeLogger = Logger(
        label: "authDidChange", level: .critical
    )
    
    /// Logs the urls of the requests made to Spotify and,
    /// if present, the body of the requests by converting the raw
    /// data to a string.
    /// :nodoc:
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
        
        self.authorizationManager.didChange
            .subscribe(authorizationManagerDidChange)
            .store(in: &cancellables)
        
    }
    
    deinit {
        self.logger.notice("\n\n\(self): DEINIT\n\n")
    }

}

extension SpotifyAPI {
    
    /// This function has no stable API and may change arbitrarily.
    /// Only use it for testing purposes.
    func setupDebugging() {

        self.logger.level = .trace
        self.apiRequestLogger.level = .trace
        
        CurrentlyPlayingContext.logger.level = .trace
        AuthorizationCodeFlowManager.logger.level = .trace
        ClientCredentialsFlowManager.logger.level = .trace
        
    }
    
}


