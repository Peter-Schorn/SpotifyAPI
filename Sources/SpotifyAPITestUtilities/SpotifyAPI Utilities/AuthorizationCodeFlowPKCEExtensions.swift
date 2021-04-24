import Foundation

#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import SpotifyWebAPI

public extension SpotifyAPI where AuthorizationManager == AuthorizationCodeFlowPKCEManager<AuthorizationCodeFlowPKCEClientBackend> {
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret
        )
    )
    
    /// A shared instance used for testing purposes with a custom network
    /// adaptor for `self` and `AuthorizationCodeFlowPKCEManager`.
    static let sharedTestNetworkAdaptor = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret,
            networkAdaptor: NetworkAdaptorManager.shared.networkAdaptor(request:)
        ),
        networkAdaptor: NetworkAdaptorManager.shared.networkAdaptor(request:)
    )

}

public extension SpotifyAPI where AuthorizationManager == AuthorizationCodeFlowPKCEManager<AuthorizationCodeFlowPKCEProxyBackend> {
    
    /// We probably don't want to use the same instance of
    /// `AuthorizationCodeFlowPKCEProxyBackend` more than once, so we make a
    /// new one each time.
    private static func makeBackend() -> AuthorizationCodeFlowPKCEProxyBackend {
        return AuthorizationCodeFlowPKCEProxyBackend(
            clientId: spotifyCredentials.clientId,
            tokenURL: spotifyBackendTokenURL,
            tokenRefreshURL: spotifyBackendTokenRefreshURL
        )
    }

    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            backend: makeBackend()
        )
    )
    
    /// A shared instance used for testing purposes with a custom network
    /// adaptor for `self` and `AuthorizationCodeFlowPKCEManager`.
    static let sharedTestNetworkAdaptor = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            backend: makeBackend(),
            networkAdaptor: NetworkAdaptorManager.shared.networkAdaptor(request:)
        ),
        networkAdaptor: NetworkAdaptorManager.shared.networkAdaptor(request:)
    )
    
}


public extension AuthorizationCodeFlowPKCEManager {
    
    
    /// Authorizes the application. You should probably use
    /// `authorizeAndWaitForTokens(scopes:showDialog:)` instead,
    /// which blocks the thread until the application is authorized.
    ///
    /// Returns early if the application is already authorized.
    func testAuthorize(
        scopes: Set<Scope> = Scope.allCases
    ) -> AnyPublisher<Void, Error> {
    
        if self.isAuthorized(for: scopes) {
            return Empty().eraseToAnyPublisher()
        }
        
        let codeVerifier = String.randomURLSafe(length: 128)
        let codeChallenge = codeVerifier.makeCodeChallenge()
        let state = Bool.random() ? String.randomURLSafe(length: 128) : nil
//        let state = "~" + String.randomURLSafe(length: 125)
        
        guard let authorizationURL = self.makeAuthorizationURL(
            redirectURI: localHostURL,
            codeChallenge: codeChallenge,
            state: state,
            scopes: scopes
        )
        else {
            fatalError("couldn't make authorization URL")
        }
        
        print("authorization URL: '\(authorizationURL)'")
        
        guard let redirectURLWithQuery = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        ) else {
            fatalError("couldn't get redirectURLWithQuery")
        }
        
        return self.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURLWithQuery,
            codeVerifier: codeVerifier,
            state: state
        
        )
        
    }
    
    /// Blocks the thread until the application has been authorized
    /// and the refresh and access tokens have been retrieved.
    /// Returns early if the application is already authorized.
    func authorizeAndWaitForTokens(
        scopes: Set<Scope> = Scope.allCases
    ) {
        
        if self.isAuthorized(for: scopes) {
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
