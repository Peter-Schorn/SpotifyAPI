
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

// MARK: - Internal Authorization Managers -

/// Provides generic access to members that are only expected to be available in
/// the authorization managers in this library, as opposed to those that may be
/// created by other clients.
public protocol _InternalSpotifyAuthorizationManager: SpotifyAuthorizationManager, Equatable {

    var _accessToken: String? { get set }

    /**
     Sets the expiration date of the access token to the specified date.
     **Only use for testing purposes**.
     
     - Parameter date: The date to set the expiration date to.
     */
    func setExpirationDate(to date: Date) -> Void
   
    func waitUntilAuthorized() -> Void

}

/// Provides generic access to members that are only expected to be available in
/// the **scope** authorization managers in this library, as opposed to those
/// that may be created by other clients.
public protocol _InternalSpotifyScopeAuthorizationManager:
    SpotifyScopeAuthorizationManager,
    _InternalSpotifyAuthorizationManager

{
    var _refreshToken: String? { get set }
    
    /// Blocks the thread until the application has been authorized and the
    /// refresh and access tokens have been retrieved. Returns early if the
    /// application is already authorized.
    func authorizeAndWaitForTokens(
        scopes: Set<Scope>, showDialog: Bool
    ) -> Void
    
}

// MARK: - Generic Over Backend -

public protocol _AuthorizationCodeFlowManagerProtocol: _InternalSpotifyScopeAuthorizationManager {
    
    func makeAuthorizationURL(
        redirectURI: URL,
        showDialog: Bool,
        state: String?,
        scopes: Set<Scope>
    ) -> URL?
    
    func requestAccessAndRefreshTokens(
        redirectURIWithQuery: URL,
        state: String?
    ) -> AnyPublisher<Void, Error>
    
}

public protocol _AuthorizationCodeFlowPKCEManagerProtocol: _InternalSpotifyScopeAuthorizationManager {
    
    func makeAuthorizationURL(
        redirectURI: URL,
        codeChallenge: String,
        state: String?,
        scopes: Set<Scope>
    ) -> URL?
    
    func requestAccessAndRefreshTokens(
        redirectURIWithQuery: URL,
        codeVerifier: String,
        state: String?
    ) -> AnyPublisher<Void, Error> 
    
}

public protocol _ClientCredentialsFlowManagerProtocol: _InternalSpotifyAuthorizationManager {
    
    func authorize() -> AnyPublisher<Void, Error>

}

// MARK: - Conformances -

extension AuthorizationCodeFlowBackendManager: _AuthorizationCodeFlowManagerProtocol {
    
    public func waitUntilAuthorized() {
        self.authorizeAndWaitForTokens(
            scopes: Scope.allCases,
            showDialog: false
        )
    }

}

extension AuthorizationCodeFlowPKCEBackendManager: _AuthorizationCodeFlowPKCEManagerProtocol {
    
    public func waitUntilAuthorized() {
        self.authorizeAndWaitForTokens(scopes: Scope.allCases)
    }

}

extension ClientCredentialsFlowBackendManager: _ClientCredentialsFlowManagerProtocol { }


