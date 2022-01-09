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
public extension SpotifyAPI where AuthorizationManager == AuthorizationCodeFlowManager {
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: spotifyCredentials.clientId,
            clientSecret: spotifyCredentials.clientSecret
        )
    )
    
}

// MARK: Proxy
public extension SpotifyAPI where
    AuthorizationManager == AuthorizationCodeFlowBackendManager<AuthorizationCodeFlowProxyBackend>
{
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowBackendManager(
            backend: AuthorizationCodeFlowProxyBackend(
                clientId: spotifyCredentials.clientId,
                tokensURL: authorizationCodeFlowTokensURL,
                tokenRefreshURL: authorizationCodeFlowRefreshTokensURL,
                decodeServerError: VaporServerError.decodeFromNetworkResponse(data:response:)
            )
        )
    )
    
}

public extension AuthorizationCodeFlowBackendManager {
    
    
    /**
     Authorizes the application.
    
     You should probably use ``authorizeAndWaitForTokens(scopes:showDialog:)``
     instead, which blocks the thread until the application is authorized.
     Returns early if the application is already authorized.
     */
    func testAuthorize(
        scopes: Set<Scope> = Scope.allCases,
        showDialog: Bool = false
    ) -> AnyPublisher<Void, Error> {
    
        if self.isAuthorized(for: scopes) {
            return Empty().eraseToAnyPublisher()
        }
        
        let state = Bool.random() ? String.randomURLSafe(
            length: Int.random(in: 32...128)
        ) : nil
        
        guard let authorizationURL = self.makeAuthorizationURL(
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
        
        return self.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURLWithQuery, state: state
        )

    }
    
    /// Blocks the thread until the application has been authorized and the
    /// refresh and access tokens have been retrieved. Returns early if the
    /// application is already authorized.
    func authorizeAndWaitForTokens(
        scopes: Set<Scope> = Scope.allCases,
        showDialog: Bool = false
    ) {
        
        if self.isAuthorized(for: scopes) {
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
        
        _ = cancellable  // suppress warnings
        
        semaphore.wait()
        
    }
    
}
