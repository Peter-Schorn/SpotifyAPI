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

public protocol SpotifyAPIAuthorizationCodeFlowPKCEAuthorizationTests: SpotifyAPITests
    where AuthorizationManager: _AuthorizationCodeFlowPKCEManagerProtool
{

    func makeFakeAuthManager() -> AuthorizationManager

}

extension SpotifyAPIAuthorizationCodeFlowPKCEAuthorizationTests {

    func deauthorizeReauthorize() {

        encodeDecode(Self.spotify.authorizationManager, areEqual: ==)

        let authorizationManagerDidChangeExpectation = XCTestExpectation(
            description: "authorizationManagerDidChange"
        )
        
        let authorizationManagerDidDeauthorizeExpectation = XCTestExpectation(
            description: "authorizationManagerDidDeauthorize"
        )

        let internalQueue = DispatchQueue(label: "internal")
        var cancellables: Set<AnyCancellable> = []
        
        var didChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didChangeCount += 1
                internalQueue.asyncAfter(deadline: .now() + 2) {
                    authorizationManagerDidChangeExpectation.fulfill()
                }
            })
            .store(in: &cancellables)

        var didDeauthorizeCount = 0
        Self.spotify.authorizationManagerDidDeauthorize
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didDeauthorizeCount += 1
                internalQueue.asyncAfter(deadline: .now() + 2) {
                    authorizationManagerDidDeauthorizeExpectation.fulfill()
                }
            })
            .store(in: &cancellables)

        let currentScopes = Self.spotify.authorizationManager.scopes

        Self.spotify.authorizationManager.deauthorize()

        self.wait(
            for: [
                authorizationManagerDidDeauthorizeExpectation
            ],
            timeout: 10
        )

        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 0,
                "authorizationManagerDidChange should not emit"
            )
            XCTAssertEqual(
                didDeauthorizeCount, 1,
                "authorizationManagerDidDeauthorize should only emit once"
                
            )
        }

        XCTAssertEqual(Self.spotify.authorizationManager.scopes, [])
        XCTAssertFalse(Self.spotify.authorizationManager.isAuthorized(for: []))

        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: currentScopes,
            showDialog: false
        )

        XCTAssertTrue(
            Self.spotify.authorizationManager.isAuthorized(for: currentScopes),
            "\(Self.spotify.authorizationManager.scopes)"
        )
        XCTAssertEqual(Self.spotify.authorizationManager.scopes , currentScopes)
        XCTAssertFalse(
            Self.spotify.authorizationManager.accessTokenIsExpired(tolerance: 0)
        )

        self.wait(
            for: [
                authorizationManagerDidChangeExpectation
            ],
            timeout: 10
        )

        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 1,
                "authorizationManagerDidChange should only emit once"
            )
            XCTAssertEqual(
                didDeauthorizeCount, 1,
                "authorizationManagerDidDeauthorize should only emit once"
                
            )
        }

        encodeDecode(Self.spotify.authorizationManager, areEqual: ==)

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

        Self.spotify.authorizationManager = self.makeFakeAuthManager()

        Self.spotify.authorizationManager = currentAuthManager

        XCTAssertEqual(didChangeCount, 2)
        XCTAssertEqual(didDeauthorizeCount, 0)

        self.deauthorizeReauthorize()

    }

    /// Test authorizing with an invalid client id.
    func invalidCredentials() {

        let codeVerifier = String.randomURLSafe(length: 100)
        let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)

        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            codeChallenge: codeChallenge,
            state: nil,
            scopes: []
        )!

        guard let redirectURI = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        ) else {
            XCTFail("couldn't get redirectURI")
            return
        }

        let authorizationManager = self.makeFakeAuthManager()

        let expectation = XCTestExpectation(
            description: "invalidCredentials"
        )

        authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURI,
            codeVerifier: codeVerifier,
            state: nil
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

        func receiveCompletion(
            _ completion: Subscribers.Completion<Error>
        ) {
            defer { expectation.fulfill() }
            guard case .failure(let error) = completion else {
                XCTFail("should not finish normally")
                return
            }
            
            if Self.spotify.authorizationManager is
                    AuthorizationCodeFlowPKCEManager {
                guard let authError = error as? SpotifyAuthenticationError else {
                    XCTFail("unexpected error: \(error)")
                    return
                }
                XCTAssertEqual(authError.error, "invalid_grant")
                XCTAssertEqual(authError.errorDescription, "Invalid refresh token")
            }
            else {
                guard let vaporError = error as? VaporServerError else {
                    XCTFail("unexpected error: \(error)")
                    return
                }
                XCTAssertEqual(vaporError.reason, "Bad Request")
                XCTAssertEqual(vaporError.error, true)
            }
        }

        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: [],
            showDialog: false
        )

        // make the refresh token invalid
        Self.spotify.authorizationManager._refreshToken = "invalidtoken"

        let expectation = XCTestExpectation(
            description: "refreshWithInvalidRefreshToken"
        )

        Self.spotify.authorizationManager.refreshTokens(
            onlyIfExpired: false, tolerance: 120
        )
        .sink(
            receiveCompletion: receiveCompletion(_:),
            receiveValue: {
                XCTFail("should not receive value")
            }

        )
        .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 120)

    }

    /// No state provided when making the authorization URL; state provided
    /// when requesting the access and refresh tokens. Correct code challenge
    /// and code verifier.
    func invalidState1() {

        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)

        let requestedScopes = Set(Scope.allCases.shuffled().prefix(5))
        let codeVerifier = String.randomURLSafe(length: 128)
        let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)

        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            codeChallenge: codeChallenge,
            state: nil,
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

        XCTAssertNil(queryDict["state"])
        XCTAssertEqual(queryDict["code_challenge"], codeChallenge)

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
            redirectURIWithQuery: redirectURL,
            codeVerifier: codeVerifier,
            state: state
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
                XCTFail("error should be SpotifyLocalError: \(error)")
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
    /// when requesting the access and refresh tokens. Correct code challenge
    /// and code verifier.
    func invalidState2() {

        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)

        let requestedScopes = Set(Scope.allCases.shuffled().prefix(5))
        let codeVerifier = String.randomURLSafe(length: 128)
        let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)
        let authorizationState = String.randomURLSafe(length: 128)

        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            codeChallenge: codeChallenge,
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

        XCTAssertEqual(queryDict["state"], authorizationState)
        XCTAssertEqual(queryDict["code_challenge"], codeChallenge)

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
            redirectURIWithQuery: redirectURL,
            codeVerifier: codeVerifier,
            state: nil
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
                XCTFail("error should be SpotifyLocalError: \(error)")
                return
            }
            print(localError)
            guard case .invalidState(let supplied, let received) = localError else {
                XCTFail("case should be invalidState: \(localError)")
                return
            }
            XCTAssertNil(supplied)
            XCTAssertEqual(received, authorizationState)

        })
        .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)
        XCTAssertEqual(didChangeCount, 0)

    }

    /// State provided when making the authorization URL did not match the state
    /// provided when requesting the access and refresh tokens. Correct code
    /// challenge and code verifier.
    func invalidState3() {

        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)

        let requestedScopes = Set(Scope.allCases.shuffled().prefix(5))
        let codeVerifier = String.randomURLSafe(length: 128)
        let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)
        let authorizationState = String.randomURLSafe(length: 100)

        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            codeChallenge: codeChallenge,
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

        XCTAssertEqual(queryDict["state"], authorizationState)
        XCTAssertEqual(queryDict["code_challenge"], codeChallenge)

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
            redirectURIWithQuery: redirectURL,
            codeVerifier: codeVerifier,
            state: tokensState
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
                XCTFail("error should be SpotifyLocalError: \(error)")
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

        let codeVerifier = String.randomURLSafe(length: 44)
        let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)

        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            codeChallenge: codeChallenge,
            state: nil,
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
            redirectURIWithQuery: invalidRedirectURI,
            codeVerifier: codeVerifier,
            state: nil
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
                XCTFail("error should be SpotifyAuthenticationError: \(error)")
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

    /// Matching state parameters supplied, but code verifier is invalid.
    func invalidCodeVerifier() {

        let logLevel = spotifyDecodeLogger.logLevel
        spotifyDecodeLogger.logLevel = .trace

        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)

        let requestedScopes = Set(Scope.allCases.shuffled().prefix(5))
        let codeVerifier = String.randomURLSafe(length: 128)
        let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)
        let state = String.randomURLSafe(length: 128)

        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            codeChallenge: codeChallenge,
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

        XCTAssertEqual(queryDict["state"], state)
        XCTAssertEqual(queryDict["code_challenge"], codeChallenge)

        guard let redirectURL = openAuthorizationURLAndWaitForRedirect(
            authorizationURL
        ) else {
            XCTFail("redirect URL should not be nil")
            return
        }

        let expectation = XCTestExpectation(
            description: "testInvalidState: code verifier doesn't match " +
                         "code challenge"
        )

        Self.spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURL,
            codeVerifier: "invalid_code_verifier_invalid_code_verifier_invalid",
            state: state
        )
        .sink(receiveCompletion: { completion in

            defer { expectation.fulfill() }

            guard case .failure(let error) = completion else {
                XCTFail(
                    "publisher should fail with SpotifyAuthenticationError"
                )
                return
            }
            guard let authenticationError = error as? SpotifyAuthenticationError else {
                XCTFail("error should be SpotifyAuthenticationError: \(error)")
                return
            }
            encodeDecode(authenticationError, areEqual: ==)
            print(authenticationError)

            XCTAssertEqual(authenticationError.error, "invalid_grant")
            XCTAssertEqual(
                authenticationError.errorDescription,
                "code_verifier was incorrect"
            )

        })
        .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 300)
        XCTAssertEqual(didChangeCount, 0)

        spotifyDecodeLogger.logLevel = logLevel

    }

    func invalidRedirectURI() {

        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange.sink(receiveValue: {
            didChangeCount += 1
        })
        .store(in: &cancellables)

        let codeVerifier = String.randomURLSafe(length: 44)
        let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)

        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            codeChallenge: codeChallenge,
            state: nil,
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
            redirectURIWithQuery: invalidRedirectURI,
            codeVerifier: codeVerifier,
            state: nil
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
                XCTFail("error should be SpotifyAuthenticationError: \(error)")
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

