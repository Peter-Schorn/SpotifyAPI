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
public class SpotifyAPI<AuthorizationManager: SpotifyAuthorizationManager>:
        ObservableObject
{
    
    /**
     Manages the authorization process for your application.
     
     This is a `Published` property, so you can subscribe to
     it using `$authorizationManager.sink(receiveValue:)`.
     
     For example, you could subscribe to this property so that
     you can update persistent storage or update your UI
     to reflect whether your application has been authorized
     by the user.
     */
    
    @Published public var authorizationManager: AuthorizationManager
    // @ObservedObject public var authorizationManager: AuthorizationManager
    
    // MARK: - Loggers -
    
    /// Logs general messages for this class.
    public let spotifyAPILogger = Logger(label: "SpotifyAPI", level: .trace)
    
    /// Logs the urls of the requests made to Spotify and,
    /// if present, the body of the requests.
    public let apiRequestLogger = Logger(label: "APIRequest", level: .trace)
    
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
        self.setupPublishers()
    }
    
}

extension SpotifyAPI {
    
    private func setupPublishers() {
        
        self.authorizationManager.objectWillChange
            .receive(on: RunLoop.main)
            .sink { _ in
                self.spotifyAPILogger.notice(
                    "setupDebugging: self.authorizationManager.objectWillChange.sink"
                )
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        
        self.objectWillChange
            .receive(on: RunLoop.main)
            .sink {
                print("setupDebugging: objectWillChange.sink")
            }
            .store(in: &cancellables)
        
        self.$authorizationManager
            .receive(on: RunLoop.main)
            .sink { authManager in
                print("setupDebugging: $authorizationManager.sink:\n\(authManager)")
            }
            .store(in: &cancellables)
        
    }
    
    
    /// This function has no stable API and may change arbitrarily.
    public func setupDebugging() {
        
        SpotifyDecodingError.dataDumpfolder = URL(fileURLWithPath:
            "/Users/pschorn/Desktop/"
        )
        
    }
    
}
