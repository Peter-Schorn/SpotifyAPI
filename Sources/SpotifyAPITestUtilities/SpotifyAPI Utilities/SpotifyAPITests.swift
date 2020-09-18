#if canImport(XCTest)
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
#endif
