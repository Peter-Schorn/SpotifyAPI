
import XCTest
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation

#endif
@testable import SpotifyWebAPI

/// The base protocol that all tests involving `SpotifyAPI` inherit from.
public protocol SpotifyAPITests: SpotifyAPITestCase {
    
    associatedtype AuthorizationManager: SpotifyAuthorizationManager
    
    static var spotify: SpotifyAPI<AuthorizationManager> { get set }
    static var cancellables: Set<AnyCancellable> { get set }
    
}

public extension SpotifyAPITests {
    
    static func setUpDebugging() {
        spotify.setupDebugging()
    }

}

public extension SpotifyAPITests where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{

    static func authorizeAndWaitForTokens(
        scopes: Set<Scope>, showDialog: Bool = false
    ) {
        if let spotify = Self.spotify as?
                SpotifyAPI<AuthorizationCodeFlowManager> {
            spotify.authorizeAndWaitForTokens(
                scopes: scopes, showDialog: showDialog
            )
        }
        else if let spotify = Self.spotify as?
                SpotifyAPI<AuthorizationCodeFlowPKCEManager> {
            spotify.authorizeAndWaitForTokens(
                scopes: scopes
            )
        }
        else {
            fatalError(
                "unsupported authorization manager: " +
                "\(type(of: Self.spotify.authorizationManager))"
            )
        }
    }
    
}

public extension SpotifyAuthorizationManager {
    
    /// Only use for testing purposes.
    func setExpirationDate(to date: Date) {
        if let authManager = self as? AuthorizationCodeFlowManagerBase {
            authManager.setExpirationDate(to: Date())
        }
        else if let authManager = self as? ClientCredentialsFlowManager {
            authManager.setExpirationDate(to: Date())
        }
        else {
            fatalError("not implemented")
        }
    }
    
}
