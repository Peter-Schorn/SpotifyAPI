# Running the Unit Tests

Run the unit tests and ensure your backend server is correctly configured.

## Testing in Xcode on macOS

In order to run the unit tests, you must first retrieve a client id and client secret by going to the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/login) and creating an app. You must add the following redirect URI:

```
http://localhost:8080
```

Next create a JSON file with your client id and client secret in the following format:

```
{
    "client_id": "abcabcabcabcabcabcabcabcabcabcabcabc",
    "client_secret": "abcabcabcabcabcabcabcabcabcabcabca"
}
```

Then, open the test plan at `SpotifyAPI/Tests/SpotifyAPIMainTestPlan.xctestplan`, select the configurations tab, and set the path to the above file for the environment variable `SPOTIFY_CREDENTIALS_PATH`. You are also strongly encouraged to assign a folder path to the environment variable `SPOTIFY_DATA_DUMP_FOLDER`. If JSON data from the Spotify web API cannot be decoded into the expected response type, it will be saved to this folder. Don't forget to check the check boxes.

![SpotifyAPIMainTestPlan](SpotifyAPIMainTestPlan)

Some of the tests involve communicating with a backend server in order to retrieve the authorization information. If you don't have your own backend server, then clone and run [SpotifyAPIServer](https://github.com/Peter-Schorn/SpotifyAPIServer) during the tests. If you do have your own server, then configure the following environment variables based on the authorization methods your server supports. If your custom server doesn't support some of the authorization methods, then you must run `SpotifyAPIServer` at the same time as your custom server to handle these authorization methods and leave the default values for the corresponding environment variables.

- `SPOTIFY_AUTHORIZATION_CODE_FLOW_TOKENS_URL`
- `SPOTIFY_AUTHORIZATION_CODE_FLOW_REFRESH_TOKENS_URL`
- `SPOTIFY_AUTHORIZATION_CODE_FLOW_PKCE_TOKENS_URL`
- `SPOTIFY_AUTHORIZATION_CODE_FLOW_PKCE_REFRESH_TOKENS_URL`
- `SPOTIFY_CLIENT_CREDENTIALS_FLOW_TOKENS_URL`

With this package as your working directory, run the following terminal command:

```
python3 enable_testing.py true
```

Then, from the Xcode menu bar, select File > Swift Packages > Reset Package Caches.

**In order for the tests to pass, you must have at least two available Spotify devices, one of which must be active.** You can ensure that a device is active by playing content on it.

Select the `SpotifyAPI-Package` scheme and choose Product > Test from the menu bar in order to run the tests. Dozens of times, a URL will be opened in your browser and you will be asked to login with your Spotify account.

## Testing on Linux

The `test_linux.sh` script in the root directory of this package runs the tests on linux using a docker container. the `docker_linx.sh` script starts an interactive terminal session in linux. Both scripts require the following environment variables:

* `SPOTIFY_CLIENT_CREDENTIALS_FLOW_TOKENS_URL` (using a local host URL requires special configuration for it to be accessible from a docker container; see [I want to connect from a container to a service on the host](https://docs.docker.com/docker-for-mac/networking/#i-want-to-connect-from-a-container-to-a-service-on-the-host))
* `SPOTIFY_SWIFT_TESTING_CLIENT_ID`
* `SPOTIFY_SWIFT_TESTING_CLIENT_SECRET`

## Only Testing Your Backend Server

There is a second test plan, `SpotifyAPIProxyServer`, which only runs the tests related to the backend server. In the test navigator, at the very top, click on the test plan and change it to `SpotifyAPIProxyServer`. Ensure the same environment variables  are set for this test plan as with the `SpotifyAPIMainTestPlan`.

![Change Test Plan](Change_Test_Plan)

This test plan runs the following tests. If your backend server doesn't support all of the authorization flows, you may disable the corresponding tests.

**Client Credentials Flow**

- `SpotifyAPIClientCredentialsFlowProxyArtistTests`
- `SpotifyAPIClientCredentialsFlowProxyAuthorizationTests`
- `SpotifyAPIClientCredentialsFlowProxyFollowTests`
- `SpotifyAPIClientCredentialsFlowProxyInsufficientScopeTests`
- `SpotifyAPIClientCredentialsFlowProxyRefreshTokensConcurrentTests`

**Authorization Code Flow**

- `SpotifyAPIAuthorizationCodeFlowProxyArtistTests`
- `SpotifyAPIAuthorizationCodeFlowProxyAuthorizationTests`
- `SpotifyAPIAuthorizationCodeFlowProxyFollowTests`
- `SpotifyAPIAuthorizationCodeFlowProxyInsufficientScopeTests`
- `SpotifyAPIAuthorizationCodeFlowProxyRefreshTokensConcurrentTests`

**Authorization Code Flow with Proof Key for Code Exchange**

- `SpotifyAPIAuthorizationCodeFlowPKCEProxyArtistTests`
- `SpotifyAPIAuthorizationCodeFlowPKCEProxyAuthorizationTests`
- `SpotifyAPIAuthorizationCodeFlowPKCEProxyFollowTests`
- `SpotifyAPIAuthorizationCodeFlowPKCEProxyInsufficientScopeTests`
- `SpotifyAPIAuthorizationCodeFlowPKCEProxyRefreshTokensConcurrentTests`
