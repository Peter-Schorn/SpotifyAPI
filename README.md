# SpotifyAPI

**A Swift library for the Spotify web API**

Read the full [documentation][1].

## Quick Start

To get started, go to the [Spotify Developer Dashboard][2] and create an app. You will receive a client id and client secret. Then, click on "edit settings" and add a redirect URI. Usually, this should be a custom URL scheme that redirects to a location in your app.

The next step is authorizing your app. This library supports two authorization methods:

* [Authorization Code Flow][3]: Use this method if you need to access/modify user data, which requires [authorization scopes][5]. It requires the user to login to their Spotify account in a browser and authorize your app.
* [Client Credentials Flow][4]: Use this method if you do NOT need to access/modify user data. In other words, you cannot access endpoints that require [authorization scopes][5]. The advantage of this method is that it does not require any user interaction.

### Authorizing with the Authorization Code Flow

Create an instance of `SpotifyAPI` and 



[1]: https://peter-schorn.github.io/SpotifyAPI/
[2]: https://developer.spotify.com/dashboard/login
[3]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
[4]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
[5]: https://developer.spotify.com/documentation/general/guides/scopes/
