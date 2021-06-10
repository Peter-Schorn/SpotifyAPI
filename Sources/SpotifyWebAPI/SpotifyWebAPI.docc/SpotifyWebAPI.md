# ``SpotifyWebAPI``

A Swift library for the Spotify web API

## Overview

Supports all of the Spotify web API endpoints, including playing content, creating playlists, and retrieving albums.
Uses Apple's Combine framework, which makes chaining asynchronous requests a breeze
Supports three different authorization methods
Automatically refreshes the access token when necessary.

## Topics

### Authorization

- ``AuthorizationCodeFlowPKCEManager``
- ``AuthorizationCodeFlowManager``
- ``AuthorizationCodeFlowManagerBase``
- ``ClientCredentialsFlowManager``
- ``AuthorizationCodeFlowBackendManager``
- ``AuthorizationCodeFlowPKCEBackendManager``
- ``ClientCredentialsFlowBackendManager``
- ``Scope``
- ``SpotifyAuthorizationManager``
- ``SpotifyScopeAuthorizationManager``
