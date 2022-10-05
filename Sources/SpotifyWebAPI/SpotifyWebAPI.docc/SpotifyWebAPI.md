# ``SpotifyWebAPI``

A Swift library for the Spotify web API

## Overview

* Supports *all* of the [Spotify web API endpoints][1], including playing content, creating playlists, and retrieving albums
* Uses Apple's Combine framework, which makes chaining asynchronous requests a breeze
* Supports three different authorization methods
* Automatically refreshes the access token when necessary

See this [example iOS app][2] and this [example command-line app][3].

## Authorizing your App

To get started, go to the [Spotify Developer Dashboard][4] and create an app. You will receive a client id and client secret. Then, click on "edit settings" and add a redirect URI. Usually, this should be a custom URL scheme that redirects to a location in your app. **DO NOT add a forward-slash to the end of the redirect URI**.

The next step is authorizing your app. *All* requests to the Spotify web API—whether they require [authorization scopes][5] or not—require authorization. This library supports three authorization methods:

* **<doc:Authorizing-with-the-Authorization-Code-Flow-with-Proof-Key-for-Code-Exchange>**: This is the best option for mobile and desktop applications where it is unsafe to store your client secret. It provides an additional layer of security compared to the Authorization Code Flow. Use this method if you need to access/modify user data, which requires [authorization scopes][5]. It requires the user to login to their Spotify account in a browser/web view and approve your app. Read more at the [Spotify web API reference][6].

* **<doc:Authorizing-with-the-Authorization-Code-Flow>**: Use this method if you need to access/modify user data, which requires [authorization scopes][5]. It requires the user to login to their Spotify account in a browser/web view and approve your app.  Read more at the [Spotify web API reference][7].
* **<doc:Authorizing-with-the-Client-Credentials-Flow>**: Use this method if you do NOT need to access/modify user data. In other words, you cannot access endpoints that require [authorization scopes][5] or an access token that was issued on behalf of a user. The advantage of this method is that it does not require any user interaction. Read more at the [Spotify web API reference][8].

See also <doc:Additional-Authorization-Methods>.

When creating an application that uses this library, you will probably want to **save the authorization information to persistent storage** so that the user does not have to login again every time the application is quit and re-launched. See <doc:Saving-the-Authorization-Information-to-Persistent-Storage> for a guide on how to do this.

## Topics

### Articles

- <doc:Saving-the-Authorization-Information-to-Persistent-Storage>
- <doc:Using-the-Player-Endpoints>
- <doc:Working-with-Paginated-Results>
- <doc:Debugging>
- <doc:Running-the-Unit-Tests>

### SpotifyAPI

- ``SpotifyAPI``

### Authorization

- ``AuthorizationCodeFlowPKCEManager``
- <doc:Authorizing-with-the-Authorization-Code-Flow-with-Proof-Key-for-Code-Exchange>

- ``AuthorizationCodeFlowManager``
- <doc:Authorizing-with-the-Authorization-Code-Flow>

- ``ClientCredentialsFlowManager``
- <doc:Authorizing-with-the-Client-Credentials-Flow>

- ``Scope``

- <doc:Additional-Authorization-Methods>

### Errors

- ``SpotifyError``
- ``SpotifyPlayerError``
- ``SpotifyGeneralError``
- ``RateLimitedError``
- ``SpotifyAuthenticationError``
- ``SpotifyAuthorizationError``
- ``SpotifyDecodingError``

### Object Model

- <doc:Media-Objects>
- <doc:Playlist-Objects>
- <doc:Player-Objects>
- <doc:Audiobook-Objects>
- <doc:Audio-Analysis-Objects>
- <doc:Other-Objects>

### Spotify Identifiers

- ``SpotifyIdentifier``
- ``IDCategory``

[1]: https://developer.spotify.com/documentation/web-api/reference/
[2]: https://github.com/Peter-Schorn/SpotifyAPIExampleApp
[3]: https://github.com/Peter-Schorn/SpotifyAPIExamples
[4]: https://developer.spotify.com/dashboard/login
[5]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
[6]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
[7]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
[8]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
