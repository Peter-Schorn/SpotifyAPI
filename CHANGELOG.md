# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [0.3.2] - 2020-09-20

### Changed

- Renamed the `types` parameter of SpotifyAPI.search to `categories`.


## [0.3.1] - 2020-09-19

### Changed

- `SpotifyAPI.currentPlayback()` now returns an optional `CurrentlyPlayingContext`, which will be `nil` if no available device was found.

## [0.3.0] - 2020-09-17

All of the Spotify web API endpoints are now supported!

### Added

- Added the following endpoints:
  - `category(_:country:locale:)` - Get a Spotify Category
  - `categories(country:locale:limit:offset:)` - Get a list of categories used to tag items in Spotify (on, for example, the Spotify player’s “Browse” tab).
  - `categoryPlaylists(_:country:limit:offset:)` - Get a list of Spotify playlists tagged with a particular category.
  - `featuredPlaylists(locale:country:timestamp:limit:offset:)` - Get a list of featured playlists (shown, for example, on a Spotify player’s “Browse” tab).
  - `newAlbumReleases(country:limit:offset:)` - Get a list of new album releases featured in Spotify (shown, for example, on a Spotify player’s “Browse” tab).
  - `recommendations(_:limit:market:)` - Get Recommendations Based on Seeds.
  - `recommendationGenres()` - Retrieve a list of available genres seeds for recommendations.
- Added `genre` to `IDCategory`

### Changed
- Made all the properties of all public objects used in post/put requests (as opposed to objected *returned* by Spotify) mutable. These objects are:
  - `AttributeRange`
  - `TrackAttributes`
  - `PlaybackRequest`
  - `PlaylistDetails`
  - `ReorderPlaylistItems`
  - `URIsWithPositionsContainer`
  - `URIWithPositions`
- `SpotifyIdentifier` has much more descriptive error messages when identifiers cannot be parsed and improved documentation.

## [0.2.0] - 2020-09-15

### Changed
- Refactored SpotifyAPI methods that require either authorization scopes or an access token that was retrieved for a user into conditional extensions where  AuthorizationManager conforms SpotifyScopeAuthorizationManager. This new protocol extends SpotifyAuthorizationManager and requires that conforming types support authorization scopes. Currently, only `AuthorizationCodeFlowManager` conforms to this protocol, but a future version of this library will support the [Authorization Code Flow with Proof Key for Code Exchange](https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce), which will also conform to this protocol. `ClientCredentialsFlowManager` is not a conforming type because it does not support authorization scopes. This change provides a compile-time guarantee that you can not call methods that require authorization scopes when using the `ClientCredentialsFlowManager`.
- Refactored `resumePlayback` into two separate methods: `resumePlayback(deviceId:)` only resumes the user's current playback. `play(_:deviceId:)` (added) plays specific content for the current user.
- When multiple asyncronous requests are made to refresh the access token, only one network request will be made. While this request is in progress, additional requests to refresh the access token will receive the same publisher as a class instance.
- If you try to make a request to the Spotify web API before your application is authorized, then a more informative error indicating that you haven't retrieved an access token is returned, instead of one indicating that you haven't retrieved a refresh token.
//