final class SpotifyAPIAuthorizationCodeFlowPKCEClientAuthorizationTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIAuthorizationCodeFlowPKCEAuthorizationTests
{

    static let allTests = [
        ("testDeauthorizeReauthorize", testDeauthorizeReauthorize),
        ("testCodingSpotifyAPI", testCodingSpotifyAPI),
        ("testReassigningAuthorizationManager", testReassigningAuthorizationManager),
        ("testInvalidCredentials", testInvalidCredentials),
        ("testRefreshWithInvalidRefreshToken", testRefreshWithInvalidRefreshToken),
        ("testConvenienceInitializer", testConvenienceInitializer),
        ("testInvalidState1", testInvalidState1),
        ("testInvalidState2", testInvalidState2),
        ("testInvalidState3", testInvalidState3),
        ("testInvalidCodeVerifier", testInvalidCodeVerifier),
        ("testInvalidRedirectURI", testInvalidRedirectURI),
        ("testInvalidCode", testInvalidCode)
    ]

    override class func setupAuthorization(scopes: Set<Scope> = Scope.allCases) {

    }

    func makeFakeAuthManager() -> AuthorizationCodeFlowPKCEManager{
        return AuthorizationCodeFlowPKCEManager(
            clientId: ""
        )
    }

    func testDeauthorizeReauthorize() { deauthorizeReauthorize() }

