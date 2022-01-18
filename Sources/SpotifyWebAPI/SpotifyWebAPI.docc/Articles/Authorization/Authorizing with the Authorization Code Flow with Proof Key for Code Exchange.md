# Authorizing with the Authorization Code Flow with Proof Key for Code Exchange

This is the best option for mobile and desktop applications where it is unsafe to store your client secret. It provides an additional layer of security compared to the Authorization Code Flow. Use this method if you need to access/modify user data, which requires authorization scopes. It requires the user to login to their Spotify account in a browser/web view and approve your app.

## Authorization

Create an instance of ``SpotifyAPI`` and assign an instance of ``AuthorizationCodeFlowPKCEManager`` to the ``SpotifyAPI/authorizationManager`` property:
```swift
import SpotifyWebAPI

let spotify = SpotifyAPI(
    authorizationManager: AuthorizationCodeFlowPKCEManager(
        clientId: "Your Client Id"
    )
)
```

Before each authentication request your app should generate a code verifier and a code challenge. The code verifier is a cryptographically random string between 43 and 128 characters in length. It can contain letters, digits, underscores, periods, hyphens, and tildes.

In order to generate the code challenge, your app should hash the code verifier using the SHA256 algorithm. Then, [base64url][1] encode the hash that you generated. **Do not include any** `=` **padding characters** (percent-encoded or not).

You can use `String.randomURLSafe(length:using:)` or `String.randomURLSafe(length:)` to generate the code verifier. You can use the `String.makeCodeChallenge(codeVerifier:)` method to create the code challenge from the code verifier. 

For example:

```swift
let codeVerifier = String.randomURLSafe(length: 128)
let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)

// optional, but strongly recommended
let state = String.randomURLSafe(length: 128)
```

If you use your own method to create these values, you can validate them using this [PKCE generator tool][2]. See also `Data.base64URLEncodedString()` and `String.urlSafeCharacters`.

Next, create the authorization URL that will be opened in a browser (or web view) using ``AuthorizationCodeFlowPKCEBackendManager/makeAuthorizationURL(redirectURI:codeChallenge:state:scopes:)``. When opened, it displays a permissions dialog to the user. The user can then choose to either authorize or deny authorization for your application.

```swift
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
```

The redirect URI needs to have been entered in the Redirect URI whitelist that you specified when you registered your application using the [Spotify Developer Dashboard][3]. **DO NOT add a forward-slash to the end of the redirect URI.**

The documentation for each endpoint lists the [authorization scopes][4] that are required. You can always authorize your application again for different scopes, if necessary. However, this is not an additive process. You must specify all the scopes that you need each time you create the authorization URL.

You can decide how to open the URL. If you are creating an iOS app, the simplest method is to use `UIApplication.shared.open(authorizationURL)` to open the URL in the browser.

After the user either approves or denies authorization for your app, Spotify will redirect to the redirect URI that you specified when making the authorization URL with query parameters appended to it. Pass this URL into ``AuthorizationCodeFlowPKCEBackendManager/requestAccessAndRefreshTokens(redirectURIWithQuery:codeVerifier:state:)`` to request the access and refresh tokens:
```swift
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

Once this publisher completes successfully, your application is authorized and you may begin making requests to the Spotify web API. **Ensure that you generate a new value for the state parameter, code verifier, and code challenge before making another authorization request**. The access token will be refreshed automatically when necessary. For example:
```swift
import SpotifyExampleContent

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
```

Read more at the [Spotify web API reference][5].

[1]: https://tools.ietf.org/html/rfc4648#section-5
[2]: https://tonyxu-io.github.io/pkce-generator/
[3]: https://developer.spotify.com/dashboard/login
[4]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
[5]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
