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
        let environment = ProcessInfo.processInfo.environment
        if let dataDumpFolder = environment["data_dump_folder"] {
            let url = URL(fileURLWithPath: dataDumpFolder)
            SpotifyDecodingError.dataDumpfolder = url
        }
        else {
            print(
                "Couldn't find 'data_dump_folder' in environment variables"
            )
            
        }
        setupAuthorization()
    }
    
    open class func setupAuthorization() {
        spotify.authorizeAndWaitForTokens(scopes: Scope.allCases)
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
        if let dataDumpFolder = ProcessInfo.processInfo
                .environment["data_dump_folder"] {
            let url = URL(fileURLWithPath: dataDumpFolder)
            SpotifyDecodingError.dataDumpfolder = url
        }
        else {
            print("Couldn't find 'data_dump_folder' in environment variables")
        }
        
        setupAuthorization()
    }

    open class func setupAuthorization() {
        spotify.waitUntilAuthorized()
    }
    
}

