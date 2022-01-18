# Debugging

Debug issues and configure logging.

## Overview

If you believe you have encountered a bug with one of the methods in ``SpotifyAPI``, click on the "Read more at the Spotify web API reference" link in the documentation for the method. Then, click on one of the green "TRY IT" buttons in order to try out your request directly in the Spotify web API console. If you get a different result, then you may have found a bug.

## Debugging

To debug errors related to the decoding of data from the Spotify web API, assign a folder to ``SpotifyDecodingError/dataDumpFolder``. It will automatically be initialized to the "SPOTIFY_DATA_DUMP_FOLDER" environment variable, if it exists. When JSON data cannot be decoded into the expected response type, the raw data and a description of the decoding error will be saved to that folder. You can then upload the data to this [online JSON viewer](https://jsoneditoronline.org). See also ``spotifyDecodeLogger`` (described below) and ``SpotifyDecodingError/writeToFolder(_:)``.

## Logging

This library has various loggers that can be used to aid in debugging. By default the `logLevel` of all the loggers is set to critical; no messages are logged at a critical level. In other words, this means that all logging will be disabled by default. All loggers are public and you can set their log level to whatever you want.

In order to use your own logging backend, create a type that conforms to `LogHandler` and call [`LoggingSystem.bootstrap(_:)`](https://apple.github.io/swift-log/docs/current/Logging/Enums/LoggingSystem.html#/s:7Logging0A6SystemO9bootstrapyyAA10LogHandler_pSScFZ). Alternatively, call ``SpotifyAPILogHandler``.``SpotifyAPILogHandler/bootstrap()`` in order to configure this type as the logging backend. See [swift-log](https://github.com/apple/swift-log#on-the-implementation-of-a-logging-backend-a-loghandler), the logging API that this package uses, for more information. 

Call ``SpotifyAPI/setupDebugging()`` to set the log level of most of the loggers to `trace`.

> Warning: The loggers may output sensitive data, such as your client id and client secret. It is your responsibility to redact sensitive data from the logs, if necessary.

### Loggers

#### SpotifyAPI.logger

Logs general messages for the ``SpotifyAPI`` class.

#### SpotifyAPI.authDidChangeLogger

Logs a message when the any of the following publishers emit a signal:   

* ``SpotifyAPI/authorizationManagerDidChange``

* ``SpotifyAPI/authorizationManagerDidDeauthorize``

* ``SpotifyAuthorizationManager/didChange``

* ``SpotifyAuthorizationManager/didDeauthorize``   

Also logs a message in the didSet observer of ``SpotifyAPI/authorizationManager``.

#### SpotifyAPI.apiRequestLogger

Logs the URLs of the network requests made to Spotify and, if present, the body of the requests by converting the raw data to a string. For example:

```
[APIRequest: trace: apiRequest(path:queryItems:httpMethod:makeHeaders:bodyData:requiredScopes:) line 174] POST request to "https://api.spotify.com/v1/users/petervschorn/playlists"; request body:
{"description":"Fri, October 30, 20 at 5:10:23 AM","name":"replaceItemsInPlaylist","collaborative":true,"public":false}
```

#### spotifyDecodeLogger (global)

Logs messages related to the decoding of data from the Spotify web API.

Set the `logLevel` to `trace` to print the raw data received from each request to the Spotify web API to the standard output.

Set the `logLevel` to `warning` to print various warning and error messages to the standard output.

#### AuthorizationCodeFlowBackendManager.logger

Logs messages related to the [Authorization Code Flow](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/), such as when ``AuthorizationCodeFlowManagerBase/deauthorize()``  is called, when the access and refresh tokens are retrieved, and when the tokens are refreshed.

#### AuthorizationCodeFlowPKCEBackendManager.logger

Logs messages related to the [Authorization Code Flow with Proof Key for Code Exchange](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/), such as when ``AuthorizationCodeFlowManagerBase/deauthorize()``  is called, when the access and refresh tokens are retrieved, and when the tokens are refreshed.

#### ClientCredentialsFlowBackendManager.logger

Logs messages related to the [Client Credentials Flow](https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/), such as when ``AuthorizationCodeFlowManagerBase/deauthorize()``  is called, and when an access token is retrieved.

#### AuthorizationCodeFlowManagerBase.baseLogger

Logs messages related to the Authorization Code Flow and the Authorization Code Flow with Proof Key for Code Exchange. Subclasses will not use this logger.

#### ClientCredentialsFlowClientBackend.logger

Logs messages related to retrieving the authorization information for the [Client Credentials Flow](https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/).

#### ClientCredentialsFlowProxyBackend.logger

Logs messages related to retrieving the authorization information for the [Client Credentials Flow](https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/).

#### AuthorizationCodeFlowClientBackend.logger

Logs messages related to retrieving the authorization information for the [Authorization Code Flow](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/).

#### AuthorizationCodeFlowProxyBackend.logger

Logs messages related to retrieving the authorization information for the [Authorization Code Flow](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/).

#### AuthorizationCodeFlowPKCEClientBackend.logger

Logs messages related to retrieving the authorization information for the [Authorization Code Flow with Proof Key for Code Exchange](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/).

#### AuthorizationCodeFlowPKCEProxyBackend.logger

Logs messages related to retrieving the authorization information for the [Authorization Code Flow with Proof Key for Code Exchange](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/).

#### CurrentlyPlayingContext.logger

Logs messages for this struct, especially those involving the decoding of data into this type.
