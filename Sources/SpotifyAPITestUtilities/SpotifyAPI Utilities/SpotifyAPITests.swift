import Foundation
import XCTest
import Combine
@testable import SpotifyWebAPI

/// The base protocol that all tests involving `SpotifyAPI` inherit from.
public protocol SpotifyAPITests: XCTestCase {
    
    associatedtype AuthorizationManager: SpotifyAuthorizationManager
    
    static var spotify: SpotifyAPI<AuthorizationManager> { get }
    static var cancellables: Set<AnyCancellable> { get set }
    
}

public extension SpotifyAPITests {
    
    static func setUpDebugging() {
        spotify.setupDebugging()
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
