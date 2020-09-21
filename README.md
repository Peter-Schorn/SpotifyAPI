# SpotifyAPI

**A Swift library for the Spotify web API**

Read the full [documentation][1] and check out [this example app][14]. Additional Information is available on the [wiki page](https://github.com/Peter-Schorn/SpotifyAPI/wiki), including:
* [Saving Authorization Information to Persistent Storage](https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.)

## Table of Contents

* **[Supported Platforms](#supported-platforms)**
* **[Installation](#installation)**
* **[Quick Start](#quick-start)**
* **[Authorizing with the Authorization Code Flow](#authorizing-with-the-authorization-code-flow)**  
* **[Authorizing with the Client Credentials Flow](#authorizing-with-the-client-credentials-flow)**

## Supported Platforms

* iOS 13+
* macOS 10.15+
* tvOS 13+
* watchOS 6+

## Installation

1. In Xcode, open the project that you want to add this package to.
2. From the menu bar, select File > Swift Packages > Add Package Dependency...
3. Paste the [url](https://github.com/Peter-Schorn/SpotifyAPI.git) for this repository into the search field.
5. Select the `SpotifyAPI` Library.
4. Follow the prompts for adding the package.

## Quick Start

To get started, go to the [Spotify Developer Dashboard][2] and create an app. You will receive a client id and client secret. Then, click on "edit settings" and add a redirect URI. Usually, this should be a custom URL scheme that redirects to a location in your app.

The next step is authorizing your app. All requests to the Spotify web API—whether they require authorization scopes or not—require authorization This library supports two authorization methods:

* [Authorization Code Flow][3]: Use this method if you need to access/modify user data, which requires [authorization scopes][5]. It requires the user to login to their Spotify account in a browser and approve your app.
* [Client Credentials Flow][4]: Use this method if you do NOT need to access/modify user data. In other words, you cannot access endpoints that require [authorization scopes][5]. The advantage of this method is that it does not require any user interaction.

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
Next, create the authorization URL that will be opened in a browser (or web view):
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

The redirect URI needs to have been entered in the Redirect URI whitelist that you specified when you registered your application using the [Spotify Developer Dashboard][2].
**DO NOT add a forward-slash to the end of the redirect URI.**

The documentation for each endpoint lists the [authorization scopes][5] that are required. You can always authorize your application again for different scopes, if necessary. However, this is not an additive process. You must specify all the scopes that you need each time you create the authorization URL.

If you are creating an iOS app, then you can use `UIApplication.shared.open(authorizationURL)` to open the URL in the browser. The user will then be asked to login to their Spotify account and approve your application. 

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

Once this publisher completes successfully, your application is authorized and you may begin making requests to the Spotify web API. The access token will be refreshed automatically when necessary. For example:
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

The full documentation for all of the endpoints can be found [here][8].
You are also encouraged to read the [Spotify web API reference][12].

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

The full documentation for all of the endpoints can be found [here][8].
You are also encouraged to read the [Spotify web API reference][12].

[1]: https://peter-schorn.github.io/SpotifyAPI/
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
