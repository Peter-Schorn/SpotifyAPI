import Foundation

/**
 A Spotify ID Category, which is the identifier that appears near the beginning
 of a Spotify URI.
 
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
    
    /// An audiobook.
    case audiobook
    
    /// An audiobook chapter.
    case chapter

    /// An ad.
    case ad
    
    /// Unknown. This should be rare.
    case unknown

    /**
     A collection.
     
     When the user is playing their saved tracks (labeled as "Liked Songs" in
     the native Spotify clients), ``SpotifyContext``.``SpotifyContext/type``
     will be equal to this value.
     */
    case collection
 
    /**
     Creates a new instance with the specified raw value.
     
     The id categories:
     
     * ``artist``
     * ``album``
     * ``track``
     * ``playlist``
     * ``show``
     * ``episode``
     * ``local``
     * ``user``
     * ``genre``
     * ``ad``
     * ``audiobook``
     * ``chapter``
     * ``unknown``
     * ``collection``
     
     - Parameter rawValue: The raw value for an id category. **It is**
           **case-insensitive**.
     */
    @inlinable
    public init?(rawValue: String) {
        
        let lowercasedRawValue = rawValue.lowercased()
        for category in Self.allCases {
            if category.rawValue == lowercasedRawValue {
                self = category
                return
            }
        }
        return nil
        
    }
    
}
