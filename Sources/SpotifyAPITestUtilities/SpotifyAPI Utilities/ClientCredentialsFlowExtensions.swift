import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import SpotifyWebAPI

// MARK: Client
public extension SpotifyAPI where AuthorizationManager == ClientCredentialsFlowManager {
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: ClientCredentialsFlowManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret
        )
    )
    
    /// A shared instance used for testing purposes with a custom network
    /// adaptor for `self` and `AuthorizationCodeFlowManager`.
    static let sharedTestNetworkAdaptor = SpotifyAPI(
        authorizationManager: ClientCredentialsFlowManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret,
            networkAdaptor: NetworkAdaptorManager.shared.networkAdaptor(request:)
        ),
        networkAdaptor: NetworkAdaptorManager.shared.networkAdaptor(request:)
    )
    
}

// MARK: Proxy
public extension SpotifyAPI where
    AuthorizationManager == ClientCredentialsFlowBackendManager<ClientCredentialsFlowProxyBackend>
 {
 
    /// We probably don't want to use the same instance of
    /// `ClientCredentialsFlowProxyBackend` more than once, so we make a
    /// new one each time.
    private static func makeBackend() -> ClientCredentialsFlowProxyBackend {
        return ClientCredentialsFlowProxyBackend(
            tokenURL: spotifyBackendTokenURL
        )
    }

    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: ClientCredentialsFlowBackendManager(
            backend: makeBackend()
        )
    )
    
    /// A shared instance used for testing purposes with a custom network
    /// adaptor for `self` and `AuthorizationCodeFlowManager`.
    static let sharedTestNetworkAdaptor = SpotifyAPI(
        authorizationManager: ClientCredentialsFlowBackendManager(
            backend: makeBackend(),
            networkAdaptor: NetworkAdaptorManager.shared.networkAdaptor(request:)
        ),
        networkAdaptor: NetworkAdaptorManager.shared.networkAdaptor(request:)
    )
    
}

public extension ClientCredentialsFlowBackendManager {
    
    
    /// Calls `authorizationManager.authorize()` and blocks
    /// until the publisher finishes.
    /// Returns early if the application is already authorized.
    func waitUntilAuthorized() {
        
        if self.isAuthorized() { return }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let cancellable = self.authorize()
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
