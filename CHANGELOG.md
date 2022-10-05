# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 10-5-2022

* Added new endpoints for retrieving audiobooks and audiobook chapters:

    - `SpotifyAPI.audiobook(_:market:)`

    - `SpotifyAPI.audiobooks(_:market:)`

    - `SpotifyAPI.chapter(_:market:)`

    - `SpotifyAPI.chapters(_:market:)`

- Added a new endpoint for retrieving the user's queue: `SpotifyAPI.queue()`.

- Added new types to the object model: `Audiobook`, `AudiobookChapter`, `AudiobookAuthor`, and `SpotifyQueue`.

- The `SpotifyAPI.search(query:categories:market:limit:offset:includeExternal:)` method now supports audiobooks. Added `audiobooks` property to `SearchResult`, which is returned by this method. Also, removed `next` property from `SearchResult`. 

- `SpotifyAPI.categoryPlaylists(_:country:limit:offset:)` now returns `AnyPublisher<PagingObject<Playlist<PlaylistItemsReference>?>, Error>` instead of `AnyPublisher<PagingObject<Playlist<PlaylistItemsReference>>, Error>` (the `Playlist<PlaylistItemsReference>` is now optional). This fixes decoding errors.

- Added `totalTracks` to `Album`.

- Added `htmlDescription` and `restrictions` to `Episode`.

- Added `htmlDescription` to `Show`.

- Removed support for Swift 5.1 and 5.2 by deleting the `swift-5-1` branch, which had not been maintained for a long time.

- Added `Audiobooks` and `Chapters` to `URIs` in `SpotifyExampleContent`.

- Added the following sample data to `SpotifyExampleContent`:

    - `Audiobook.harryPotterAndTheSorcerersStone`

    - `Audiobook.enlightenmentNow`

    - `Audiobook.freeWill`

    - `AudiobookChapter.freeWillChapter1`

    - `AudiobookChapter.steveJobsChapter1`

    - `AudiobookChapter.enlightenmentNowChapter3`

    - `SpotifyQueue.sampleQueue`

- Added `audiobook` and `chapter` to `IDCategory`.

## [2.1.1] - 7-25-2022

* Fixed bugs with retrieving additional pages of results when using `SpotifyAPI.currentUserFollowedArtists`, `SpotifyAPI.categories`, and`SpotifyAPI.categoryPlaylists`.

## [2.1.0] - 6-11-2022

* Fixed Bug with decoding playback when context is saved tracks ("liked songs")
* Added `collection` to `IDCategory`.
* `SpotifyContext.type` is decoded to `unknown` if the string in the JSON payload does not match any of the `IDCategory` raw values.
* Updated URLs

## [2.0.3] - 2-7-2022

* When decoding calendar dates for `Album.releaseDate` or  `Episode.releaseDate`, if the format of the date-string is invalid, then these properties will be set to `nil` instead of the decoder throwing an error.

## [2.0.2] - 1-23-2022

* Added support for docc documentation.

## [2.0.1] - 6-23-2021

### Added

* Added `ad` to `IDCategory`. This can be returned for `CurrentlyPlayingContext.itemType`, which indicates the user is currently listening to an ad.

## [2.0.0] - 5-29-2021

### Proxy Server

* Three new authorization managers have been added: `AuthorizationCodeFlowBackendManager`, `AuthorizationCodeFlowPKCEBackendManager`, and `ClientCredentialsFlowBackendManager`. `AuthorizationCodeFlowManager`, `AuthorizationCodeFlowPKCEManager`, and `ClientCredentialsFlowManager` have been refactored to inherit from these classes, respectively. The former three classes are generic over a backend. This backend can handle the process of retrieving the authorization information either directly from Spotify or via a custom backend server that makes requests to Spotify on behalf of your frontend app. This allows you to store sensitive credentials, such as your client id and client secret securely on your backend server, thereby preventing them from being exposed directly in your frontend app.
* Three new protocols have been added:
    * `AuthorizationCodeFlowBackend`. Conforming types: `AuthorizationCodeFlowClientBackend` and `AuthorizationCodeFlowProxyBackend`.
    * `AuthorizationCodeFlowPKCEBackend`. Conforming types: `AuthorizationCodeFlowPKCEClientBackend` and `AuthorizationCodeFlowPKCEProxyBackend`.
    * `ClientCredentialsFlowBackend`. Conforming types: `ClientCredentialsFlowClientBackend` and `ClientCredentialsFlowProxyBackend`.

### Other

