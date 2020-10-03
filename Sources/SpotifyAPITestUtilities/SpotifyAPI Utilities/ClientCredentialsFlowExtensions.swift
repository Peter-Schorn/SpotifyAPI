import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

import Combine
import SpotifyWebAPI

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
