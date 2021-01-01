# SpotifyAPI

**A Swift library for the Spotify web API**

### Features

* Supports *all* of the [Spotify web API endpoints][24], including playing content, creating playlists, and retrieving albums.
* Uses Apple's Combine framework, which makes chaining asynchronous requests a breeze
* Supports three different authorization methods
* Automatically refreshes the access token when necessary

Read the full [documentation][1] and check out [this example iOS app][14] and this [example command-line app][23]. Additional Information is available on the [wiki page][17].

## Table of Contents

* **[Supported Platforms](#supported-platforms)**
* **[Installation](#installation)**
* **[Quick Start](#quick-start)**
* **[Authorizing with the Authorization Code Flow with Proof Key for Code Exchange](#authorizing-with-the-authorization-code-flow-with-proof-key-for-code-exchange)**
* **[Authorizing with the Authorization Code Flow](#authorizing-with-the-authorization-code-flow)**  
* **[Authorizing with the Client Credentials Flow](#authorizing-with-the-client-credentials-flow)**

## Supported Platforms

* iOS 13+
* macOS 10.15+
* tvOS 13+
* watchOS 6+
* **NEW**: Linux

## Installation

1. In Xcode, open the project that you want to add this package to.
2. From the menu bar, select File > Swift Packages > Add Package Dependency...
3. Paste the [URL](https://github.com/Peter-Schorn/SpotifyAPI.git) for this repository into the search field.
5. Select the `SpotifyAPI` Library.
4. Follow the prompts for adding the package.

## Quick Start

To get started, go to the [Spotify Developer Dashboard][2] and create an app. You will receive a client id and client secret. Then, click on "edit settings" and add a redirect URI. Usually, this should be a custom URL scheme that redirects to a location in your app. **DO NOT add a forward-slash to the end of the redirect URI**.

The next step is authorizing your app. *All* requests to the Spotify web API—whether they require [authorization scopes][5] or not—require authorization This library supports three authorization methods:

* **[Authorization Code Flow with Proof Key for Code Exchange](#authorizing-with-the-authorization-code-flow-with-proof-key-for-code-exchange)**: This is the best option for mobile and desktop applications where it is unsafe to store your client secret. It provides an additional layer of security compared to the Authorization Code Flow. Use this method if you need to access/modify user data, which requires [authorization scopes][5]. It requires the user to login to their Spotify account in a browser/web view and approve your app. Read more at the [Spotify web API reference][15].

* **[Authorization Code Flow](#authorizing-with-the-authorization-code-flow)**: Use this method if you need to access/modify user data, which requires [authorization scopes][5]. It requires the user to login to their Spotify account in a browser/web view and approve your app.  Read more at the [Spotify web API reference][3].
* **[Client Credentials Flow](#authorizing-with-the-client-credentials-flow)**: Use this method if you do NOT need to access/modify user data. In other words, you cannot access endpoints that require [authorization scopes][5] or an access token that was issued on behalf of a user. The advantage of this method is that it does not require any user interaction.  Read more at the [Spotify web API reference][4].

When creating an application that uses this library, you will probably want to **save the authorization information to persistent storage** so that the user does not have to login again every time the application is quit and re-launched. See the [Saving Authorization Information to Persistent Storage][16] wiki page for a guide on how to do this.

## Authorizing with the Authorization Code Flow with Proof Key for Code Exchange

Create an instance of `SpotifyAPI` and assign an instance of `AuthorizationCodeFlowPKCEManager` to the `authorizationManager` property:
```swift
import SpotifyWebAPI

let spotify = SpotifyAPI(
    authorizationManager: AuthorizationCodeFlowPKCEManager(
        clientId: "Your Client Id", clientSecret: "Your Client Secret"
    )
)
```


Before each authentication request your app should generate a code verifier and a code challenge. The code verifier is a cryptographically random string between 43 and 128 characters in length. It can contain letters, digits, underscores, periods, hyphens, and tildes.

In order to generate the code challenge, your app should hash the code verifier using the SHA256 algorithm. Then, [base64url][19] encode the hash that you generated. **Do not include any** `=` **padding characters** (percent-encoded or not).

You can use `String.randomURLSafe(length:using:)` or `String.randomURLSafe(length:)` to generate the code verifier. You can use the `String.makeCodeChallenge()` instance method to create the code challenge from the code verifier. 

For example:

```swift
let codeVerifier = String.randomURLSafe(length: 128)
let codeChallenge = codeVerifier.makeCodeChallenge()

// optional, but strongly recommended
let state = String.randomURLSafe(length: 128)
```

If you use your own method to create these values, you can validate them using this [PKCE generator tool][18]. See also `Data.base64URLEncodedString()` and `String.urlSafeCharacters`.

Next, create the authorization URL that will be opened in a browser (or web view). When opened, it displays a permissions dialog to the user. The user can then choose to either authorize or deny authorization for your application.

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

See the full documentation for [makeAuthorizationURL(redirectURI:showDialog:codeChallenge:state:scopes:)][20].

The redirect URI needs to have been entered in the Redirect URI whitelist that you specified when you registered your application using the [Spotify Developer Dashboard][2]. **DO NOT add a forward-slash to the end of the redirect URI.**

The documentation for each endpoint lists the [authorization scopes][5] that are required. You can always authorize your application again for different scopes, if necessary. However, this is not an additive process. You must specify all the scopes that you need each time you create the authorization URL.

You can decide how to open the URL. If you are creating an iOS app, the simplest method is to use `UIApplication.shared.open(authorizationURL)` to open the URL in the browser.

After the user either approves or denies authorization for your app, Spotify will redirect to the redirect URI that you specified when making the authorization URL with query parameters appended to it. Pass this URL into [requestAccessAndRefreshTokens(redirectURIWithQuery:codeVerifier:state:)][21] to request the access and refresh tokens:
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

The full documentation for all of the endpoints can be found [here][8]. You are also encouraged to read the [Spotify web API reference][12].

## Authorizing with the Authorization Code Flow

Create an instance of `SpotifyAPI` and assign an instance of `AuthorizationCodeFlowManager` to the `authorizationManager` property:
```swift
import SpotifyWebAPI

let spotify = SpotifyAPI(
    authorizationManager: AuthorizationCodeFlowManager(
        clientId: "Your Client Id", clientSecret: "Your Client Secret"
    )
)
```

Next, create the authorization URL that will be opened in a browser (or web view). When opened, it displays a permissions dialog to the user. The user can then choose to either authorize or deny authorization for your application.
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

See the full documentation for [makeAuthorizationURL(redirectURI:showDialog:state:scopes:)][6].

The redirect URI needs to have been entered in the Redirect URI whitelist that you specified when you registered your application using the [Spotify Developer Dashboard][2]. **DO NOT add a forward-slash to the end of the redirect URI.**

The documentation for each endpoint lists the [authorization scopes][5] that are required. You can always authorize your application again for different scopes, if necessary. However, this is not an additive process. You must specify all the scopes that you need each time you create the authorization URL.

You can decide how to open the URL. If you are creating an iOS app, the simplest method is to use `UIApplication.shared.open(authorizationURL)` to open the URL in the browser.

After the user either approves or denies authorization for your app, Spotify will redirect to the redirect URI that you specified when making the authorization URL with query parameters appended to it. Pass this url into [requestAccessAndRefreshTokens(redirectURIWithQuery:state:)][7] to request the access and refresh tokens:
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

This authorization process is fully implemented in this [example app][22]. The full documentation for all of the endpoints can be found [here][8]. You are also encouraged to read the [Spotify web API reference][12].

## Authorizing with the Client Credentials Flow

Create an instance of `SpotifyAPI` and assign an instance of `ClientCredentialsFlowManager` to the `authorizationManager` property:
```swift
import SpotifyWebAPI

let spotify = SpotifyAPI(
    authorizationManager: ClientCredentialsFlowManager(
        clientId: "Your Client Id", clientSecret: "Your Client Secret"
    )
)
```

To authorize your application, call `authorize()`:
```swift
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
```

See the full documentation for [authorize][13].

Once this publisher completes successfully, your application is authorized and you may begin making requests to the Spotify web API. The access token will be refreshed automatically when necessary. For example:
```swift
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
```

This authorization process is implemented in this [example command-line app][23]. The full documentation for all of the endpoints can be found [here][8]. You are also encouraged to read the [Spotify web API reference][12].

[1]: https://peter-schorn.github.io/SpotifyAPI/Classes/SpotifyAPI.html
[2]: https://developer.spotify.com/dashboard/login

[3]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
[4]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
[5]: https://developer.spotify.com/documentation/general/guides/scopes/
[6]: https://peter-schorn.github.io/SpotifyAPI/Classes/AuthorizationCodeFlowManager.html#/s:13SpotifyWebAPI28AuthorizationCodeFlowManagerC04makeD3URL11redirectURI10showDialog5state6scopes10Foundation0I0VSgAK_SbSSSgShyAA5ScopeOGtF
[7]: https://peter-schorn.github.io/SpotifyAPI/Classes/AuthorizationCodeFlowManager.html#/s:13SpotifyWebAPI28AuthorizationCodeFlowManagerC29requestAccessAndRefreshTokens20redirectURIWithQuery5state7Combine12AnyPublisherVyyts5Error_pG10Foundation3URLV_SSSgtF

[8]: https://peter-schorn.github.io/SpotifyAPI/Classes/SpotifyAPI.html
[12]: https://developer.spotify.com/documentation/web-api/reference/
[13]: https://peter-schorn.github.io/SpotifyAPI/Classes/ClientCredentialsFlowManager.html#/s:13SpotifyWebAPI28ClientCredentialsFlowManagerC9authorize7Combine12AnyPublisherVyyts5Error_pGyF
[14]: https://github.com/Peter-Schorn/SpotifyAPIExampleApp
[15]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
[16]: https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.
[17]: https://github.com/Peter-Schorn/SpotifyAPI/wiki
[18]: https://tonyxu-io.github.io/pkce-generator/
[19]: https://tools.ietf.org/html/rfc4648#section-5
[20]: https://peter-schorn.github.io/SpotifyAPI/Classes/AuthorizationCodeFlowPKCEManager.html#/s:13SpotifyWebAPI32AuthorizationCodeFlowPKCEManagerC04makeD3URL11redirectURI10showDialog13codeChallenge5state6scopes10Foundation0I0VSgAL_SbS2SSgShyAA5ScopeOGtF
[21]: https://peter-schorn.github.io/SpotifyAPI/Classes/AuthorizationCodeFlowPKCEManager.html#/s:13SpotifyWebAPI32AuthorizationCodeFlowPKCEManagerC29requestAccessAndRefreshTokens20redirectURIWithQuery12codeVerifier5state7Combine12AnyPublisherVyyts5Error_pG10Foundation3URLV_S2SSgtF

[22]: https://github.com/Peter-Schorn/SpotifyAPIExampleApp#how-the-authorization-process-works
[23]: https://github.com/Peter-Schorn/SpotifyAPIExamples
[24]: https://developer.spotify.com/documentation/web-api/reference/