* Removed the `networkAdaptor` property from the authorization managers. If you need to use a custom networking client, then create a type that conforms to one of the backend protocols in `Sources/SpotifyWebAPI/Authorization/Backends/AuthorizationBackends.swift` based on which authorization method you are using.

- `SpotifyAPILogHandler` is no longer automatically bootstrapped when an instance of `SpotifyAPI` is created. You now must call its `bootstrap` method manually. This allows you to select a different logging backend, if needed.
- Removed `clientSecret` from `AuthorizationCodeFlowPKCEManager` because it is not needed.
- `SpotifyAuthenticationError.errorDescription` is now optional because it can be missing in the JSON payload in rare cases.
- Removed all deprecated symbols.
- Publisher extensions where the output is `URLResponse` are now extensions where the output is `HTTPURLResponse`. Other methods that returned `URLResponse`, such as `SpotifyAPI.filteredPlaylist(_:filters:additionalTypes:market:)`, now also return `HTTPURLResponse`.
- Refactored `ContextOption` and `OffsetOption` as nested types under `PlaybackRequest` (`Context` and `Offset`).
- Added `type` property to `Playlist`.
- Changed the type of properties in the object model that represent URLs from String to URL. `SpotifyAPI.getFromHref(_:responseType)` now accepts a URL as well instead of a string.
- `String.makeCodeChallenge()` is now a static method that accepts the coder verifier as a parameter: `String.makeCodeChallenge(codeVerifier:)`.
- Removed the + and += operators from `Dictionary`.
- The custom `URLComponents` and `URL` initializers are now internal.
- The `scopes` properties of `AuthInfo` and the authorization managers are non-optional. Instead, the lack of scopes is represented by an empty set.
- Renamed `SpotifyLocalError` to `SpotifyGeneralError`.
- Renamed `SpotifyLocalError.httpError(HTTPURLResponse:Data)` to `SpotifyLocalError.httpError(Data:HTTPURLResponse)`
- Renamed `SpotifyAPI.removeAllOccurencesFromPlaylist(_:of:snapshotId:)` to `SpotifyAPI.removeAllOccurrencesFromPlaylist(_:of:snapshotId:)`.
- Renamed `SpotifyAPI.removeSpecificOccurencesFromPlaylist(_:of:)` to `SpotifyAPI.removeSpecificOccurrencesFromPlaylist(_:of:)`.
- Renamed `SpotifyDecodingError.dataDumpfolder` to `dataDumpFolder`.

## [1.6.1] - 2021-4-26

### Fixed

