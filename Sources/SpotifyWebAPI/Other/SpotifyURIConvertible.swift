import Foundation

/**
 A type that can convert itself to a [Spotify URI][1].

 `SpotifyIdentifier`, `String`, `SubString`, and some of the objects
 returned by the Spotify web API are conforming types. Usually, you
 should not need to conform additional types to this protocol.

 [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
 */
public protocol SpotifyURIConvertible {
    
    /**
     The unique resource identifier for the
     Spotify content.
     
     See [spotify uris and ids][1].
     
     [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
     */
    var uri: String { get }

}

extension String: SpotifyURIConvertible {

    @inlinable @inline(__always)
    public var uri: Self { self }

}

extension Substring: SpotifyURIConvertible {

    @inlinable @inline(__always)
    public var uri: String { String(self) }

}
