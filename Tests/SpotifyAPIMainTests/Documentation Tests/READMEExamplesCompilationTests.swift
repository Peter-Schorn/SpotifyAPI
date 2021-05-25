import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import SpotifyWebAPI
import SpotifyExampleContent

/**
 Ensure that the examples in the README compile.
 These methods should not be called.
 This class is intentionally **NOT** a subclass of `XCTestCase`.

 For example, if a symbol was renamed, then this file would fail to compile,
 serving as a warning that the documentation needs to be updated to reflect
 the changes.
 */
private class READMEExamplesCompilationTests {
    
    private var cancellables: Set<AnyCancellable> = []
    
    func testDocsAuthorizationCodeFlowPKCE() {
        
        let spotify = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowPKCEManager(
                clientId: "Your Client Id"
            )
        )
        
        let codeVerifier = String.randomURLSafe(length: 128)
        let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)
        let state = String.randomURLSafe(length: 128)
        
        let authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: URL(string: "Your Redirect URI")!,
            codeChallenge: codeChallenge,
            state: state,
            scopes: [
                .playlistModifyPrivate,
                .userModifyPlaybackState,
                .playlistReadCollaborative,
                .userReadPlaybackPosition
            ]
        )!
        
        _ = authorizationURL
        
        let url = URL(string: "redirectURIWithQuery")!
        
        spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            // Must match the code verifier that was used to generate the
            // code challenge when creating the authorization URL.
            codeVerifier: codeVerifier,
            // Must match the value used when creating the authorization URL.
            state: state
        )
        .sink(receiveCompletion: { completion in
            switch completion {
                case .finished:
                    print("successfully authorized")
                case .failure(let error):
                    if let authError = error as? SpotifyAuthorizationError,
                           authError.accessWasDenied {
                        print("The user denied the authorization request")
                    }
                    else {
                        print("couldn't authorize application: \(error)")
                    }
            }
        })
        .store(in: &cancellables)
        
        let playbackRequest = PlaybackRequest(
            context: .uris(
                URIs.Tracks.array(.faces, .illWind, .fearless)
            ),
            offset: .uri(URIs.Tracks.fearless),
            positionMS: 50_000
        )

        spotify.play(playbackRequest)
            .sink(receiveCompletion: { completion in
                print(completion)
            })
            .store(in: &cancellables)

    }
    
    func testDocsAuthorizationCodeFlow() {
        
        let spotify = SpotifyAPI(
            authorizationManager: AuthorizationCodeFlowManager(
                clientId: "Your Client Id", clientSecret: "Your Client Secret"
            )
        )
        
        let authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: URL(string: "YourRedirectURI")!,
            showDialog: false,
            scopes: [
                .playlistModifyPrivate,
                .userModifyPlaybackState,
                .playlistReadCollaborative,
                .userReadPlaybackPosition
            ]
        )!

        _ = authorizationURL
        
        let url = URL(string: "redirectURIWithQuery")!
        
        spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url
        )
        .sink(receiveCompletion: { completion in
            switch completion {
                case .finished:
                    print("successfully authorized")
                    break
                case .failure(let error):
                    if let authError = error as? SpotifyAuthorizationError,
                            authError.accessWasDenied {
                        print("The user denied the authorization request")
                    }
                    else {
                        print("couldn't authorize application: \(error)")
                    }
            }
        })
        .store(in: &cancellables)
        
        spotify.currentUserPlaylists()
            .extendPages(spotify)
            .sink(
                receiveCompletion: { completion in
                    print(completion)
                },
                receiveValue: { results in
                    print(results)
                }
            )
            .store(in: &cancellables)
        
    }
    
    func testDocsClientCredentialsCodeFlow() {
        
        let spotify = SpotifyAPI(
            authorizationManager: ClientCredentialsFlowManager(
                clientId: "Your Client Id", clientSecret: "Your Client Secret"
            )
        )
        
        spotify.authorizationManager.authorize()
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        print("successfully authorized application")
                    case .failure(let error):
                        print("could not authorize application: \(error)")
                }
            })
            .store(in: &cancellables)
        
        spotify.search(query: "Pink Floyd", categories: [.track])
            .sink(
                receiveCompletion: { completion in
                    print(completion)
                },
                receiveValue: { results in
                    print(results)
                }
            )
            .store(in: &cancellables)

    }

}