* Fixed a bug that caused a compilation error in Swift 5.4. See [here](https://forums.swift.org/t/invalid-redeclaration-of-synthesized-implementation-for-protocol-requirement-allcases/47715/3).

## [1.6.0] - 2021-4-20

### Added

* Added `SpotifyLocalError.httpError(HTTPURLResponse, Data)`. This error is returned when the status code of the response from the server is in the 4xx or 5xx range and the response body could not be decoded into any of the other errors types (`SpotifyAuthenticationError`, `SpotifyError`, `SpotifyPlayerError`). 

### Changed

* A request will be automatically retried up to three times if it returns a `SpotifyLocalError.httpError` with a status code of 500, 502, 503, or 504.
* When decoding the data from a request into a Swift type, the data will *first* be decoded into an error object if the status code is in the 4xx or 5xx range.

## [1.5.1] - 2021-4-15

### Added

* Added `SpotifyAPI.currentUserFollowedArtists(after:limit:)`.
* Added documentation for each authorization scope that specifies which endpoints the scope is required for.
* Added a ` makeCopy` method to `ClientCredentialsFlowManager`, `AuthorizationCodeFlowManager`, and `AuthorizationCodeFlowPKCEManager`.

## [1.5.0] - 2021-3-30

### Added

* Requests will now be automatically retried up to three times depending on the error received:

    Retries upon receiving a `RateLimitedError`. If a `SpotifyError` or `SpotifyPlayerError` is received, then retries if the status code is 500, 502, 503, or 504.

* Added the following endpoints:

    * `SpotifyAPI.currentUserSavedEpisodes(limit:offset:market:)`
    * `SpotifyAPI.currentUserSavedEpisodesContains(_:)`
    * `SpotifyAPI.saveEpisodesForCurrentUser(_:)`
    * `SpotifyAPI.removeSavedEpisodesForCurrentUser(_:)`
    * `SpotifyAPI.availableMarkets()`

* Added methods for retrieving additional pages of results *concurrently*:

    * `SpotifyAPI.extendPagesConcurrently(_:maxExtraPages:)`
    * `Publisher.extendPagesConcurrently(_:maxExtraPages:)`
    
* Added `Publisher.collectAndSortByOffset()`

* `SpotifyUser` how has the following additional properties: `allowsExplicitContent` and `explicitContentSettingIsLocked`.

### Changed

* The `before` and `after` cases of `TimeReference` now accept a timestamp string instead of a `Date`. `TimeReference` has the static methods `before(_:)` and `after(_:)` which accept Dates instead and return an instance of self.
* Renamed `PlaylistsItemsReference` to `PlaylistItemsReference`.

## [1.4.2] - 2021-3-16

### Fixed

* Fixed a bug where a request to refresh the access token (`refreshTokens(onlyIfExpired:tolerance:`) using  `AuthorizationCodeFlowManager` or  `AuthorizationCodeFlowPKCEManager` failed if the access token was authorized for zero scopes. Compare with 1.4.1.

## [1.4.1] - 2021-3-13

### Fixed

* Fixed a bug where requesting access and refresh tokens using  `AuthorizationCodeFlowManager` or  `AuthorizationCodeFlowPKCEManager` failed if no authorization scopes where requested.

## [1.4.0] - 2021-3-7

### Fixed

* Fixed a bug in `AuthorizationCodeFlowManager.==` and `AuthorizationCodeFlowPKCEManager.==`: The access tokens were being compared twice and the refresh tokens weren't being compared. 

### Added

* Added Method for disabling the bootstrapping of `SpotifyAPILogHandler`: `SpotifyAPILogHandler.disable`.
* Added a new protocol, `ApproximatelyEquatable`, which is conformed to by all types in the object model that have Date or floating point properties or that contain other types with those properties. 

### Changed

* `SpotifyAPI.search` now throws an error if `categories` is empty.
* When comparing the authorization managers for equality, an absolute tolerance of 1 second (instead of three seconds) is used when comparing the expiration dates.

## [1.3.0] - 2021-1-10

### Added

* Added a network adaptor property to `SpotifyAPI` and the authorization managers. This property allows you to use your own network client for all network requests.

## [1.2.1] - 2020-12-31

### Fixed

* Fixed a bug in which the value for the "retry-after" header was not retrieved because the library was expecting it to be in uppercase ("Retry-After"), but the Spotify web API returned it in lowercase. The header is now retrieved in a case-insensitive manner.

### Added

* Linux is now officially supported (tested on Ubuntu 20.04.1)!

## [1.2.0] - 2020-12-26

### Fixed

* Fixed a bug in which the port, username, and password components of a URL were removed by the `URL.removingQueryItems()` method, when it should've only removed the query items and fragment. This caused the methods for requesting access and refresh tokens to fail when the redirect URI had these components. The initializers for `URL` and `URLComponents` now accept a port.

### Changed

* Removed the `showDialog` parameter from `AuthorizationCodeFlowPKCEManager.makeAuthorizationURL(redirectURI:codeChallenge:state:scopes:)` because it is not actually supported by the Authorization Code Flow with Proof Key for Code Exchange. It is only supported by the Authorization Code Flow.
* Removed the period and tilde characters from `String.urlSafeCharacters` because they are reserved in certain components of a URL (although not in the query string, where they will most likely be used).

## [1.1.3] - 2020-12-20

### Added

* Added `RepeatMode.cycled()`
* Added public initializers for `CurrentlyPlayingContext`, `Device`, `PlayHistory`, and `SpotifyContext`.
* Added CaseIterable conformance to `DeviceType`, `SpotifyPlayerError.ErrorReason`, and `TimeRange`. Also added `Hashable` conformance to `TimeRange`.

### Changed

*  Changed the order of the cases in the `RepeatMode` enum from `off`, `track`, `context` to `off`, `context`, `track`, which matches the order that they are cycled through in Spotify clients and in `RepeatMode.cycle()` and `RepeatMode.cycled()`.

## [1.1.2] - 2020-11-29

### Added

* `RepeatMode.cycle()` - Cycles between the different repeat modes.

### Fixed

* Fixed typo in `DeviceType.castAudio.rawValue`.

## [1.1.1] - 2020-11-27

### Changed

* The refresh token is now optional in the initializers `AuthorizationCodeFlowManager.init(clientId:clientSecret:accessToken:expirationDate:refreshToken:scopes:)` and `AuthorizationCodeFlowPKCEManager.init(clientId:clientSecret:accessToken:expirationDate:refreshToken:scopes:)`

## [1.1.0] - 2020-11-14

### Changed

* Made `Endpoints` enum Public.

### Removed

* Removed `Publisher.assignToOptional(_:on:)`.

## [1.0.4] - 2020-11-12

### Added

* Added `localizedDescription` to `SpotifyLocalError.other` with a default value of "An unexpected error occurred.".

## [1.0.3] - 2020-11-09

### Added

* Added `URIsWithPositionsContainer.init(snapshotId:urisWithSinglePosition:)` and `URIsWithPositionsContainer.chunked(urisWithSinglePosition:)`. These methods will aid in removing more than 100 duplicate items from a playlist.

### Changed

* `URIsDictWithInsertionIndex` is now public
* `URIsContainer.init(_:snapshotId:)` and `URIsWithPositionsContainer.init(snapshotId:urisWithPositions:)` now have a default value of `nil` for the snapshot id.

### Deprecated

* Deprecated `URIsWithPositionsContainer` initializer that accepted an array of tuples.

## [1.0.2] - 2020-11-02

### Changed

* Changed docs for `SpotifyAPI.play(_:deviceId:)` to mention that you *can* provide the id of a non-active device, which will cause the given content to be played on that device. Added a new wiki article: [Using the Player Endpoints](https://github.com/Peter-Schorn/SpotifyAPI/wiki/Using-the-Player-Endpoints).

## [1.0.1] - 2020-10-31

### Changed

* The URL query parameters for all requests are now sorted. This may improve caching.

## [1.0.0] - 2020-10-29

**SpotifyAPI is out of beta!**

### Changed

* Small documentation changes

## [0.10.0] - 2020-10-28

### Changed

* Changed the type of `SpotifyPlayerError.reason` from  `String` to an enum: `ErrorReason`. This provides additional type safety.

## [0.9.1] - 2020-10-27

### Fixed

Fixed bugs in which the following methods called the wrong endpoints:

* `SpotifyAPI.currentUserSavedTracks(limit:offset:market:)`
* `SpotifyAPI.currentUserSavedShowsContains(_:)`

All of the methods in `SpotifyAPI` are now covered by unit tests!

## [0.9.0] - 2020-10-27

### Added

* Added `SpotifyAPI.authorizationManagerDidDeauthorize`. This publisher emits when the `deauthorize()` method of the authorization manager is called; `SpotifyAPI.authorizationManagerDidChange` no longer emits when `deauthorize()`  is called.

### Fixed

* Fixed bug in which creating an instance of `SpotifyAPI` using `init(from:)` did not properly setup the subscription to `authorizationManager.didChange`.

## [0.8.1] - 2020-10-24

### Fixed

* Fixed a bug with the JSON data being in the incorrect format for the endpoints for following and unfollowing artists and users.
* Fixed a typo in the raw value of `TimeRange.shortTerm`, which caused an "invalid request" error from Spotify.

## [0.8.0] - 2020-10-23

### Added

* Added the following initializers to the authorization managers:
    * `AuthorizationCodeFlowPKCEManager.init(clientId:clientSecret:accessToken:expirationDate:refreshToken:scopes:)`
    * `AuthorizationCodeFlowManager.init(clientId:clientSecret:accessToken:expirationDate:refreshToken:scopes:)`
    * `ClientCredentialsFlowManager.init(clientId:clientSecret:accessToken:expirationDate:)`

These initializers should rarely be needed. They should only be used if the authorization information was retrieved from an external source outside this library. In cases where you simply need to save the authorization information to persistent storage, encode the entire authorization manager instance to data using a `JSONEncoder` and then decode the data from storage later. See [Saving authorization information to persistent storage](https://github.com/Peter-Schorn/SpotifyAPI/wiki/Saving-authorization-information-to-persistent-storage.) for more information.

* Added the prefix "sample" to some of the properties in the `SpotifyExampleContent` module to prevent potential confusion.

### Fixed

* Fixed a bug with the JSON data not being decoded from the `SpotifyAPI.recommendations(_:limit:market:)` endpoint because some of the values were in all uppercase.

## [0.7.6] - 2020-10-22

### Fixed

* Minor bug fixes and small changes to documentation

## [0.7.5] - 2020-10-20

### Changed

* Updated documentation for playing content to mention that shows can be used for `contextURI`.
* Simplified the `localizedDescription` for the error objects. The descriptions are now more suitable for the end user. Always use the string representation of the error objects for debugging purposes; only use `localizedDescription` to display the error to the end user.

### Fixed

* Fixed a bug where the values passed into `SpotifyLocalError.invalidState` were transposed. **Edit**: Due to a source-control issue, this change was not released in this version. It was released in the next version.

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

- Fixed bug in which calling `SpotifyAPI.currentPlayback()` when there were no available devices returned an error because Spotify returned no data. Now, `nil` is returned when Spotify returns no data.
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
