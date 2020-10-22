import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

import Combine
import SpotifyWebAPI

public extension SpotifyAPI where AuthorizationManager == AuthorizationCodeFlowManager {
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret
        )
    )
    
    /// Authorizes the application. You should probably use
    /// `authorizeAndWaitForTokens(scopes:showDialog:)` instead,
    /// blocks the thread until the application is authorized.
    /// 
    /// Returns early if the application is already authorized.
    func testAuthorize(
        scopes: Set<Scope>,
        showDialog: Bool = false
    ) -> AnyPublisher<Void, Error> {
    
        if self.authorizationManager.isAuthorized(for: scopes) {
            return Empty().eraseToAnyPublisher()
        }
        
        let state = Bool.random() ? String.randomURLSafe(length: 128) : nil
        
        guard let authorizationURL = self.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            showDialog: showDialog,
            state: state,
            scopes: scopes
        )
        else {
            fatalError("couldn't make authorization URL")
        }
        
        print("authorization URL: '\(authorizationURL)'")
        
        let redirectURLwithQuery = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        )
        
        guard let redirectURLWithQuery = redirectURLwithQuery else {
            fatalError("couldn't convert redirect URI to URL")
        }
        
        return self.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURLWithQuery, state: state
        )

    }
    
    /// Blocks the thread until the application has been authorized
    /// and the refresh and access tokens have been retrieved.
    /// Returns early if the application is already authorized.
    func authorizeAndWaitForTokens(
        scopes: Set<Scope>,
        showDialog: Bool = false
    ) {
        
        if self.authorizationManager.isAuthorized(for: scopes) {
            return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let cancellable = self.testAuthorize(scopes: scopes)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        semaphore.signal()
                    case .failure(let error):
                        fatalError(
                            "couldn't authorize application:\n\(error)"
                        )
                }
            })
        
        _ = cancellable  // supress warnings
        
        semaphore.wait()
        
    }
    
}
