import Foundation

#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import SpotifyWebAPI

public extension SpotifyAPI where AuthorizationManager == AuthorizationCodeFlowManager<AuthorizationEndpointNative> {
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret
        )
    )
    
    static let sharedTestNetworkAdaptor = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret,
            networkAdaptor: NetworkAdaptorManager.shared.networkAdaptor(request:)
        ),
        networkAdaptor: NetworkAdaptorManager.shared.networkAdaptor(request:)
    )
    
    /// Authorizes the application. You should probably use
    /// `authorizeAndWaitForTokens(scopes:showDialog:)` instead,
    /// which blocks the thread until the application is authorized.
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
//        let state = "~" + String.randomURLSafe(length: 125)
        
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
        
        guard let redirectURLWithQuery = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        ) else {
            fatalError("couldn't get redirectURLWithQuery")
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
        
        let cancellable = self.testAuthorize(
            scopes: scopes, showDialog: showDialog
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
