# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.7.5] - 2020-10-20

### Changed

* Updated documentation for playing content to mention that shows can be used for `contextURI`.
* Simplified the `localizedDescription` for the error objects. The descriptions are now more suitable for the end user. Always use the string representation of the error objects for debugging purposes; only use `localizedDescription` to display the error to the end user.

### Fixed

* Fixed a bug where the values passed into `SpotifyLocalError.invalidState` were transposed.

## [0.7.4] - 2020-10-17

### Fixed

* Fixed bugs for the `SpotifyAPI.showEpisodes(_:market:offset:limit:)` endpoint, which was trying to decode the wrong response type and did not add the id of the show to the query string correctly.

### Added

* Added `totalEpisodes` property to `Show`, which should've already been added.
* Added example `PlaylistItem`s to the `SpotifyExampleContent` module.

## [0.7.3] - 2020-10-16

### Changed

* The type of `SearchResult.episodes` has been changed from `PagingObject<Episode>?` to `PagingObject<Episode?>?` and The type of `SearchResult.shows` has been changed from `PagingObject<Show>?` to `PagingObject<Show?>?`. This change was necessary because Spotify can return nil for these properties if the shows and/or episodes are not available in the specified markets.

## [0.7.2] - 2020-10-15

### Changed

* Added the `market` parameter to `SpotifyAPI.currentPlayback(market:)` and fixed a bug that caused episodes to not be returned.
* Renamed `CurrentlyPlayingContext.activeDevice` to `device` because this device is not necessarily active. 
* Renamed `CurrentlyPlayingContext.currentlyPlayingType` to `itemType` because this item is not necessarily currently playing. Use `CurrentlyPlayingContext.currentlyPlayingType.isPlaying` to determine if the content is currently playing. 

## [0.7.0] - 2020-10-15

### Added

* Added documentation about how omitting the market parameter when using the client credentials flow causes episodes and shows to not be returned.
* Added `SpotifyAPI.filteredPlaylistItems(_:filters:additionalTypes:limit:offset:market:)`.
* Added `snapshotId` parameter to `SpotifyAPI.removeAllOccurencesFromPlaylist(_:of:snapshotId:)`.
* Added `SpotifyPlayerError`; this error object is returned by Spotify when there are errors related to the player endpoints.

### Changed

* Renamed `SpotifyAPI.filteredPlaylistRequest(_:filters:additionalTypes:market:)` to `SpotifyAPI.filteredPlaylist(_:filters:additionalTypes:market:)`.
* Renamed `SpotifyAPI.getPlaylistImage(_:)` to `SpotifyAPI.playlistImage(_:)`.
* Renamed `AlbumGroup` to `AlbumType`.
* The generic `Item` type of `PlaylistItemContainer` is now optional because the episodes in a playlist will be `nil` If they were retrieved using the client credentials flow manager and a value for the `market` parameter was not provided or if they are not available in the specifed market.

### Fixed

* Fixed issues with additional types parameter for the playlist endpoints and added clearer documentation to `filteredPlaylist` and `filteredPlaylistItems`.
* Fixed bug with decoding of `Album` where both the `albumGroup` and `albumType` properties were being decoded from the `albumGroup` JSON key.
* Fixed bug where the incorrect coding key was being used for the `trackNumber` and `previewURL` properties of `Track`, causing them to never be decoded from the data and always set to `nil`.
* Fixed bug where `externalURLs` property of `SpotifyContext` was not being decoded because the JSON key name was incorrect.

## [0.6.0] - 2020-10-03

### Added

- Added support for the [Authorization Code Flow with Proof Key for Code Exchange](https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce)! This is the best option for mobile and desktop applications where it is unsafe to store your client secret. See `AuthorizationCodeFlowPKCEManager`. 

### Changed

- Added `AuthorizationCodeFlowManagerBase` and refactored `AuthorizationCodeFlowManager` to inherit from it.  `AuthorizationCodeFlowPKCEManager` also inherits from this class.
- The methods for retrieving and refreshing tokens now return an error if the expected properties weren't returned from Spotify. This would've caused an error at a later point anyway.

## [0.5.0] - 2020-10-01

### Changed

- Renamed the following symbols
  - `CurrentlyPlayingContext.device` -> `activeDevice`
  - `CurrentlyPlayingContext.item` -> `currentlyPlayingItem`
  - `PlaylistDetails.collaborative` -> `isCollaborative`
  - `SpotifyAPI.getPlaylistCoverImage(_:)` -> `getPlaylistImage(_:)`
  - `SpotifyAPI.search(query:types:market:limit:offset:includeExternal:)` -> `search(query:categories:market:limit:offset:includeExternal:)`

- The `refreshTokens` method of `ClientCredentialsFlowManager` and `AuthorizationCodeFlowManager` 
is now fully synchronized, meaning it is thread-safe. Calling it multiple times concurrently will always result in a **single** network request being made. Additional calls while a request is still in progress will return a reference to the same publisher as a class instance.

- The `accessToken`, `refreshToken`, `expirationDate`, and `scopes` properties of `AuthorizationCodeFlowManager` and the `accessToken` and `expirationDate` properties of `ClientCredentialsFlowManager` are now synchronized, meaning that they are thread-safe.

## [0.4.0] - 2020-09-22

### Added

- Added a wealth of sample data to the `SpotifyExampleContent` module. It includes URIs and various sample objects from the object model. This is particularly useful for SwiftUI Previews. You are highly encouraged to browse the source code for this module to see all of the available sample data.

### Changed

- Fixed bug in which calling `SpotifyAPI.currentPlayback()` when where were no available devices returned an error because Spotify returned no data. Now, `nil` is returned when Spotify returns no data.
- Bumped the swift tools version to 5.3 so that resources can be used by this package.

## [0.3.3] - 2020-09-21

### Changed 

- Changed the name of the  "SpotifyURIs" module  to "SpotifyExampleContent". 

### Added

- Added public initializers for **all** public objects in the object model. This allows clients to create their own examples for testing purposes.

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
- Made all the properties of all public objects used in post/put requests (as opposed to objects *returned* by Spotify) mutable. These objects are:
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
