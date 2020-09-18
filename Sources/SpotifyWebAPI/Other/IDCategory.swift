import Foundation

/**
 The Spotify ID Category, which is the identifier that appears
 near the beginning of a Spotify URI.
 
 In this URI:
 ```
 "spotify:track:6rqhFgbbKwnb9MLmUQDhG6"
 ```
 "track" is the id category.
 
 Read more at the [Spotify web API reference][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
 - tag: IDCategory
 */
public enum IDCategory: String, CaseIterable, Codable, Hashable {

    /// An artist.
    case artist
    
    /// An album.
    case album
    
    /// A track.
    case track
    
    /// A playlist.
    case playlist
    
    /// A show.
    case show
    
    /// A podcast episode.
    case episode
    
    /// See [Identifying Local Files][1].
    ///
    /// [1]: https://developer.spotify.com/documentation/general/guides/local-files-spotify-playlists/
    case local
    
    /// A Spotify user.
    case user
    
    /// A genre.
    case genre
    
    /// Unknown. This should be rare.
    case unknown
 
    /**
     Creates a new instance with the specified raw value.
     
     - Parameter rawValue: The raw value to use for the id category.
           **It is case-insensitive**.
     */
    @inlinable
    public init?(rawValue: String) {
        // This is all because of one endpoint that just HAD to return the
        // id cateogry in all-uppercase, unlike all the other endpoints.
        switch rawValue.lowercased() {
            case "artist":
                self = .artist
            case "album":
                self = .album
            case "track":
                self = .track
            case "playlist":
                self = .playlist
            case "show":
                self = .show
            case "episode":
                self = .episode
            case "local":
                self = .local
            case "user":
                self = .user
            case "genre":
                self = .genre
            case "unknown":
                self = .unknown
            default:
                return nil
        }
    }
    
}
