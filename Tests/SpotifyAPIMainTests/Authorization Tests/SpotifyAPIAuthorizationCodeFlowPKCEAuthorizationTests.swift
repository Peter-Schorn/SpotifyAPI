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

protocol SpotifyAPIAuthorizationCodeFlowPKCEAuthorizationTests: SpotifyAPIAuthorizationTests
    where AuthorizationManager: _AuthorizationCodeFlowPKCEManagerProtocol
{ }

extension SpotifyAPIAuthorizationCodeFlowPKCEAuthorizationTests {

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
                    XCTFail("should've received SpotifyAuthenticationError: \(error)")
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
            
            switch error {
                case let vaporServerError as VaporServerError:
                    XCTAssertEqual(
                        vaporServerError.reason,
                        "could not decrypt refresh token"
                    )
                    XCTAssertEqual(vaporServerError.error, true)
                    if Self.spotify.authorizationManager is
                            AuthorizationCodeFlowPKCEManager {
                        XCTFail(
                            """
                            authorization code flow pkce manager should not \
                            return VaporServerError:
                            \(Self.spotify.authorizationManager)
                            """
                        )
                    }
                case let authError as SpotifyAuthenticationError:
                    XCTAssertEqual(
                        authError.error,
                        "invalid_grant"
                    )
                    XCTAssertEqual(
                        authError.errorDescription,
                        "Invalid refresh token"
                    )
                case .httpError(let data, let response) as SpotifyGeneralError:
                    if let vaporServerError = VaporServerError
                            .decodeFromNetworkResponse(
                                data: data, response: response
                            ) {
                        let dataString = String(data: data, encoding: .utf8) ?? "nil"
                        XCTFail(
                            """
                            was able to decode VaporServerError from data:
                            \(dataString)
                            \(vaporServerError)
                            """
                        )
                    }
                default:
                    XCTFail(
                        """
                        should've received SpotifyAuthenticationError, \
                        VaporServerError, or SpotifyGeneralError.httpError: \
                        \(error)
                        """
                    )
                    
            }
            
        }

        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: [], showDialog: false
        )
        
        // make the refresh token invalid
        Self.spotify.authorizationManager._refreshToken = "invalidToken"
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 3))

        let internalQueue = DispatchQueue(label: "internal")
        var cancellables: Set<AnyCancellable> = []
        
        var didChangeCount = 0
        Self.spotify.authorizationManagerDidChange
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didChangeCount += 1
            })
            .store(in: &cancellables)
        
        var didDeauthorizeCount = 0
        Self.spotify.authorizationManagerDidDeauthorize
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didDeauthorizeCount += 1
            })
            .store(in: &cancellables)

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

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 3))
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 0,
                "authorization manager should not change"
            )
            XCTAssertEqual(
                didDeauthorizeCount, 0,
                "authorization manager should not deauthorize"
            )
        }

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
                    "publisher should fail with SpotifyGeneralError.invalidState"
                )
                return
            }
            guard let localError = error as? SpotifyGeneralError else {
                XCTFail("error should be SpotifyGeneralError: \(error)")
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
                    "publisher should fail with SpotifyGeneralError.invalidState"
                )
                return
            }
            guard let localError = error as? SpotifyGeneralError else {
                XCTFail("error should be SpotifyGeneralError: \(error)")
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
                    "publisher should fail with SpotifyGeneralError.invalidState"
                )
                return
            }
            guard let localError = error as? SpotifyGeneralError else {
                XCTFail("error should be SpotifyGeneralError: \(error)")
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

    func denyAuthorizationRequest() throws {
        #if canImport(WebKit)
        
        try XCTSkipIf(
            spotifyDCCookieValue == nil,
            "Cannot test \(#function) without 'SPOTIFY_DC' environment variable."
        )

        encodeDecode(Self.spotify.authorizationManager, areEqual: ==)
        
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
        let randomScope = Scope.allCases.randomElement()!
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(for: [randomScope]),
            "should not be authorized for \(randomScope.rawValue): " +
            "\(Self.spotify.authorizationManager)"
        )
        
        // MARK: Deny Authorization
        
        let state = String.randomURLSafe(length: 20)
        let codeVerifier = String.randomURLSafe(length: 50)
        let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)

        let authorizationURL = Self.spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: localHostURL,
            codeChallenge: codeChallenge,
            state: state,
            scopes: []
        )!
        
        guard let redirectURI = openAuthorizationURLAndWaitForRedirect(
            authorizationURL, button: .cancel
        ) else {
            XCTFail("couldn't get redirectURI")
            return
        }
        
        XCTAssertEqual(redirectURI.queryItemsDict["state"], state)
        XCTAssertEqual(redirectURI.queryItemsDict["error"], "access_denied")
        
        let requestTokensExpectation = XCTestExpectation(
            description: "request tokens after denying authorization request"
        )
        
        let invalidCodeVerifier = String.randomURLSafe(length: 50)
        precondition(invalidCodeVerifier != codeVerifier)

        Self.spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: redirectURI,
            codeVerifier: invalidCodeVerifier,
            state: nil
        )
        .sink(
            receiveCompletion: { completion in
                defer { requestTokensExpectation.fulfill() }
                guard case .failure(let error) = completion else {
                    XCTFail("should not complete normally")
                    return
                }
                guard let authError = error as? SpotifyAuthorizationError else {
                    XCTFail("should've received SpotifyAuthorizationError: \(error)")
                    return
                }
                XCTAssertTrue(authError.accessWasDenied)
                XCTAssertEqual(authError.error, "access_denied")
                XCTAssertEqual(authError.state, state)
            },
            receiveValue: {
                XCTFail("should not receive value")
            }
            
        )
        .store(in: &Self.cancellables)
        
        // A network request shouldn't be made.
        self.wait(for: [requestTokensExpectation], timeout: 10)
        
        XCTAssertEqual(Self.spotify.authorizationManager.scopes, [])
        XCTAssertFalse(Self.spotify.authorizationManager.isAuthorized(for: []))
        let randomScope2 = Scope.allCases.randomElement()!
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(for: [randomScope2]),
            "should not be authorized for \(randomScope2.rawValue): " +
            "\(Self.spotify.authorizationManager)"
        )
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 3))
        
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 0,
                "authorizationManagerDidChange should NOT emit"
            )
            XCTAssertEqual(
                didDeauthorizeCount, 1,
                "authorizationManagerDidDeauthorize should only emit once"
                
            )
        }
        
        encodeDecode(Self.spotify.authorizationManager, areEqual: ==)
     
        #else
        throw XCTSkip("cannot test \(#function) without WebKit")
        #endif
    }

}