    func testCodingSpotifyAPI() throws {
        let spotifyAPIData = try JSONEncoder().encode(Self.spotify)
        
        let decodedSpotifyAPI = try JSONDecoder().decode(
            SpotifyAPI<AuthorizationManager>.self,
            from: spotifyAPIData
        )
        
        Self.spotify = decodedSpotifyAPI
        
        self.deauthorizeReauthorize()
    }

    func testReassigningAuthorizationManager() { reassigningAuthorizationManager() }

    func testInvalidCredentials() { invalidCredentials() }

    func testRefreshWithInvalidRefreshToken() { refreshWithInvalidRefreshToken() }

    func testConvenienceInitializer() throws {

        Self.spotify.authorizationManager.authorizeAndWaitForTokens()

        let authManagerData = try JSONEncoder().encode(
            Self.spotify.authorizationManager
        )

        let decodedAuthManager = try JSONDecoder().decode(
            AuthorizationCodeFlowPKCEManager.self,
            from: authManagerData
        )

        guard
            let accessToken = decodedAuthManager.accessToken,
            let expirationDate = decodedAuthManager.expirationDate,
            let refreshToken = decodedAuthManager.refreshToken
        else {
            XCTFail("none of the properties should be nil: \(decodedAuthManager)")
            return
        }


        let backend = AuthorizationCodeFlowPKCEClientBackend(
            clientId: decodedAuthManager.backend.clientId
        )

        let newAuthorizationManager = AuthorizationCodeFlowPKCEManager(
            backend: backend,
            accessToken: accessToken,
            expirationDate: expirationDate,
            refreshToken: refreshToken,
            scopes: decodedAuthManager.scopes
        )

        XCTAssertEqual(Self.spotify.authorizationManager, newAuthorizationManager)
        
        self.deauthorizeReauthorize()

    }

    /// No state provided when making the authorization URL; state provided
    /// when requesting the access and refresh tokens. Correct code challenge
    /// and code verifier.
    func testInvalidState1() { invalidState1() }

    /// State provided when making the authorization URL, but no state provided
    /// when requesting the access and refresh tokens. Correct code challenge
    /// and code verifier.
    func testInvalidState2() { invalidState2() }

    /// State provided when making the authorization URL did not match the state
    /// provided when requesting the access and refresh tokens. Correct code
    /// challenge and code verifier.
    func testInvalidState3() {invalidState3() }

    /// Matching state parameters supplied, but code verifier is invalid.
    func testInvalidCodeVerifier() { invalidCodeVerifier() }

