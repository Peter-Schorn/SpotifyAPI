import Foundation
import Combine
import XCTest
import SpotifyWebAPI

/// The base class for all tests involving
/// `SpotifyAPI<AuthorizationCodeFlowManager>`.
class SpotifyAPIAuthorizationCodeFlowTests: XCTestCase {
    
    static let spotify = SpotifyAPI<AuthorizationCodeFlowManager>.shared
    static var cancellables: Set<AnyCancellable> = []
    
    override class func setUp() {
        spotify.authorizeAndWaitForTokens(scopes: [])
    }

}

/// The base class for all tests involving
/// `SpotifyAPI<ClientCredentialsFlowManager>`.
class SpotifyAPIClientCredentialsFlowTests: XCTestCase {
    
    static let spotify = SpotifyAPI<ClientCredentialsFlowManager>.shared
    static var cancellables: Set<AnyCancellable> = []

    override class func setUp() {
        spotify.waitUntilAuthorized()
    }

}
