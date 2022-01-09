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
    
}

// MARK: Proxy
public extension SpotifyAPI where
    AuthorizationManager == ClientCredentialsFlowBackendManager<ClientCredentialsFlowProxyBackend>
 {
 
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: ClientCredentialsFlowBackendManager(
            backend: ClientCredentialsFlowProxyBackend(
                tokensURL: clientCredentialsFlowTokensURL,
                decodeServerError: VaporServerError.decodeFromNetworkResponse(data:response:)
            )
        )
    )
    
}

public extension ClientCredentialsFlowBackendManager {
    
    
    /// Calls ``authorize()`` and blocks until the publisher
    /// finishes. Returns early if the application is already authorized.
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
        
        _ = cancellable  // suppress warnings
        
        semaphore.wait()

    }

}
