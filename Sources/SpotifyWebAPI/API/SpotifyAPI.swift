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
    public let spotifyAPILogger = Logger(label: "SpotifyAPI", level: .critical)
    
    /// Logs the urls of the requests made to Spotify and,
    /// if present, the body of the requests.
    public let apiRequestLogger = Logger(label: "APIRequest", level: .critical)
    
    private var cancellables: Set<AnyCancellable> = []
    
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
     - clientId: A Spotify Client ID.
     - clientSecret: A Spotify Client Secret.
     
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
        self.spotifyAPILogger.level = .trace
        self.apiRequestLogger.level = .trace
        
    }
    
}
