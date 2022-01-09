
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import XCTest
import SpotifyWebAPI

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - Client -

/// The base class for all tests involving
/// `SpotifyAPI<ClientCredentialsFlowManager>`.
open class SpotifyAPIClientCredentialsFlowTests:
    SpotifyAPITestCase, SpotifyAPITests
{
    
    public static var spotify =
            SpotifyAPI<ClientCredentialsFlowManager>.sharedTest
    
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
                SpotifyAPI<ClientCredentialsFlowManager>.self,
                from: encoded
            )
            Self.spotify = decoded
        
        } catch {
            fatalError("\(error)")
        }
        
    }

}


/// The base class for all tests involving
/// `SpotifyAPI<AuthorizationCodeFlowManager<AuthorizationCodeFlowClientBackend>>`.
open class SpotifyAPIAuthorizationCodeFlowTests:
    SpotifyAPITestCase, SpotifyAPITests
{

    public static var spotify =
            SpotifyAPI<AuthorizationCodeFlowManager>.sharedTest
    
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
                SpotifyAPI<AuthorizationCodeFlowManager>.self,
                from: encoded
            )
            Self.spotify = decoded
        
        } catch {
            fatalError("\(error)")
        }
        
    }
    

}

/// The base class for all tests involving
/// `SpotifyAPI<AuthorizationCodeFlowPKCEManager<AuthorizationCodeFlowPKCEClientBackend>>`.
open class SpotifyAPIAuthorizationCodeFlowPKCETests:
    SpotifyAPITestCase, SpotifyAPITests
{

    public static var spotify =
            SpotifyAPI<AuthorizationCodeFlowPKCEManager>.sharedTest
    
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
                SpotifyAPI<AuthorizationCodeFlowPKCEManager>.self,
                from: encoded
            )
            Self.spotify = decoded
        
        } catch {
            fatalError("\(error)")
        }
        
    }

}
