
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import XCTest

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@testable import SpotifyWebAPI

// MARK: - Proxy -

/// The base class for all tests involving
/// `SpotifyAPI<ClientCredentialsFlowManager>`.
open class SpotifyAPIClientCredentialsFlowProxyTests:
    SpotifyAPITestCase, SpotifyAPITests
{
    
    public static var spotify =
            SpotifyAPI<ClientCredentialsFlowBackendManager<ClientCredentialsFlowProxyBackend>>.sharedTest
    
    public static var cancellables: Set<AnyCancellable> = []

    /// If you only need to setup the authorization, override
    /// ``setupAuthorization()`` instead.
    override open class func setUp() {
        super.setUp()
        print(
            "setup debugging and authorization for " +
            "SpotifyAPIClientCredentialsFlowTests"
        )
        Self.spotify.setupDebugging()
        Self.fuzzSpotify()
        Self.setupAuthorization()
    }

    open class func setupAuthorization() {
        Self.spotify.authorizationManager.waitUntilAuthorized()
    }
    
    open class func fuzzSpotify() {
        
        encodeDecode(Self.spotify, areEqual: { lhs, rhs in
            lhs.authorizationManager == rhs.authorizationManager
        })
        do {
            let encoded = try JSONEncoder().encode(Self.spotify)
            let decoded = try JSONDecoder().decode(
                SpotifyAPI<ClientCredentialsFlowBackendManager<ClientCredentialsFlowProxyBackend>>.self,
                from: encoded
            )
            Self.spotify = decoded
            Self.spotify.authorizationManager.backend.decodeServerError =
                VaporServerError.decodeFromNetworkResponse(data:response:)

        } catch {
            fatalError("\(error)")
        }
        
    }

}

/// The base class for all tests involving
/// `SpotifyAPI<AuthorizationCodeFlowManager<AuthorizationCodeFlowProxyBackend>>`.
open class SpotifyAPIAuthorizationCodeFlowProxyTests:
    SpotifyAPITestCase, SpotifyAPITests
{

    public static var spotify =
            SpotifyAPI<AuthorizationCodeFlowBackendManager<AuthorizationCodeFlowProxyBackend>>.sharedTest

    public static var cancellables: Set<AnyCancellable> = []

    /// If you only need to setup the authorization, override
    /// ``setupAuthorization(scopes:showDialog:)`` instead.
    override open class func setUp() {
        super.setUp()
        print(
            "setup debugging and authorization for " +
            "SpotifyAPIAuthorizationCodeFlowTests"
        )
        Self.spotify.setupDebugging()
        Self.fuzzSpotify()
        Self.setupAuthorization()
    }

    open class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases,
        showDialog: Bool = false
    ) {

        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: scopes, showDialog: showDialog
        )
    }

    open class func fuzzSpotify() {

        encodeDecode(Self.spotify, areEqual: { lhs, rhs in
            lhs.authorizationManager == rhs.authorizationManager
        })
        do {
            let encoded = try JSONEncoder().encode(Self.spotify)
            let decoded = try JSONDecoder().decode(
                SpotifyAPI<AuthorizationCodeFlowBackendManager<AuthorizationCodeFlowProxyBackend>>.self,
                from: encoded
            )
            Self.spotify = decoded
            Self.spotify.authorizationManager.backend.decodeServerError =
                VaporServerError.decodeFromNetworkResponse(data:response:)

        } catch {
            fatalError("\(error)")
        }

    }


}

/// The base class for all tests involving
/// `SpotifyAPI<AuthorizationCodeFlowPKCEManager<AuthorizationCodeFlowPKCEProxyBackend>>`.
open class SpotifyAPIAuthorizationCodeFlowPKCEProxyTests:
    SpotifyAPITestCase, SpotifyAPITests
{
    public static var spotify =
            SpotifyAPI<AuthorizationCodeFlowPKCEBackendManager<AuthorizationCodeFlowPKCEProxyBackend>>.sharedTest

    public static var cancellables: Set<AnyCancellable> = []

    /// If you only need to setup the authorization, override
    /// ``setupAuthorization(scopes:)`` instead.
    override open class func setUp() {
        super.setUp()
        print(
            "setup debugging and authorization for " +
            "SpotifyAPIAuthorizationCodeFlowPKCETests"
        )
        Self.spotify.setupDebugging()
        Self.fuzzSpotify()
        Self.setupAuthorization()
    }

    open class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases
    ) {
        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: scopes
        )
    }

    open class func fuzzSpotify() {

        encodeDecode(Self.spotify, areEqual: { lhs, rhs in
            lhs.authorizationManager == rhs.authorizationManager
        })
        do {
            let encoded = try JSONEncoder().encode(Self.spotify)
            let decoded = try JSONDecoder().decode(
                SpotifyAPI<AuthorizationCodeFlowPKCEBackendManager<AuthorizationCodeFlowPKCEProxyBackend>>.self,
                from: encoded
            )
            Self.spotify = decoded
            Self.spotify.authorizationManager.backend.decodeServerError =
                    VaporServerError.decodeFromNetworkResponse(data:response:)

        } catch {
            fatalError("\(error)")
        }

    }

}
