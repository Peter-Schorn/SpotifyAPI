import Foundation
import XCTest
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

protocol SpotifyAPIUserProfileTests: SpotifyAPITests { }

extension SpotifyAPIUserProfileTests {
    
    func userProfile() {
        
        func receiveUser(_ user: SpotifyUser) {
            encodeDecode(user, areEqual: ==)
            XCTAssertNil(user.allowsExplicitContent)
            XCTAssertNil(user.explicitContentSettingIsLocked)
            XCTAssertEqual(user.displayName, "April")
            XCTAssertEqual(
                user.href,
                URL(string: "https://api.spotify.com/v1/users/p8gjjfbirm8ucyt82ycfi9zuu")!
            )
            XCTAssertEqual(user.id, "p8gjjfbirm8ucyt82ycfi9zuu")
            XCTAssertEqual(user.type, .user)
            XCTAssertEqual(user.uri, "spotify:user:p8gjjfbirm8ucyt82ycfi9zuu")
            
            if let externalURLs = user.externalURLs {
                XCTAssertEqual(
                    externalURLs["spotify"],
                    URL(string: "https://open.spotify.com/user/p8gjjfbirm8ucyt82ycfi9zuu")!,
                    "\(externalURLs)"
                )
            }
            else {
                XCTFail("externalURLs should not be nil")
            }

            XCTAssertNotNil(user.followers)
            
            XCTAssertImagesExist(user.images, assertSizeNotNil: false)
            
        }
        
        let expectation = XCTestExpectation(
            description: "testUserProfile"
        )
        
        Self.spotify.userProfile(URIs.Users.april)
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveUser(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

    func userProfileNonASCII() {
        
        func receiveUser(_ user: SpotifyUser) {
            XCTAssertEqual(user.displayName, "gaet ~")
            XCTAssertEqual(
                user.externalURLs?["spotify"],
                URL(string: "https://open.spotify.com/user/ga%C3%ABtan_stz")!
            )
            XCTAssertEqual(
                user.href,
                URL(string: "https://api.spotify.com/v1/users/ga%C3%ABtan_stz")!
            )
            XCTAssertEqual(user.id, "gaëtan_stz")
            XCTAssertEqual(user.type, .user)
            XCTAssertEqual(user.uri, "spotify:user:gaëtan_stz")
            encodeDecode(user, areEqual: ==)
        }

        let expectation = XCTestExpectation(
            description: "testUserProfileNonASCII"
        )
        
        Self.spotify.userProfile(URIs.Users.gaëtan_stz)
            .XCTAssertNoFailure()
            .receiveOnMain()
            .flatMap { userProfile -> AnyPublisher<SpotifyUser, Error> in
                receiveUser(userProfile)
                return Self.spotify.userProfile(userProfile)
            }
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveUser(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

}


extension SpotifyAPIUserProfileTests where
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager
{
    
    func currentUserProfile() {
        
        func receiveCurrentUserProfile(_ user: SpotifyUser) {
            encodeDecode(user, areEqual: ==)
            XCTAssertEqual(user.type, .user)
            XCTAssert(user.uri.starts(with: "spotify:user:"))
            XCTAssertNotNil(user.allowsExplicitContent)
            XCTAssertNotNil(user.explicitContentSettingIsLocked)
            do {
                let identifier = try SpotifyIdentifier(
                    uri: user.uri, ensureCategoryMatches: [.user]
                )
                XCTAssertEqual(user.id, identifier.id)
                XCTAssertEqual(user.uri, identifier.uri)
                XCTAssertEqual(identifier.idCategory, .user)
            } catch {
                XCTFail("\(error)")
            }
           
        }
        
        let expectation = XCTestExpectation(
            description: "testCurrentUserProfile"
        )
        
        Self.spotify.currentUserProfile()
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveCurrentUserProfile(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)
        
    }

}

final class SpotifyAPIClientCredentialsFlowUserProfileTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIUserProfileTests
{
    
    static let allTests = [
        ("testUserProfile", testUserProfile),
        ("testUserProfileNonASCII", testUserProfileNonASCII)
    ]
    
    func testUserProfile() { userProfile() }
    func testUserProfileNonASCII() { userProfileNonASCII() }
    
}

final class SpotifyAPIAuthorizationCodeFlowUserProfileTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIUserProfileTests
{
    
    static let allTests = [
        ("testUserProfile", testUserProfile),
        ("testUserProfileNonASCII", testUserProfileNonASCII),
        ("testCurrentUserProfile", testCurrentUserProfile)
    ]
    
    func testUserProfile() { userProfile() }
    func testUserProfileNonASCII() { userProfileNonASCII() }
    func testCurrentUserProfile() { currentUserProfile() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEUserProfileTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIUserProfileTests
{
    static let allTests = [
        ("testUserProfile", testUserProfile),
        ("testUserProfileNonASCII", testUserProfileNonASCII),
        ("testCurrentUserProfile", testCurrentUserProfile)
    ]
    
    func testUserProfile() { userProfile() }
    func testUserProfileNonASCII() { userProfileNonASCII() }
    func testCurrentUserProfile() { currentUserProfile() }
    
}
