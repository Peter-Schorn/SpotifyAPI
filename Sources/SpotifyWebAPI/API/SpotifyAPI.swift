import Foundation
import Logger
import Combine
import SwiftUI

/**
 The central class in this library.
 
 It provides methods for all of the Spotify web API endpoints
 and contains an authorization manager for managing the
 authorization/authentication process of your application.
 */
public class SpotifyAPI<AuthorizationManager: SpotifyAuthorizationManager> {
    
    /// Manages the authorization process for your application.
    public var authorizationManager: AuthorizationManager
    
    // MARK: - Loggers -
    
    /// Logs general messages for this class.
    public let logger = Logger(label: "SpotifyAPI", level: .critical)
    
    /// Logs the urls of the requests made to Spotify and,
    /// if present, the body of the requests.
    /// Note that the http body for each request will be logged before
    /// the url is logged.
    public let apiRequestLogger = Logger(label: "APIRequest", level: .critical)
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers -

    /**
     Creates an instance of `SpotifyAPI`, which contains
     all the methods for making requests to the Spotify web API.
     
     To get your client id and secret,
     see the [guide for registering your app][1].
     
     - Parameter authorizationManager: An authorization manager.
     
     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/
     */
    public init(authorizationManager: AuthorizationManager)  {
        self.authorizationManager = authorizationManager
        self.setupDebugging()
    }
    
}

extension SpotifyAPI {
    
    /// This function has no stable API and may change arbitrarily.
    public func setupDebugging() {
        
        SpotifyDecodingError.dataDumpfolder = URL(fileURLWithPath:
            "/Users/pschorn/Desktop/"
        )
        CurrentlyPlayingContext.logger.level = .trace
        
        self.logger.level = .trace
        self.apiRequestLogger.level = .trace
        
    }
    
}
