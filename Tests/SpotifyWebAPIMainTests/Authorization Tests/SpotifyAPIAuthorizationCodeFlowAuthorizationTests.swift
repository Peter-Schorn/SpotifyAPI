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

public protocol SpotifyAPIAuthorizationCodeFlowAuthorizationTests: AuthorizationCodeFlowTestsProtocol {
    
    func makeNewFakeAuthManager() -> AuthorizationCodeFlowManager<Backend>

    
}

extension SpotifyAPIAuthorizationCodeFlowAuthorizationTests where AuthorizationManager: Equatable {
    
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
        
        let currentScopes = Self.spotify.authorizationManager.scopes ?? []
        
        Self.spotify.authorizationManager.deauthorize()
            
        XCTAssertNil(Self.spotify.authorizationManager.scopes)
        XCTAssertFalse(Self.spotify.authorizationManager.isAuthorized(for: []))
        
        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: currentScopes, showDialog: false
        )
        
        XCTAssertTrue(
            Self.spotify.authorizationManager.isAuthorized(for: currentScopes),
            "\(Self.spotify.authorizationManager.scopes ?? [])"
        )
        XCTAssertEqual(Self.spotify.authorizationManager.scopes ?? [], currentScopes)
        XCTAssertFalse(
            Self.spotify.authorizationManager.accessTokenIsExpired(tolerance: 0)
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
    
    func codingSpotifyAPI() throws {
        
        let spotifyAPIData = try JSONEncoder().encode(Self.spotify)
        
        let decodedSpotifyAPI = try JSONDecoder().decode(
            SpotifyAPI<AuthorizationCodeFlowManager<Backend>>.self,
            from: spotifyAPIData
        )
        
        Self.spotify = decodedSpotifyAPI
        
        self.deauthorizeReauthorize()
        
    }
     
    func reassigningAuthorizationManager() {
        
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
        
        let currentAuthManager = Self.spotify.authorizationManager
        
        Self.spotify.authorizationManager = self.makeNewFakeAuthManager()

        Self.spotify.authorizationManager = currentAuthManager
        
        XCTAssertEqual(didChangeCount, 2)
        XCTAssertEqual(didDeauthorizeCount, 0)
        
        self.deauthorizeReauthorize()
        
    }
    
    func invalidCredentials() {
        
        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            showDialog: false,
            scopes: []
        )!
        
        guard let redirectURI = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        ) else {
            XCTFail("couldn't get redirectURI")
            return
        }
        
        let authorizationManager = self.makeNewFakeAuthManager()
        
        let expectation = XCTestExpectation(
            description: "invalidCredentials"
        )

        authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURI
        )
        .sink(
            receiveCompletion: { completion in
                defer { expectation.fulfill() }
                guard case .failure(let error) = completion else {
                    XCTFail("should not complete normally")
                    return
                }
                guard let authError = error as? SpotifyAuthenticationError else {
                    XCTFail("unexpected error: \(error)")
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

    func refreshWithInvalidRefreshToken() {
        
        Self.spotify.authorizationManager.authorizeAndWaitForTokens(scopes: [])
        
        Self.spotify.authorizationManager._refreshToken = "invalid token"
        
        let expectation = XCTestExpectation(
            description: "refreshWithInvalidRefreshToken"
        )

        Self.spotify.authorizationManager.refreshTokens(
            onlyIfExpired: false
        )
        .sink(
            receiveCompletion: { completion in
                defer { expectation.fulfill() }
                guard case .failure(let error) = completion else {
                    XCTFail("should not finish normally")
                    return
                }
                guard let authError = error as? SpotifyAuthenticationError else {
                    XCTFail("unexpected error: \(error)")
                    return
                }
                XCTAssertEqual(authError.error, "invalid_grant")
                XCTAssertEqual(authError.errorDescription, "Invalid refresh token")
            },
            receiveValue: {
                XCTFail("should not receive value")
            }

        )
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }

    /// No state provided when making the authorization URL; state provided
    /// when requesting the access and refresh tokens.
    func invalidState1() {
        
        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)
        
        let requestedScopes = Set(Scope.allCases.shuffled().prefix(5))
        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            showDialog: false,
            scopes: requestedScopes
        )!
        
        let queryDict = authorizationURL.queryItemsDict
        guard let scopesString = queryDict["scope"] else {
            XCTFail("Couldn't find 'scope' in query string: '\(authorizationURL)'")
            return
        }
        let scopesFromQuery = Scope.makeSet(scopesString)
        XCTAssertEqual(requestedScopes, scopesFromQuery)
        
        if let redirectURI = queryDict["redirect_uri"],
               let url = URL(string: redirectURI) {
            XCTAssertEqual(localHostURL, url)
        }
        else {
            XCTFail("couldn't find redirect_uri in query string")
        }
        
        XCTAssertEqual(queryDict["show_dialog"], "false")
        XCTAssertNil(queryDict["state"])
        
        guard let redirectURL = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        ) else {
            XCTFail("redirect URL should not be nil")
            return
        }
        
        let expectation = XCTestExpectation(
            description: "testInvalidState: no state when making authorization URL"
        )
        
        let state = String.randomURLSafe(length: 100)
        Self.spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURL, state: state
        )
        .sink(receiveCompletion: { completion in
            
            defer { expectation.fulfill() }

            guard case .failure(let error) = completion else {
                XCTFail(
                    "publisher should fail with SpotifyLocalError.invalidState"
                )
                return
            }
            guard let localError = error as? SpotifyLocalError else {
                XCTFail("error should be SpotifyLocalError")
                return
            }
            print(localError)
            guard case .invalidState(let supplied, let received) = localError else {
                XCTFail("case should be invalidState: \(localError)")
                return
            }
            XCTAssertEqual(supplied, state)
            XCTAssertNil(received)
            
        })
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 300)
        XCTAssertEqual(didChangeCount, 0)
            
    }
    
    /// State provided when making the authorization URL, but no state provided
    /// when requesting the access and refresh tokens.
    func invalidState2() {
     
        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)
        
        let requestedScopes = Set(Scope.allCases.shuffled().prefix(5))
        let state = String.randomURLSafe(length: 100)
        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            showDialog: false,
            state: state,
            scopes: requestedScopes
        )!
        
        let queryDict = authorizationURL.queryItemsDict
        guard let scopesString = queryDict["scope"] else {
            XCTFail("Couldn't find 'scope' in query string: '\(authorizationURL)'")
            return
        }
        let scopesFromQuery = Scope.makeSet(scopesString)
        XCTAssertEqual(requestedScopes, scopesFromQuery)
        
        if let redirectURI = queryDict["redirect_uri"],
               let url = URL(string: redirectURI) {
            XCTAssertEqual(localHostURL, url)
        }
        else {
            XCTFail("couldn't find redirect_uri in query string")
        }
        
        XCTAssertEqual(queryDict["show_dialog"], "false")
        XCTAssertEqual(queryDict["state"], state)
        
        guard let redirectURL = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        ) else {
            XCTFail("redirect URL should not be nil")
            return
        }
        
        let expectation = XCTestExpectation(
            description: "testInvalidState: no state when requesting access " +
                         "and refresh tokens"
        )
        
        Self.spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURL
        )
        .sink(receiveCompletion: { completion in
            
            defer { expectation.fulfill() }

            guard case .failure(let error) = completion else {
                XCTFail(
                    "publisher should fail with SpotifyLocalError.invalidState"
                )
                return
            }
            guard let localError = error as? SpotifyLocalError else {
                XCTFail("error should be SpotifyLocalError")
                return
            }
            print(localError)
            guard case .invalidState(let supplied, let received) = localError else {
                XCTFail("case should be invalidState: \(localError)")
                return
            }
            XCTAssertNil(supplied)
            XCTAssertEqual(received, state)
            
        })
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 300)
        XCTAssertEqual(didChangeCount, 0)
        
    }
    
    /// State provided when making the authorization URL did not match the state
    /// provided when requesting the access and refresh tokens.
    func invalidState3() {
        
        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)
        
        let requestedScopes = Set(Scope.allCases.shuffled().prefix(5))
        let authorizationState = String.randomURLSafe(length: 100)
        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            showDialog: false,
            state: authorizationState,
            scopes: requestedScopes
        )!
        
        let queryDict = authorizationURL.queryItemsDict
        guard let scopesString = queryDict["scope"] else {
            XCTFail("Couldn't find 'scope' in query string: '\(authorizationURL)'")
            return
        }
        let scopesFromQuery = Scope.makeSet(scopesString)
        XCTAssertEqual(requestedScopes, scopesFromQuery)
        
        if let redirectURI = queryDict["redirect_uri"],
               let url = URL(string: redirectURI) {
            XCTAssertEqual(localHostURL, url)
        }
        else {
            XCTFail("couldn't find redirect_uri in query string")
        }
        
        XCTAssertEqual(queryDict["show_dialog"], "false")
        XCTAssertEqual(queryDict["state"], authorizationState)
        
        guard let redirectURL = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        ) else {
            XCTFail("redirect URL should not be nil")
            return
        }
        
        let expectation = XCTestExpectation(
            description: "testInvalidState: different state"
        )
        
        let tokensState = String.randomURLSafe(length: 100)
        precondition(tokensState != authorizationState)
        
        Self.spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURL, state: tokensState
        )
        .sink(receiveCompletion: { completion in
            
            defer { expectation.fulfill() }

            guard case .failure(let error) = completion else {
                XCTFail(
                    "publisher should fail with SpotifyLocalError.invalidState"
                )
                return
            }
            guard let localError = error as? SpotifyLocalError else {
                XCTFail("error should be SpotifyLocalError")
                return
            }
            print(localError)
            guard case .invalidState(let supplied, let received) = localError else {
                XCTFail("case should be invalidState: \(localError)")
                return
            }
            XCTAssertEqual(supplied, tokensState)
            XCTAssertEqual(received, authorizationState)
            
        })
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 300)
        XCTAssertEqual(didChangeCount, 0)

    }

    func invalidCode() {
        
        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)
        
        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            showDialog: false,
            scopes: []
        )!
        
        guard let redirectURL = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        ) else {
            XCTFail("redirect URL should not be nil")
            return
        }
        
        let expectation = XCTestExpectation(
            description: "testInvalidCode"
        )
        
        var invalidRedirectURIComponents = redirectURL.components!
        invalidRedirectURIComponents.queryItemsDict["code"] = "invalidcode"

        guard let invalidRedirectURI = invalidRedirectURIComponents.url else {
            XCTFail("could not create invalidRedirectURI from: \(redirectURL)")
            return
        }

        Self.spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: invalidRedirectURI
        )
        .sink(receiveCompletion: { completion in
            
            defer { expectation.fulfill() }

            guard case .failure(let error) = completion else {
                XCTFail(
                    "publisher should fail with SpotifyAuthenticationError"
                )
                return
            }
            guard let authError = error as? SpotifyAuthenticationError else {
                XCTFail("error should be SpotifyAuthenticationError")
                return
            }
            encodeDecode(authError, areEqual: ==)
            XCTAssertEqual(authError.error, "invalid_grant")
            XCTAssertEqual(authError.errorDescription, "Invalid authorization code")
            print(authError)
            
            
        })
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 300)
        XCTAssertEqual(didChangeCount, 0)

    }

    func invalidRedirectURI() {
        
        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)
        
        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            showDialog: false,
            scopes: []
        )!
        
        guard let redirectURL = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        ) else {
            XCTFail("redirect URL should not be nil")
            return
        }
        
        let expectation = XCTestExpectation(
            description: "testInvalidRedirectURI"
        )
        
        guard let invalidRedirectURI = URL(
            scheme: "https",
            host: "www.google.com",
            queryString: redirectURL.query
        ) else {
            XCTFail("couldn't create invalidRedirectURI from: \(redirectURL)")
            return
        }

        Self.spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: invalidRedirectURI
        )
        .sink(receiveCompletion: { completion in
            
            defer { expectation.fulfill() }

            guard case .failure(let error) = completion else {
                XCTFail(
                    "publisher should fail with SpotifyAuthenticationError"
                )
                return
            }
            guard let authError = error as? SpotifyAuthenticationError else {
                XCTFail("error should be SpotifyAuthenticationError")
                return
            }
            encodeDecode(authError, areEqual: ==)
            XCTAssertEqual(authError.error, "invalid_grant")
            XCTAssertEqual(authError.errorDescription, "Invalid redirect URI")
            print(authError)
            
            
        })
        .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 300)
        XCTAssertEqual(didChangeCount, 0)

    }

}

