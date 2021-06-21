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
public extension SpotifyAPI where AuthorizationManager == AuthorizationCodeFlowPKCEManager {
    
    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: spotifyCredentials.clientId
        )
    )
    
}

// MARK: Proxy
public extension SpotifyAPI where
    AuthorizationManager == AuthorizationCodeFlowPKCEBackendManager<AuthorizationCodeFlowPKCEProxyBackend>
{

    /// A shared instance used for testing purposes.
    static let sharedTest = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEBackendManager(
            backend: AuthorizationCodeFlowPKCEProxyBackend(
                clientId: spotifyCredentials.clientId,
                tokensURL: authorizationCodeFlowPKCETokensURL,
                tokenRefreshURL: authorizationCodeFlowPKCERefreshTokensURL,
                decodeServerError: VaporServerError.decodeFromNetworkResponse(data:response:)
            )
        )
    )
    
}


public extension AuthorizationCodeFlowPKCEBackendManager {
    
    /**
     Authorizes the application.
     
     You should probably use ``authorizeAndWaitForTokens(scopes:showDialog:)``
     instead, which blocks the thread until the application is authorized.
     Returns early if the application is already authorized.
     */
    func testAuthorize(
        scopes: Set<Scope> = Scope.allCases
    ) -> AnyPublisher<Void, Error> {
    
        if self.isAuthorized(for: scopes) {
            return Empty().eraseToAnyPublisher()
        }
        
        let codeVerifier = String.randomURLSafe(
            length: Int.random(in: 43...128)
        )
        let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)
        let state = Bool.random() ? String.randomURLSafe(
            length: Int.random(in: 32...128)
        ) : nil
        
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
    
    /// Blocks the thread until the application has been authorized and the
    /// refresh and access tokens have been retrieved. Returns early if the
    /// application is already authorized.
    func authorizeAndWaitForTokens(
        scopes: Set<Scope> = Scope.allCases, showDialog: Bool = false
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
        
        _ = cancellable  // suppress warnings
        
        semaphore.wait()
        
    }
    
}
