import Foundation

/**
 A type that can convert itself to a Spotify URI.

 Read more about [Spotify URIs][1].

 The only requirement is
 ```
 var uri: String { get }
 ```
 
 ``SpotifyIdentifier``, `String`, `SubString`, and some of the objects returned
 by the Spotify web API are conforming types. Usually, you should not need to
 conform additional types to this protocol.
 
 A Spotify URI has the following format:
 ```
 "spotify:\(idCategory):\(id)"
 ```
 
 The id category must be one of the following:
 
 * ``IDCategory/artist``
 * ``IDCategory/album``
 * ``IDCategory/track``
 * ``IDCategory/playlist``
 * ``IDCategory/show``
 * ``IDCategory/episode``
 * ``IDCategory/local``
 * ``IDCategory/user``
 * ``IDCategory/genre``
 * ``IDCategory/audiobook``
 * ``IDCategory/chapter``
 * ``IDCategory/ad``
 * ``IDCategory/unknown``
 * ``IDCategory/collection``

 [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
 */
public protocol SpotifyURIConvertible {
    
    /**
     The unique resource identifier for the Spotify content.
     
     See [Spotify URIs and ids][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    var uri: String { get }

}

extension String: SpotifyURIConvertible {

    /// Returns `self`, with the assumption that it represents a [Spotify
    /// URI](https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids).
    @inlinable @inline(__always)
    public var uri: Self { self }

}

extension Substring: SpotifyURIConvertible {

    /// Returns `self` converted to `String`, with the assumption that it
    /// represents a [Spotify
    /// URI](https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids).
    @inlinable @inline(__always)
    public var uri: String { String(self) }

}