// MARK: - Client -

final class SpotifyAPIAuthorizationCodeFlowClientAuthorizationTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIAuthorizationCodeFlowAuthorizationTests
{

    static var allTests = [
        ("testDeauthorizeReauthorize", testDeauthorizeReauthorize),
        ("testCodingSpotifyAPI", testCodingSpotifyAPI),
        ("testReassigningAuthorizationManager", testReassigningAuthorizationManager),
        ("testInvalidCredentials", testInvalidCredentials),
        ("testConvenienceInitializer", testConvenienceInitializer),
        ("testRefreshWithInvalidRefreshToken", testRefreshWithInvalidRefreshToken),
        ("testInvalidState1", testInvalidState1),
        ("testInvalidState2", testInvalidState2),
        ("testInvalidState3", testInvalidState3),
        ("testInvalidRedirectURI", testInvalidRedirectURI),
        ("testInvalidCode", testInvalidCode)
    ]
    
    override class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases,
        showDialog: Bool = false
    ) {
        
    }

    func makeNewFakeAuthManager() -> AuthorizationCodeFlowManager<AuthorizationCodeFlowClientBackend> {
        return AuthorizationCodeFlowManager(
            backend: AuthorizationCodeFlowClientBackend(
                clientId: "",
                clientSecret: ""
            )
        )
    }

    func testDeauthorizeReauthorize() { deauthorizeReauthorize() }
    
    func testCodingSpotifyAPI() throws { try codingSpotifyAPI() }
     
    func testReassigningAuthorizationManager() { reassigningAuthorizationManager() }
    
    func testInvalidCredentials() { invalidCredentials() }
    
    func testRefreshWithInvalidRefreshToken() { refreshWithInvalidRefreshToken() }

    func testConvenienceInitializer() throws {
        
        Self.spotify.authorizationManager.authorizeAndWaitForTokens()

        let authManagerData = try JSONEncoder().encode(
            Self.spotify.authorizationManager
        )
        
        let decodedAuthManager = try JSONDecoder().decode(
            AuthorizationCodeFlowManager<AuthorizationCodeFlowClientBackend>.self,
            from: authManagerData
        )
        
        guard
            let accessToken = decodedAuthManager.accessToken,
            let expirationDate = decodedAuthManager.expirationDate,
            let refreshToken = decodedAuthManager.refreshToken,
            let scopes = decodedAuthManager.scopes
        else {
            XCTFail("none of the properties should be nil: \(decodedAuthManager)")
            return
        }
        
        let backend = AuthorizationCodeFlowClientBackend(
            clientId: decodedAuthManager.backend.clientId,
            clientSecret: decodedAuthManager.backend.clientSecret
        )

        let newAuthorizationManager = AuthorizationCodeFlowManager(
            backend: backend,
            accessToken: accessToken,
            expirationDate: expirationDate,
            refreshToken: refreshToken,
            scopes: scopes
        )
        
        XCTAssertEqual(Self.spotify.authorizationManager, newAuthorizationManager)

    }
    
    /// No state provided when making the authorization URL; state provided
    /// when requesting the access and refresh tokens.
    func testInvalidState1() { invalidState1() }
    
    /// State provided when making the authorization URL, but no state provided
    /// when requesting the access and refresh tokens.
    func testInvalidState2() {invalidState2() }
    
    /// State provided when making the authorization URL did not match the state
    /// provided when requesting the access and refresh tokens.
    func testInvalidState3() { invalidState3() }
    
    func testInvalidRedirectURI() { invalidRedirectURI() }
    
    func testInvalidCode() { invalidCode() }

    override class func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }

}

