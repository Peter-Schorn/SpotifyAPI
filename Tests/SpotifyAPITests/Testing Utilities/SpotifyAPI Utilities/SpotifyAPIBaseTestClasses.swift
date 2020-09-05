import Foundation
import Combine
import XCTest
@testable import SpotifyWebAPI

/// The base class for all tests involving
/// `SpotifyAPI<AuthorizationCodeFlowManager>`.
class SpotifyAPIAuthorizationCodeFlowTests: XCTestCase {
    
    static let spotify = SpotifyAPI<AuthorizationCodeFlowManager>.sharedTest
    static var cancellables: Set<AnyCancellable> = []
    
    override class func setUp() {
        spotify.setupDebugging()
        SpotifyDecodingError.dataDumpfolder =
                FileManager.default.homeDirectoryForCurrentUser
        setupAuthorization()
    }
    
    class func setupAuthorization() {
        spotify.authorizeAndWaitForTokens(scopes: [])
    }
    

}

/// The base class for all tests involving
/// `SpotifyAPI<ClientCredentialsFlowManager>`.
class SpotifyAPIClientCredentialsFlowTests: XCTestCase {
    
    static let spotify = SpotifyAPI<ClientCredentialsFlowManager>.sharedTest
    static var cancellables: Set<AnyCancellable> = []

    override class func setUp() {
        spotify.setupDebugging()
        SpotifyDecodingError.dataDumpfolder =
            FileManager.default.homeDirectoryForCurrentUser
        setupAuthorization()
    }

    class func setupAuthorization() {
        spotify.waitUntilAuthorized()
    }
    
}
