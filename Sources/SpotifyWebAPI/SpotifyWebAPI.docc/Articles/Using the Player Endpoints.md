# Using the Player Endpoints

Use the SpotifyAPI player endpoints.

## Overview

When performing a player command that is restricted, ``SpotifyPlayerError`` will be returned.  It contains the following properties:

* ``SpotifyPlayerError/message``: A short description of the cause of the error.
* ``SpotifyPlayerError/reason``: A player error reason.
* ``SpotifyPlayerError/statusCode``: The HTTP status code that is also returned in the response header.

Unfortunately, there is a bug at the moment with the Spotify web API in which  ``SpotifyPlayerError/ErrorReason/unknown`` is return in cases where a more specific error would be expected. For example, trying to skip to the previous track when there is no previous track in the context returns this error instead of ``SpotifyPlayerError/ErrorReason/noPreviousTrack``.

## "Player command failed: No active device found"

 Just because you have a Spotify client (e.g., the mobile app, the desktop application, or the web player) open does not necessarily mean it is considered an *active* device, it just means that device is *available*. When content is playing on a device, it is considered active. When playback ceases on a device, it typically becomes inactive only a few minutes later.

While your program is running, you can use the [available devices endpoint](https://developer.spotify.com/console/get-users-available-devices/) on the Spotify web API console—as well as the ``SpotifyAPI/availableDevices()`` method in this library—to check which devices are active and/or available.

For most player endpoints that accept a `deviceId` parameter, if you provide `nil` (which is the default), then the active device is targeted. If there is no *active* device, then the request will fail (even if there are *available* devices) because it isn't clear which device should be targeted for the command. Furthermore, providing the id of a non-active device will also cause the request to fail. In both cases, you must call ``SpotifyAPI/transferPlayback(to:play:)`` first in order to transfer playback to an available device, thereby making it active. On exception to the latter rule is the ``SpotifyAPI/play(_:deviceId:)`` endpoint, which *does* allow you to provide the id of a non-active device, even if there is currently an active device. Calling this endpoint with a non-active device will automatically transfer playback to that device, thereby making it active.

Below is a helper method for playing content on either the active device or the first available device found. It reduces the complexity of working with the ``SpotifyAPI/play(_:deviceId:)`` endpoint. 

```swift
extension SpotifyAPI where AuthorizationManager: SpotifyScopeAuthorizationManager {

    /**
     Makes a call to `availableDevices()` and plays the content on the
     active device if one exists. Else, plays content on the first available
     device.
     
     - Parameter playbackRequest: A request to play content.
     */
    func getAvailableDeviceThenPlay(
        _ playbackRequest: PlaybackRequest
    ) -> AnyPublisher<Void, Error> {
        
        return self.availableDevices().flatMap {
            devices -> AnyPublisher<Void, Error> in
    
            // A device must have an id and must not be restricted
            // in order to accept web API commands.
            let usableDevices = devices.filter { device in
                !device.isRestricted && device.id != nil
            }

            // If there is an active device, then it's usually a good idea
            // to use that one. For example, if content is already playing,
            // then it will be playing on the active device. If not, then
            // just use the first available device.
            let device = usableDevices.first(where: \.isActive)
                    ?? usableDevices.first
            
            if let deviceId = device?.id {
                return self.play(playbackRequest, deviceId: deviceId)
            }
            else {
                return SpotifyGeneralError.other(
                    "no active or available devices",
                    localizedDescription:
                    "There are no devices available to play content on. " +
                    "Try opening the Spotify app on one of your devices."
                )
                .anyFailingPublisher()
            }
            
        }
        .eraseToAnyPublisher()
        
    }

}
```

## Playback Request Examples

**Play a single track with playback starting at 10 seconds:**

```swift
let track = "spotify:track:6jvqaaUtBmcnxQnf5XKzFo"
let playbackRequest = PlaybackRequest(track, positionMS: 10_000)
```

You can also provide an episode URI to this initializer.

**Play a playlist:**

```swift
let playlist = "spotify:playlist:37i9dQZF1DXaQ34lqGBfrU"

let playbackRequest = PlaybackRequest(
    context: .contextURI(playlist),
    offset: nil
)
```

The first track that plays will depend on the user's shuffle state.

**Play a playlist starting at the second track:**

```swift
let playlist = "spotify:playlist:37i9dQZF1DXaQ34lqGBfrU"

let playbackRequest = PlaybackRequest(
    context: .contextURI(playlist),
    offset: .position(1)  // The offset is zero-indexed
)
```

**Play an album starting with a specific track:**

```swift
let album = "spotify:album:6QaVfG1pHYl1z15ZxkvVDW"
let track = "spotify:track:0xIuNHHcKI1JDuBPlSwzb1"

let playbackRequest = PlaybackRequest(
    context: .contextURI(album),
    offset: .uri(track)
)
```

**Play a list of tracks:**

```swift
let tracks = [
    "spotify:track:7JIV9UYKpti5xWgq6lfNNJ",  // Ode to Viceroy
    "spotify:track:1jhtxc7ON8ZzgvWGPwWXUN",  // Baby Blue
    "spotify:track:3JLrri1xSCui3bzITDJbkk",  // The Rain Song
    "spotify:track:6dsq7Nt5mIFzvm5kIYNORy"   // 15 Step
]

let playbackRequest = PlaybackRequest(
    context: .uris(tracks),
    offset: nil
)
```

**Play an episode within the the context of a show starting at 10 minutes:**

```swift
let show = "spotify:show:4rOoJ6Egrf8K2IrywzwOMk"
let episode = "spotify:episode:1saFhnv5h33EWizm2yKECl"

let playbackRequest = PlaybackRequest(
    context: .contextURI(show),
    offset: .uri(episode),
    positionMS: 600_000
)
```
