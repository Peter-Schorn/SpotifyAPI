# Additional Authorization Methods

Additional methods for authorizing your app with the Spotify web API.

## Using a Backend Server to Retrieve the Authorization Information 

Authorizing with Spotify directly via your frontend app exposes your client secret to the world. Instead, you can create a backend server that can securely store your client id and client secret. This server can authorize with Spotify on behalf of your frontend app. It can also encrypt the refresh token that Spotify returns before sending it back to your app, which provides an additional layer of security.

Listed below are protocols for each [authorization flow](https://developer.spotify.com/documentation/general/guides/authorization/) that enable you to customize how you retrieve the authorization information from Spotify, as well as concrete implementations of each protocol—one that communicates with Spotify directly (suffixed with "client") and one that communicates with a backend server (suffixed with "proxy"). For additional customization, you can create your own conforming types.

* **``AuthorizationCodeFlowBackend``**: Used by ``AuthorizationCodeFlowBackendManager`` to retrieve the authorization information and refresh the access token for the [Authorization Code Flow](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/). Conforming types: ``AuthorizationCodeFlowClientBackend`` and ``AuthorizationCodeFlowProxyBackend``.

* **``AuthorizationCodeFlowPKCEBackend``**: Used by ``AuthorizationCodeFlowPKCEBackendManager`` to retrieve the authorization information and refresh the access token for the [Authorization Code Flow with Proof Key for Code Exchange](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/). Conforming types: ``AuthorizationCodeFlowPKCEClientBackend`` and ``AuthorizationCodeFlowPKCEProxyBackend``.

* **``ClientCredentialsFlowBackend``**: Used by ``ClientCredentialsFlowBackendManager`` to retrieve the authorization information for the [Client Credentials Flow](https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/). Conforming types: ``ClientCredentialsFlowClientBackend`` and ``ClientCredentialsFlowProxyBackend``.

## SpotifyAPIServer

Instead of creating your own backend server, you can use [SpotifyAPIServer](https://github.com/Peter-Schorn/SpotifyAPIServer), which can be deployed to heroku with a single click. It supports all three authorization flows described above. It is designed to be used with ``AuthorizationCodeFlowProxyBackend``, ``AuthorizationCodeFlowPKCEProxyBackend``, or ``ClientCredentialsFlowProxyBackend``.

## Creating Your Own Backend Server

Each of the above protocols describes the functionality that your server must support. Each protocol has a conforming type suffixed with "proxy" which can make the requests to your server for you. For example, if you want to setup a server that can handle the authorization process for the [Authorization Code Flow](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/), then your frontend app should communicate with the server by either creating a custom type that conforms to ``AuthorizationCodeFlowBackend`` or by using ``AuthorizationCodeFlowProxyBackend``. You can then create an instance of ``SpotifyAPI`` as follows:

```swift
let spotifyAPI = SpotifyAPI(
    authorizationManager: AuthorizationCodeFlowBackendManager(
        backend: AuthorizationCodeFlowProxyBackend(  // or a custom type that conforms to `AuthorizationCodeFlowBackend`
            clientId: "your client id",
            tokensURL: tokensURL,
            tokenRefreshURL: tokenRefreshURL
        )
    )
)
```

You can then authorize your app using the same process described in <doc:Authorizing-with-the-Authorization-Code-Flow>.

### Errors

Any errors received from the Spotify web API by your server, along with the headers and status code, should be forwarded directly to the caller, as ``SpotifyAPI`` already knows how to decode these errors. 

If your server itself returns an error, then you can decode it into a custom error type in your frontend app. ``AuthorizationCodeFlowProxyBackend``, ``AuthorizationCodeFlowPKCEProxyBackend``, and ``ClientCredentialsFlowProxyBackend`` each provide a `decodeServerError` closure that gets called after a response from your server is received so that you can decode it into a custom error type.

## Topics

### Authorization Backend Managers

- ``AuthorizationCodeFlowPKCEBackendManager``
- ``AuthorizationCodeFlowBackendManager``
- ``ClientCredentialsFlowBackendManager``

- ``AuthorizationCodeFlowManagerBase``

### Create your Own Authorization Manager

- ``SpotifyAuthorizationManager``
- ``SpotifyScopeAuthorizationManager``

### Authorization Backends

- ``AuthorizationCodeFlowBackend``
- ``AuthorizationCodeFlowClientBackend``
- ``AuthorizationCodeFlowProxyBackend``
- ``AuthorizationCodeFlowPKCEBackend``
- ``AuthorizationCodeFlowPKCEClientBackend``
- ``AuthorizationCodeFlowPKCEProxyBackend``
- ``ClientCredentialsFlowBackend``
- ``ClientCredentialsFlowClientBackend``
- ``ClientCredentialsFlowProxyBackend``

### Authentication Objects

- ``AuthInfo``
- ``ClientCredentialsTokensRequest``
- ``TokensRequest``
- ``ProxyTokensRequest``
- ``RefreshTokensRequest``
- ``PKCETokensRequest``
- ``ProxyPKCETokensRequest``
- ``PKCERefreshTokensRequest``
- ``ProxyPKCERefreshTokensRequest``
