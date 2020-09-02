import Foundation
import Combine
import SpotifyWebAPI

/// Ensure that the examples in the README compile.
/// These methods should not be called.
/// This class is intentionally **NOT** a subclass of `XCTestCase`.
private class READMEExamplesCompilationTests {
    
    private var cancellables: Set<AnyCancellable> = []
    
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
        
        // UIApplication.shared.open(authorizationURL)

        let url = URL(string: "redirectURIWithQuery")!
        
        spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url
        )
        .sink(
            receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        // print("successfully authorized")
                        break
                    case .failure(let error):
                        if let authError = error as? SpotifyAuthorizationError,
                                authError.accessWasDenied {
                            // print("The user denied the authorization request")
                        }
                        else {
                            // print("couldn't authorize application: \(error)")
                        }
                }
            }
        )
        .store(in: &cancellables)
        
        spotify.currentUserPlaylists()
            .extendPages(spotify)
            .sink(
                receiveCompletion: { completion in
                    // print(completion)
                },
                receiveValue: { results in
                    // print(results)
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
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            break
                            // print("successfully authorized application")
                        case .failure(let error):
                            _ = error
                            // print("could not authorize application: \(error)")
                    }
                }
            )
            .store(in: &cancellables)
        
        spotify.search(query: "Pink Floyd", types: [.track])
            .sink(
                receiveCompletion: { completion in
                    // print(completion)
                },
                receiveValue: { results in
                    // print(results)
                }
            )
            .store(in: &cancellables)

    }

}
