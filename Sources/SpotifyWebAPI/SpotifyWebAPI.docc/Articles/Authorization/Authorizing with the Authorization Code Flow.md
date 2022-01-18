# Authorizing with the Authorization Code Flow

Use this method if you need to access/modify user data, which requires authorization scopes. It requires the user to login to their Spotify account in a browser/web view and approve your app.

## Authorization

Create an instance of ``SpotifyAPI`` and assign an instance of ``AuthorizationCodeFlowManager`` to the ``SpotifyAPI/authorizationManager`` property:
```swift
import SpotifyWebAPI

let spotify = SpotifyAPI(
    authorizationManager: AuthorizationCodeFlowManager(
        clientId: "Your Client Id", clientSecret: "Your Client Secret"
    )
)
```

Next, create the authorization URL that will be opened in a browser (or web view) using ``AuthorizationCodeFlowBackendManager/makeAuthorizationURL(redirectURI:showDialog:state:scopes:)``. When opened, it displays a permissions dialog to the user. The user can then choose to either authorize or deny authorization for your application.
```swift
let authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
    redirectURI: URL(string: "Your Redirect URI")!,
    showDialog: false,
    scopes: [
        .playlistModifyPrivate,
        .userModifyPlaybackState,
        .playlistReadCollaborative,
        .userReadPlaybackPosition
    ]
)!
```

The redirect URI needs to have been entered in the Redirect URI whitelist that you specified when you registered your application using the [Spotify Developer Dashboard][1]. **DO NOT add a forward-slash to the end of the redirect URI.**

The documentation for each endpoint lists the [authorization scopes][2] that are required. You can always authorize your application again for different scopes, if necessary. However, this is not an additive process. You must specify all the scopes that you need each time you create the authorization URL.

You can decide how to open the URL. If you are creating an iOS app, the simplest method is to use `UIApplication.shared.open(authorizationURL)` to open the URL in the browser.

After the user either approves or denies authorization for your app, Spotify will redirect to the redirect URI that you specified when making the authorization URL with query parameters appended to it. Pass this url into ``AuthorizationCodeFlowBackendManager/requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`` to request the access and refresh tokens:
```swift
spotify.authorizationManager.requestAccessAndRefreshTokens(
    redirectURIWithQuery: url
)
.sink(receiveCompletion: { completion in
    switch completion {
        case .finished:
            print("successfully authorized")
        case .failure(let error):
            if let authError = error as? SpotifyAuthorizationError, authError.accessWasDenied {
                print("The user denied the authorization request")
            }
            else {
                print("couldn't authorize application: \(error)")
            }
    }
})
.store(in: &cancellables)
```

Once this publisher completes successfully, your application is authorized and you may begin making requests to the Spotify web API. **Ensure that you generate a new value for the state parameter before making another authorization request**. The access token will be refreshed automatically when necessary. For example:

```swift
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
```

This authorization process is fully implemented in this [example app][3]. Read more at the [Spotify web API reference][4].

[1]: https://developer.spotify.com/dashboard/login
[2]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
[3]: https://github.com/Peter-Schorn/SpotifyAPIExampleApp#how-the-authorization-process-works
[4]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/

