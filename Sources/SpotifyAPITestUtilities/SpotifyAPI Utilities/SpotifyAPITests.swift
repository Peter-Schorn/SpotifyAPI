
import XCTest
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation

#endif

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@testable import SpotifyWebAPI

/// The base protocol that all tests involving `SpotifyAPI` inherit from.
public protocol SpotifyAPITests: SpotifyAPITestCase {
    
    associatedtype AuthorizationManager: _InternalSpotifyAuthorizationManager
    
    static var spotify: SpotifyAPI<AuthorizationManager> { get set }
    static var cancellables: Set<AnyCancellable> { get set }
    
}

// MARK: - Generic Backend -

/// Generic over the backend.
public protocol AuthorizationCodeFlowTestsProtocol: SpotifyAPITests {

    associatedtype Backend: AuthorizationCodeFlowBackend

    static var spotify: SpotifyAPI<AuthorizationCodeFlowManager<Backend>> { get set }

}

/// Generic over the backend.
public protocol AuthorizationCodeFlowPKCETestsProtocol: SpotifyAPITests {

    associatedtype Backend: AuthorizationCodeFlowPKCEBackend

    static var spotify: SpotifyAPI<AuthorizationCodeFlowPKCEManager<Backend>> { get set }

}

// MARK: - Internal Authorization Managers -

/// Provides generic access to members that are only expected to be
/// available in the authorization managers in this library, as opposed
/// to those that may be created by other clients.
public protocol _InternalSpotifyAuthorizationManager: SpotifyAuthorizationManager {

    /**
     Sets the expiration date of the access token to the specified date.
     **Only use for testing purposes**.
     
     - Parameter date: The date to set the expiration date to.
     */
    func setExpirationDate(to date: Date) -> Void
    
    var networkAdaptor: (
        URLRequest
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        get set
    }
    
}

/// Provides generic access to members that are only expected to be
/// available in the **scope** authorization managers in this library, as opposed
/// to those that may be created by other clients.
public protocol _InternalSpotifyScopeAuthorizationManager:
    SpotifyScopeAuthorizationManager,
    _InternalSpotifyAuthorizationManager

{
    
    /// Blocks the thread until the application has been authorized
    /// and the refresh and access tokens have been retrieved.
    /// Returns early if the application is already authorized.
    func authorizeAndWaitForTokens(
        scopes: Set<Scope>, showDialog: Bool
    ) -> Void
    
}

extension AuthorizationCodeFlowManager: _InternalSpotifyScopeAuthorizationManager { }

extension AuthorizationCodeFlowPKCEManager: _InternalSpotifyScopeAuthorizationManager {
    
    public func authorizeAndWaitForTokens(scopes: Set<Scope>, showDialog: Bool) {
        self.authorizeAndWaitForTokens(scopes: scopes)
    }

}

extension ClientCredentialsFlowManager: _InternalSpotifyAuthorizationManager { }
