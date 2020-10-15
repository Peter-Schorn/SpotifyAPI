import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

import Combine
import SpotifyWebAPI

public extension SpotifyAPI where AuthorizationManager == AuthorizationCodeFlowPKCEManager {
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret
        )
    )
    
    /// Authorizes the application. You should probably use
    /// `authorizeAndWaitForTokens(scopes:showDialog:)` instead,
    /// which authorizes and retrieves the refresh and access tokens.
    /// Returns early if the application is already authorized.
    func testAuthorize(
        scopes: Set<Scope>,
        showDialog: Bool = false
    ) -> AnyPublisher<Void, Error> {
    
        if self.authorizationManager.isAuthorized(for: scopes) {
            return Empty().eraseToAnyPublisher()
        }
        
        let codeVerifier = String.randomURLSafe(length: 128)
        let codeChallenge = codeVerifier.makeCodeChallenge()
        let state = String.randomURLSafe(length: 128)
        
        guard let authorizationURL = self.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            showDialog: showDialog,
            codeChallenge: codeChallenge,
            state: state,
            scopes: scopes
        )
        else {
            fatalError("couldn't make authorization URL")
        }
        
        print("authorization URL: '\(authorizationURL)'")
        
        #if os(macOS)
        NSWorkspace.shared.open(authorizationURL)
        #else
        UIApplication.shared.open(authorizationURL)
        #endif

        print(
            """

            ======================================================\
            ===============================================
            After You approve the application and are redirected, \
            paste the url that you were redirected to here:
            """
        )
        
        guard var redirectURLString = readLine(strippingNewline: true) else {
            fatalError("couldn't read redirect URI from standard input")
        }
        
        // see the documentation for `readLine`
        // see also https://en.wikipedia.org/wiki/Specials_(Unicode_block)#Unicode_chart
        let replacementCharacters: [Character] = [
            "\u{FFF9}", "\u{FFFA}", "\u{FFFB}", "\u{FFFC}", "\u{FFFD}",
            "\u{F702}"
        ]
        
        redirectURLString.removeAll(where: { character in
            replacementCharacters.contains(character)
        })
        
        guard let redirectURLWithQuery = URL(string: redirectURLString.strip()) else {
            fatalError(
                "couldn't convert redirect URI to URL: '\(redirectURLString)'"
            )
        }
        
        return self.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURLWithQuery,
            codeVerifier: codeVerifier,
            state: state
            
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
