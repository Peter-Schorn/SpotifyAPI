import Foundation

#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import SpotifyWebAPI

public extension SpotifyAPI where AuthorizationManager == AuthorizationCodeFlowPKCEManager {
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret
        )
    )
    
    static let sharedTestNetworkAdaptor = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret,
            networkAdaptor: HTTTPClientManager.shared.networkAdaptor(request:)
        )
    )
    
    /// Authorizes the application. You should probably use
    /// `authorizeAndWaitForTokens(scopes:showDialog:)` instead,
    /// which blocks the thread until the application is authorized.
    ///
    /// Returns early if the application is already authorized.
    func testAuthorize(
        scopes: Set<Scope>
    ) -> AnyPublisher<Void, Error> {
    
        if self.authorizationManager.isAuthorized(for: scopes) {
            return Empty().eraseToAnyPublisher()
        }
        
        let codeVerifier = String.randomURLSafe(length: 128)
        let codeChallenge = codeVerifier.makeCodeChallenge()
        let state = Bool.random() ? String.randomURLSafe(length: 128) : nil
//        let state = "~" + String.randomURLSafe(length: 125)
        
        
        guard let authorizationURL = self.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            codeChallenge: codeChallenge,
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
            redirectURIWithQuery: redirectURLWithQuery,
            codeVerifier: codeVerifier,
            state: state
        
        )
        
    }
    
    /// Blocks the thread until the application has been authorized
    /// and the refresh and access tokens have been retrieved.
    /// Returns early if the application is already authorized.
    func authorizeAndWaitForTokens(
        scopes: Set<Scope>
    ) {
        
        if self.authorizationManager.isAuthorized(for: scopes) {
            return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let cancellable = self.testAuthorize(
            scopes: scopes
        )
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
