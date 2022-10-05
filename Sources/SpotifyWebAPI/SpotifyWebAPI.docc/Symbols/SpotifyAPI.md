# ``SpotifyWebAPI/SpotifyAPI``

## Topics

### Initializers

- ``init(authorizationManager:networkAdaptor:)``
- ``init(from:)``

### Authorization

- ``authorizationManager``
- ``authorizationManagerDidChange``
- ``authorizationManagerDidDeauthorize``

### Network Adaptor

- ``networkAdaptor``

### Albums

- ``album(_:market:)``
- ``albums(_:market:)``
- ``albumTracks(_:market:limit:offset:)``

### Artists

- ``artist(_:)``
- ``artists(_:)``
- ``artistAlbums(_:groups:country:limit:offset:)``
- ``artistTopTracks(_:country:)``
- ``relatedArtists(_:)``

### Audiobooks

- ``audiobook(_:market:)``
- ``audiobooks(_:market:)``
- ``chapter(_:market:)``
- ``chapters(_:market:)``

### Browse

- ``category(_:country:locale:)``
- ``categories(country:locale:limit:offset:)``
- ``categoryPlaylists(_:country:limit:offset:)``
- ``featuredPlaylists(locale:country:timestamp:limit:offset:)``
- ``newAlbumReleases(country:limit:offset:)``
- ``recommendations(_:limit:market:)``
- ``recommendationGenres()``

### Episodes

- ``episode(_:market:)``
- ``episodes(_:market:)``

### Follow

- ``usersFollowPlaylist(_:userURIs:)``
- ``currentUserFollowedArtists(after:limit:)``
- ``currentUserFollowsArtists(_:)``
- ``followArtistsForCurrentUser(_:)``
- ``unfollowArtistsForCurrentUser(_:)``
- ``currentUserFollowsUsers(_:)``
- ``followUsersForCurrentUser(_:)``
- ``unfollowUsersForCurrentUser(_:)``
- ``followPlaylistForCurrentUser(_:publicly:)``
- ``unfollowPlaylistForCurrentUser(_:)``

### Library

- ``currentUserSavedAlbums(limit:offset:market:)``
- ``currentUserSavedTracks(limit:offset:market:)``
- ``currentUserSavedEpisodes(limit:offset:market:)``
- ``currentUserSavedShows(limit:offset:market:)``
- ``currentUserSavedAlbumsContains(_:)``
- ``currentUserSavedTracksContains(_:)``
- ``currentUserSavedEpisodesContains(_:)``
- ``currentUserSavedShowsContains(_:)``
- ``saveAlbumsForCurrentUser(_:)``
- ``saveTracksForCurrentUser(_:)``
- ``saveEpisodesForCurrentUser(_:)``
- ``saveShowsForCurrentUser(_:)``
- ``removeSavedAlbumsForCurrentUser(_:)``
- ``removeSavedTracksForCurrentUser(_:)``
- ``removeSavedEpisodesForCurrentUser(_:)``
- ``removeSavedShowsForCurrentUser(_:market:)``

### Markets

- ``availableMarkets()``

### Personalization

- ``currentUserTopArtists(_:offset:limit:)``
- ``currentUserTopTracks(_:offset:limit:)``

### Player

- <doc:Using-the-Player-Endpoints>
- ``availableDevices()``
- ``currentPlayback(market:)``
- ``recentlyPlayed(_:limit:)``
- ``queue()``
- ``addToQueue(_:deviceId:)``
- ``skipToNext(deviceId:)``
- ``skipToPrevious(deviceId:)``
- ``pausePlayback(deviceId:)``
- ``resumePlayback(deviceId:)``
- ``play(_:deviceId:)``
- ``seekToPosition(_:deviceId:)``
- ``setRepeatMode(to:deviceId:)``
- ``setVolume(to:deviceId:)``
- ``setShuffle(to:deviceId:)``
- ``transferPlayback(to:play:)``

### Playlists

- ``filteredPlaylist(_:filters:additionalTypes:market:)``
- ``playlist(_:market:)``
- ``filteredPlaylistItems(_:filters:additionalTypes:limit:offset:market:)``
- ``playlistTracks(_:limit:offset:market:)``
- ``playlistItems(_:limit:offset:market:)``
- ``userPlaylists(for:limit:offset:)``
- ``currentUserPlaylists(limit:offset:)``
- ``playlistImage(_:)``
- ``addToPlaylist(_:uris:position:)``
- ``createPlaylist(for:_:)``
- ``reorderPlaylistItems(_:body:)``
- ``replaceAllPlaylistItems(_:with:)``
- ``changePlaylistDetails(_:to:)``
- ``uploadPlaylistImage(_:imageData:)``
- ``removeAllOccurrencesFromPlaylist(_:of:snapshotId:)``
- ``removeSpecificOccurrencesFromPlaylist(_:of:)``

### Search

- ``search(query:categories:market:limit:offset:includeExternal:)``

### Shows

- ``show(_:market:)``
- ``shows(_:market:)``
- ``showEpisodes(_:market:offset:limit:)``

### Tracks

- ``track(_:market:)``
- ``tracks(_:market:)``
- ``trackAudioAnalysis(_:)``
- ``trackAudioFeatures(_:)``
- ``tracksAudioFeatures(_:)``

### User Profile

- ``userProfile(_:)``
- ``currentUserProfile()``

### Utilities

- ``getFromHref(_:responseType:)``
- ``extendPages(_:maxExtraPages:)``
- ``extendPagesConcurrently(_:maxExtraPages:)``

### Logging

- ``logger``
- ``apiRequestLogger``
- ``authDidChangeLogger``
- ``setupDebugging()``
