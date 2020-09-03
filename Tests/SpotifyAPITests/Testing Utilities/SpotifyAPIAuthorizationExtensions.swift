import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

import Combine
import SpotifyWebAPI

private let clientId: String = {
    guard let clientId = ProcessInfo.processInfo
            .environment["client_id"] else {
        fatalError(
            "you must provide 'client_id' in the environment variables"
        )
    }
    return clientId
}()

private let clientSecret: String = {
    guard let clientSecret = ProcessInfo.processInfo
            .environment["client_secret"] else {
        fatalError(
            "you must provide 'client_secret' in the environment variables"
        )
    }
    return clientSecret
}()

/// "http://localhost"
let localHostURL = URL(string: "http://localhost")!

extension SpotifyAPI where AuthorizationManager == AuthorizationCodeFlowManager {
    
    static let shared = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: clientId, clientSecret: clientSecret
        )
    )
    
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
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        let cancellable = self.testAuthorize(scopes: Scope.allCases)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        dispatchGroup.leave()
                    case .failure(let error):
                        fatalError(
                            "couldn't authorize application:\n\(error)"
                        )
                }
            })
        
        _ = cancellable  // supress warnings
        
        dispatchGroup.wait()
        
    }
    
}

extension SpotifyAPI where AuthorizationManager == ClientCredentialsFlowManager {
    
    static let shared = SpotifyAPI(
        authorizationManager: ClientCredentialsFlowManager(
            clientId: clientId, clientSecret: clientSecret
        )
    )
    
    /// Calls `authorizationManager.authorize()` and blocks
    /// until the publisher finishes.
    /// Returns early if the application is already authorized.
    func waitUntilAuthorized() {
        
        if self.authorizationManager.isAuthorized() { return }
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        let cancellable = self.authorizationManager.authorize()
            .XCTAssertNoFailure()
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        dispatchGroup.leave()
                    case .failure(let error):
                        fatalError(
                            "couldn't authorize application:\n\(error)"
                        )
                }
            })
        
        _ = cancellable  // supress warnings
        
        dispatchGroup.wait()

    }

}
