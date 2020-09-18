import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

import Combine
import SpotifyWebAPI

public let clientId: String = {
    guard let clientId = ProcessInfo.processInfo
            .environment["client_id"] else {
        fatalError(
            "you must provide 'client_id' in the environment variables"
        )
    }
    return clientId
}()

public let clientSecret: String = {
    guard let clientSecret = ProcessInfo.processInfo
            .environment["client_secret"] else {
        fatalError(
            "you must provide 'client_secret' in the environment variables"
        )
    }
    return clientSecret
}()

/// "http://localhost"
public let localHostURL = URL(string: "http://localhost")!

public extension SpotifyAPI where AuthorizationManager == AuthorizationCodeFlowManager {
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: clientId, clientSecret: clientSecret
        )
    )
    
    /// Authorizes the application. You should probably use
    /// `authorizeAndWaitForTokens(scopes:showDialog:)` instead,
    /// which authorizes and retrieves the refresh and access tokens.
    func testAuthorize(
        scopes: Set<Scope>,
        showDialog: Bool = false
    ) -> AnyPublisher<Void, Error> {
    
        guard let authorizationURL = self.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            showDialog: showDialog,
            scopes: scopes
        )
        else {
            fatalError("couldn't make authorization URL")
        }
        
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
            redirectURIWithQuery: redirectURLWithQuery
        )
        .XCTAssertNoFailure(
            "error requesting access and refresh tokens"
        )
        
    }
    
    /// Blocks the thread until the application has been authorized
    /// and the refresh and acess tokens have been retrieved.
    /// Returns early if the application is already authorized.
    func authorizeAndWaitForTokens(
        scopes: Set<Scope>,
        showDialog: Bool = false
    ) {
        
        if self.authorizationManager.isAuthorized(for: scopes) {
            return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let cancellable = self.testAuthorize(scopes: Scope.allCases)
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

public extension SpotifyAPI where AuthorizationManager == ClientCredentialsFlowManager {
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: ClientCredentialsFlowManager(
            clientId: clientId, clientSecret: clientSecret
        )
    )
    
    /// Calls `authorizationManager.authorize()` and blocks
    /// until the publisher finishes.
    /// Returns early if the application is already authorized.
    func waitUntilAuthorized() {
        
        if self.authorizationManager.isAuthorized() { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let cancellable = self.authorizationManager.authorize()
            .XCTAssertNoFailure()
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
