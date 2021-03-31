
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation

#endif
import XCTest
import SpotifyWebAPI

/// The base class for all tests involving
/// `SpotifyAPI<ClientCredentialsFlowManager>`.
open class SpotifyAPIClientCredentialsFlowTests: SpotifyAPITestCase, SpotifyAPITests {
    
    public static var spotify =
            SpotifyAPI<ClientCredentialsFlowManager>.sharedTest
    
    public static var cancellables: Set<AnyCancellable> = []

    /// If you only need to setup the authorization,
    /// override `setupAuthorization()` instead.
    override open class func setUp() {
        super.setUp()
        print(
            "setup debugging and authorization for " +
            "SpotifyAPIClientCredentialsFlowTests"
        )
        setUpDebugging()
        setupAuthorization()
    }

    open class func setupAuthorization() {
        if Bool.random() {
            spotify = .sharedTest
        }
        else {
            spotify = .sharedTestNetworkAdaptor
        }
        
        spotify.waitUntilAuthorized()
    }
    

}



/// The base class for all tests involving
/// `SpotifyAPI<AuthorizationCodeFlowManager>`.
open class SpotifyAPIAuthorizationCodeFlowTests: SpotifyAPITestCase, SpotifyAPITests {
    
    public static var spotify =
            SpotifyAPI<AuthorizationCodeFlowManager>.sharedTest
    
    public static var cancellables: Set<AnyCancellable> = []

    /// If you only need to setup the authorization,
    /// override `setupAuthorization()` instead.
    override open class func setUp() {
        super.setUp()
        print(
            "setup debugging and authorization for " +
            "SpotifyAPIAuthorizationCodeFlowTests"
        )
        if Bool.random() {
            spotify = .sharedTest
        }
        else {
            spotify = .sharedTestNetworkAdaptor
        }
        setUpDebugging()
        setupAuthorization()
    }

    open class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases,
        showDialog: Bool = false
    ) {

        spotify.authorizeAndWaitForTokens(
            scopes: scopes, showDialog: showDialog
        )
    }
    

}

/// The base class for all tests involving
/// `SpotifyAPI<AuthorizationCodeFlowPKCEManager>`.
open class SpotifyAPIAuthorizationCodeFlowPKCETests: SpotifyAPITestCase, SpotifyAPITests {
    
    public static var spotify =
            SpotifyAPI<AuthorizationCodeFlowPKCEManager>.sharedTest
    
    public static var cancellables: Set<AnyCancellable> = []

    /// If you only need to setup the authorization,
    /// override `setupAuthorization()` instead.
    override open class func setUp() {
        super.setUp()
        print(
            "setup debugging and authorization for " +
            "SpotifyAPIAuthorizationCodeFlowPKCETests"
        )
        if Bool.random() {
            spotify = .sharedTest
        }
        else {
            spotify = .sharedTestNetworkAdaptor
        }
        setUpDebugging()
        setupAuthorization()
    }

    open class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases
    ) {
        spotify.authorizeAndWaitForTokens(scopes: scopes)
    }
    

}
