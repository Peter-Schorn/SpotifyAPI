import Foundation
import Combine
import XCTest
@testable import SpotifyWebAPI

/// The base class for all tests involving
/// `SpotifyAPI<AuthorizationCodeFlowManager>`.
open class SpotifyAPIAuthorizationCodeFlowTests: XCTestCase {
    
    public static let spotify =
            SpotifyAPI<AuthorizationCodeFlowManager>.sharedTest
    public static var cancellables: Set<AnyCancellable> = []

    /// If you only need to setup the authorization,
    /// override `setupAuthorization()` instead.
    override open class func setUp() {
        spotify.setupDebugging()
        #if os(macOS)
        SpotifyDecodingError.dataDumpfolder =
                FileManager.default.homeDirectoryForCurrentUser
        #endif
        setupAuthorization()
    }
    
    open class func setupAuthorization() {
        spotify.authorizeAndWaitForTokens(scopes: [])
    }
    

}

/// The base class for all tests involving
/// `SpotifyAPI<ClientCredentialsFlowManager>`.
open class SpotifyAPIClientCredentialsFlowTests: XCTestCase {
    
    public static let spotify =
            SpotifyAPI<ClientCredentialsFlowManager>.sharedTest
    public static var cancellables: Set<AnyCancellable> = []

    /// If you only need to setup the authorization,
    /// override `setupAuthorization()` instead.
    override open class func setUp() {
        spotify.setupDebugging()
        #if os(macOS)
        SpotifyDecodingError.dataDumpfolder =
                FileManager.default.homeDirectoryForCurrentUser
        #endif
        setupAuthorization()
    }

    open class func setupAuthorization() {
        spotify.waitUntilAuthorized()
    }
    
}