    func testInvalidRedirectURI() { invalidRedirectURI() }

    func testInvalidCode() { invalidCode() }

    override class func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }

}

// MARK: - Proxy -

final class SpotifyAPIAuthorizationCodeFlowPKCEProxyAuthorizationTests:
    SpotifyAPIAuthorizationCodeFlowPKCEProxyTests, SpotifyAPIAuthorizationCodeFlowPKCEAuthorizationTests
{

    static let allTests = [
        ("testDeauthorizeReauthorize", testDeauthorizeReauthorize),
        ("testCodingSpotifyAPI", testCodingSpotifyAPI),
        ("testReassigningAuthorizationManager", testReassigningAuthorizationManager),
        ("testRefreshWithInvalidRefreshToken", testRefreshWithInvalidRefreshToken),
        ("testConvenienceInitializer", testConvenienceInitializer),
        ("testInvalidState1", testInvalidState1),
        ("testInvalidState2", testInvalidState2),
        ("testInvalidState3", testInvalidState3),
        ("testInvalidCodeVerifier", testInvalidCodeVerifier),
        ("testInvalidCode", testInvalidCode)
    ]

    override class func setupAuthorization(scopes: Set<Scope> = Scope.allCases) {

    }

    func makeFakeAuthManager() -> AuthorizationCodeFlowPKCEBackendManager<AuthorizationCodeFlowPKCEProxyBackend> {
        return AuthorizationCodeFlowPKCEBackendManager(
            backend: AuthorizationCodeFlowPKCEProxyBackend(
                clientId: "",
                tokensURL: authorizationCodeFlowPKCETokensURL,
                tokenRefreshURL: authorizationCodeFlowPKCERefreshTokensURL
            )
        )
    }

    func testDeauthorizeReauthorize() { deauthorizeReauthorize() }

    func testCodingSpotifyAPI() throws {
        let decodeServerError = Self.spotify.authorizationManager
            .backend.decodeServerError
        let spotifyAPIData = try JSONEncoder().encode(Self.spotify)
        
        let decodedSpotifyAPI = try JSONDecoder().decode(
            SpotifyAPI<AuthorizationManager>.self,
            from: spotifyAPIData
        )
        
        Self.spotify = decodedSpotifyAPI
        Self.spotify.authorizationManager.backend.decodeServerError =
            decodeServerError
        
        self.deauthorizeReauthorize()
    }

    func testReassigningAuthorizationManager() { reassigningAuthorizationManager() }

    func testRefreshWithInvalidRefreshToken() { refreshWithInvalidRefreshToken() }

    func testConvenienceInitializer() throws {

        Self.spotify.authorizationManager.authorizeAndWaitForTokens()

        let authManagerData = try JSONEncoder().encode(
            Self.spotify.authorizationManager
        )

        let decodedAuthManager = try JSONDecoder().decode(
            AuthorizationCodeFlowPKCEBackendManager<AuthorizationCodeFlowPKCEProxyBackend>.self,
            from: authManagerData
        )

        guard
            let accessToken = decodedAuthManager.accessToken,
            let expirationDate = decodedAuthManager.expirationDate,
            let refreshToken = decodedAuthManager.refreshToken
        else {
            XCTFail("none of the properties should be nil: \(decodedAuthManager)")
            return
        }

        let backend = AuthorizationCodeFlowPKCEProxyBackend(
            clientId: decodedAuthManager.backend.clientId,
            tokensURL: decodedAuthManager.backend.tokensURL,
            tokenRefreshURL: decodedAuthManager.backend.tokenRefreshURL,
            decodeServerError: decodedAuthManager.backend.decodeServerError
        )

        let newAuthorizationManager = AuthorizationCodeFlowPKCEBackendManager(
            backend: backend,
            accessToken: accessToken,
            expirationDate: expirationDate,
            refreshToken: refreshToken,
            scopes: decodedAuthManager.scopes
        )

        XCTAssertEqual(Self.spotify.authorizationManager, newAuthorizationManager)
        
        self.deauthorizeReauthorize()

    }

    /// No state provided when making the authorization URL; state provided
    /// when requesting the access and refresh tokens. Correct code challenge
    /// and code verifier.
    func testInvalidState1() { invalidState1() }

    /// State provided when making the authorization URL, but no state provided
    /// when requesting the access and refresh tokens. Correct code challenge
    /// and code verifier.
    func testInvalidState2() { invalidState2() }

    /// State provided when making the authorization URL did not match the state
    /// provided when requesting the access and refresh tokens. Correct code
    /// challenge and code verifier.
    func testInvalidState3() {invalidState3() }

    /// Matching state parameters supplied, but code verifier is invalid.
    func testInvalidCodeVerifier() { invalidCodeVerifier() }

    func testInvalidCode() { invalidCode() }

    override class func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }

}