// MARK: - Proxy -

final class SpotifyAPIAuthorizationCodeFlowProxyAuthorizationTests:
    SpotifyAPIAuthorizationCodeFlowProxyTests, SpotifyAPIAuthorizationCodeFlowAuthorizationTests
{

    static var allTests = [
        ("testDeauthorizeReauthorize", testDeauthorizeReauthorize),
        ("testCodingSpotifyAPI", testCodingSpotifyAPI),
        ("testReassigningAuthorizationManager", testReassigningAuthorizationManager),
        ("testRefreshWithInvalidRefreshToken", testRefreshWithInvalidRefreshToken),
        ("testConvenienceInitializer", testConvenienceInitializer),
        ("testInvalidState1", testInvalidState1),
        ("testInvalidState2", testInvalidState2),
        ("testInvalidState3", testInvalidState3),
        ("testInvalidCode", testInvalidCode)
    ]

    override class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases,
        showDialog: Bool = false
    ) {
        
    }

    func makeNewFakeAuthManager() -> AuthorizationCodeFlowManager<AuthorizationCodeFlowProxyBackend> {
        return AuthorizationCodeFlowManager(
            backend: AuthorizationCodeFlowProxyBackend(
                clientId: "",
                tokenURL: spotifyBackendTokenURL,
                tokenRefreshURL: spotifyBackendTokenRefreshURL
            )
        )
    }

    func testDeauthorizeReauthorize() { deauthorizeReauthorize() }
    
    func testCodingSpotifyAPI() throws { try codingSpotifyAPI() }
     
    func testReassigningAuthorizationManager() { reassigningAuthorizationManager() }
    
    func testRefreshWithInvalidRefreshToken() { refreshWithInvalidRefreshToken() }

    func testConvenienceInitializer() throws {
        
        Self.spotify.authorizationManager.authorizeAndWaitForTokens()

        let authManagerData = try JSONEncoder().encode(
            Self.spotify.authorizationManager
        )
        
        let decodedAuthManager = try JSONDecoder().decode(
            AuthorizationCodeFlowManager<AuthorizationCodeFlowProxyBackend>.self,
            from: authManagerData
        )
        
        guard
            let accessToken = decodedAuthManager.accessToken,
            let expirationDate = decodedAuthManager.expirationDate,
            let refreshToken = decodedAuthManager.refreshToken,
            let scopes = decodedAuthManager.scopes
        else {
            XCTFail("none of the properties should be nil: \(decodedAuthManager)")
            return
        }
        
        let backend = AuthorizationCodeFlowProxyBackend(
            clientId: decodedAuthManager.backend.clientId,
            tokenURL: decodedAuthManager.backend.tokenURL,
            tokenRefreshURL: decodedAuthManager.backend.tokenRefreshURL
        )
//
        let newAuthorizationManager = AuthorizationCodeFlowManager(
            backend: backend,
            accessToken: accessToken,
            expirationDate: expirationDate,
            refreshToken: refreshToken,
            scopes: scopes
        )

        XCTAssertEqual(Self.spotify.authorizationManager, newAuthorizationManager)

    }
    
    /// No state provided when making the authorization URL; state provided
    /// when requesting the access and refresh tokens.
    func testInvalidState1() { invalidState1() }
    
    /// State provided when making the authorization URL, but no state provided
    /// when requesting the access and refresh tokens.
    func testInvalidState2() {invalidState2() }
    
    /// State provided when making the authorization URL did not match the state
    /// provided when requesting the access and refresh tokens.
    func testInvalidState3() { invalidState3() }
    
    func testInvalidCode() { invalidCode() }

    override class func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }

}
