import Foundation
import XCTest
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import SpotifyAPITestUtilities
@testable import SpotifyWebAPI

protocol SpotifyAPIClientCredentialsFlowAuthorizationTests: SpotifyAPIAuthorizationTests
    where AuthorizationManager: _ClientCredentialsFlowManagerProtocol
{ }

extension SpotifyAPIClientCredentialsFlowAuthorizationTests {
    
    func deauthorizeReauthorize() {
        
        encodeDecode(Self.spotify.authorizationManager, areEqual: ==)
        
        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)

        var didDeauthorizeCount = 0
        Self.spotify.authorizationManagerDidDeauthorize
            .sink(receiveValue: {
                didDeauthorizeCount += 1
            })
            .store(in: &cancellables)
        
        let randomScope = Scope.allCases.randomElement()!
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(for: [randomScope]),
            "should not be authorized for \(randomScope.rawValue): " +
            "\(Self.spotify.authorizationManager)"
        )

        Self.spotify.authorizationManager.deauthorize()
        
        XCTAssertFalse(Self.spotify.authorizationManager.isAuthorized(for: []))
        
        Self.spotify.authorizationManager.waitUntilAuthorized()
        
        XCTAssertTrue(Self.spotify.authorizationManager.isAuthorized(for: []))
        let randomScope2 = Scope.allCases.randomElement()!
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(for: [randomScope2]),
            "should not be authorized for \(randomScope2.rawValue): " +
            "\(Self.spotify.authorizationManager)"
        )

        XCTAssertEqual(
            didChangeCount, 1,
            "authorizationManagerDidChange should only emit once"
        )
        XCTAssertEqual(
            didDeauthorizeCount, 1,
            "authorizationManagerDidDeauthorize should only emit once"
        )
        
        encodeDecode(Self.spotify.authorizationManager, areEqual: ==)
        
    }
    
    /// Test authorizing with an invalid client id and client secret
    func invalidCredentials() {

        let authorizationManager = self.makeFakeAuthManager()
        
        let expectation = XCTestExpectation(
            description: "invalidCredentials"
        )

        authorizationManager.authorize()
            .sink(
                receiveCompletion: { completion in
                    defer { expectation.fulfill() }
                    guard case .failure(let error) = completion else {
                        XCTFail("should not complete normally")
                        return
                    }
                    guard let authError = error as? SpotifyAuthenticationError else {
                        XCTFail(
                            "should've received SpotifyAuthenticationError: \(error)"
                        )
                        return
                    }
                    XCTAssertEqual(authError.error, "invalid_client")
                },
                receiveValue: {
                    XCTFail("should not receive value")
                }
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
    /// Test `refreshTokens` with an invalid client id and client secret
    func refreshTokensWithInvalidCredentials() {
        
        let authorizationManager = self.makeFakeAuthManager()
        
        let expectation = XCTestExpectation(
            description: "refreshTokensWithInvalidCredentials"
        )

        authorizationManager.refreshTokens(
            onlyIfExpired: false, tolerance: 120
        )
        .sink(
            receiveCompletion: { completion in
                defer { expectation.fulfill() }
                guard case .failure(let error) = completion else {
                    XCTFail("should not complete normally")
                    return
                }
                guard let authError = error as? SpotifyAuthenticationError else {
                    XCTFail(
                        "should've received SpotifyAuthenticationError: \(error)"
                    )
                    return
                }
                XCTAssertEqual(authError.error, "invalid_client")
            },
            receiveValue: {
                XCTFail("should not receive value")
            }
        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
}

// MARK: - Client -

final class SpotifyAPIClientCredentialsFlowClientAuthorizationTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIClientCredentialsFlowAuthorizationTests
{

    static let allTests = [
        ("testConvenienceInitializer", testConvenienceInitializer),
        ("testDeauthorizeReauthorize", testDeauthorizeReauthorize),
        ("testReassigningAuthorizationManager", testReassigningAuthorizationManager),
        ("testInvalidCredentials", testInvalidCredentials),
        ("testRefreshTokens", testRefreshTokens),
        ("testRefreshTokensWithInvalidCredentials", testRefreshTokensWithInvalidCredentials)
    ]

    override class func setupAuthorization() {
        Self.spotify.authorizationManager.deauthorize()
    }

    func makeFakeAuthManager() -> ClientCredentialsFlowManager {
        return ClientCredentialsFlowManager(
            clientId: "",
            clientSecret: ""
        )
    }

    func testConvenienceInitializer() throws {
        
        Self.spotify.authorizationManager.waitUntilAuthorized()
        
        let authManagerData = try JSONEncoder().encode(
            Self.spotify.authorizationManager
        )
        
        let decodedAuthManager = try JSONDecoder().decode(
            ClientCredentialsFlowManager.self,
            from: authManagerData
        )
        
        guard
            let accessToken = decodedAuthManager.accessToken,
            let expirationDate = decodedAuthManager.expirationDate
        else {
            XCTFail("none of the properties should be nil: \(decodedAuthManager)")
            return
        }
        
        let newAuthorizationManager = ClientCredentialsFlowManager(
            clientId: decodedAuthManager.clientId,
            clientSecret: decodedAuthManager.clientSecret,
            accessToken: accessToken,
            expirationDate: expirationDate
        )
        
        XCTAssertEqual(Self.spotify.authorizationManager, newAuthorizationManager)
        
        self.deauthorizeReauthorize()
        
    }

    func testDeauthorizeReauthorize() { deauthorizeReauthorize() }

    func testReassigningAuthorizationManager() { reassigningAuthorizationManager() }
    
    func testInvalidCredentials() { invalidCredentials() }
    
    func testRefreshTokens() { refreshTokens() }

    func testRefreshTokensWithInvalidCredentials() {
        refreshTokensWithInvalidCredentials()
    }

    override class func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }

}

// MARK: - Proxy -

final class SpotifyAPIClientCredentialsFlowProxyAuthorizationTests:
    SpotifyAPIClientCredentialsFlowProxyTests, SpotifyAPIClientCredentialsFlowAuthorizationTests
{

    static let allTests = [
        ("testConvenienceInitializer", testConvenienceInitializer),
        ("testDeauthorizeReauthorize", testDeauthorizeReauthorize),
        ("testReassigningAuthorizationManager", testReassigningAuthorizationManager),
        ("testRefreshTokens", testRefreshTokens)
    ]

    override class func setupAuthorization() {
        Self.spotify.authorizationManager.deauthorize()
    }

    func makeFakeAuthManager() -> ClientCredentialsFlowBackendManager<ClientCredentialsFlowProxyBackend> {
        return ClientCredentialsFlowBackendManager(
            backend: ClientCredentialsFlowProxyBackend(
                tokensURL: clientCredentialsFlowTokensURL
            )
        )
    }

    func testConvenienceInitializer() throws {
        
        Self.spotify.authorizationManager.waitUntilAuthorized()
        
        let authManagerData = try JSONEncoder().encode(
            Self.spotify.authorizationManager
        )
        
        let decodedAuthManager = try JSONDecoder().decode(
            ClientCredentialsFlowBackendManager<ClientCredentialsFlowProxyBackend>.self,
            from: authManagerData
        )
        
        guard
            let accessToken = decodedAuthManager.accessToken,
            let expirationDate = decodedAuthManager.expirationDate
        else {
            XCTFail("none of the properties should be nil: \(decodedAuthManager)")
            return
        }
        
        let newAuthorizationManager = ClientCredentialsFlowBackendManager(
            backend: ClientCredentialsFlowProxyBackend(
                tokensURL: clientCredentialsFlowTokensURL,
                decodeServerError: decodedAuthManager.backend.decodeServerError
            ),
            accessToken: accessToken,
            expirationDate: expirationDate
        )
        
        
        XCTAssertEqual(Self.spotify.authorizationManager, newAuthorizationManager)
        
        self.deauthorizeReauthorize()
        
    }

    func testDeauthorizeReauthorize() { deauthorizeReauthorize() }

    func testReassigningAuthorizationManager() { reassigningAuthorizationManager() }

    func testRefreshTokens() { refreshTokens() }

    override class func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }

}