// MARK: - Client -

final class SpotifyAPIAuthorizationCodeFlowPKCEClientAuthorizationTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIAuthorizationCodeFlowPKCEAuthorizationTests
{

    static let allTests = [
        ("testConvenienceInitializer", testConvenienceInitializer),
        ("testDeauthorizeReauthorize", testDeauthorizeReauthorize),
        ("testReassigningAuthorizationManager", testReassigningAuthorizationManager),
        ("testInvalidCredentials", testInvalidCredentials),
        ("testRefreshTokens", testRefreshTokens),
        ("testRefreshWithInvalidRefreshToken", testRefreshWithInvalidRefreshToken),
        ("testInvalidState1", testInvalidState1),
        ("testInvalidState2", testInvalidState2),
        ("testInvalidState3", testInvalidState3),
        ("testInvalidCodeVerifier", testInvalidCodeVerifier),
        ("testInvalidRedirectURI", testInvalidRedirectURI),
        ("testInvalidCode", testInvalidCode),
        ("testDenyAuthorizationRequest", testDenyAuthorizationRequest)
    ]

    override class func setupAuthorization(scopes: Set<Scope> = Scope.allCases) {
        Self.spotify.authorizationManager.deauthorize()
    }

    func makeFakeAuthManager() -> AuthorizationCodeFlowPKCEManager{
        return AuthorizationCodeFlowPKCEManager(
            clientId: ""
        )
    }

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

    func testDeauthorizeReauthorize() { deauthorizeReauthorize() }

    func testReassigningAuthorizationManager() { reassigningAuthorizationManager() }

    func testInvalidCredentials() { invalidCredentials() }

    func testRefreshTokens() { refreshTokens() }

    func testRefreshWithInvalidRefreshToken() { refreshWithInvalidRefreshToken() }

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

    func testDenyAuthorizationRequest() throws { try denyAuthorizationRequest() }

    override class func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }

}

// MARK: - Proxy -

final class SpotifyAPIAuthorizationCodeFlowPKCEProxyAuthorizationTests:
    SpotifyAPIAuthorizationCodeFlowPKCEProxyTests, SpotifyAPIAuthorizationCodeFlowPKCEAuthorizationTests
{

    static let allTests = [
        ("testConvenienceInitializer", testConvenienceInitializer),
        ("testDeauthorizeReauthorize", testDeauthorizeReauthorize),
        ("testReassigningAuthorizationManager", testReassigningAuthorizationManager),
        ("testRefreshTokens", testRefreshTokens),
        ("testRefreshWithInvalidRefreshToken", testRefreshWithInvalidRefreshToken),
        ("testInvalidState1", testInvalidState1),
        ("testInvalidState2", testInvalidState2),
        ("testInvalidState3", testInvalidState3),
        ("testInvalidCodeVerifier", testInvalidCodeVerifier),
        ("testInvalidCode", testInvalidCode),
        ("testDenyAuthorizationRequest", testDenyAuthorizationRequest)
    ]

    override class func setupAuthorization(scopes: Set<Scope> = Scope.allCases) {
        Self.spotify.authorizationManager.deauthorize()
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
            decodeServerError: Self.spotify.authorizationManager.backend.decodeServerError
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

    func testDeauthorizeReauthorize() { deauthorizeReauthorize() }

    func testReassigningAuthorizationManager() { reassigningAuthorizationManager() }

    func testRefreshTokens() { refreshTokens() }

    func testRefreshWithInvalidRefreshToken() { refreshWithInvalidRefreshToken() }

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

    func testDenyAuthorizationRequest() throws { try denyAuthorizationRequest() }

    override class func tearDown() {
        Self.spotify.authorizationManager.deauthorize()
    }

}
