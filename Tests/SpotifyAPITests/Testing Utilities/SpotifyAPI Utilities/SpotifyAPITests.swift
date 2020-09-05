import Foundation
import XCTest
import Combine
@testable import SpotifyWebAPI

protocol SpotifyAPITests: XCTestCase {
    
    associatedtype AuthorizationManager: SpotifyAuthorizationManager
    
    static var spotify: SpotifyAPI<AuthorizationManager> { get }
    static var cancellables: Set<AnyCancellable> { get set }
}
