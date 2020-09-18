import Foundation

/**
 A [Recommendations Response Object][1]. Returned by
 `SpotifyAPI.recommendations(_:limit:market:)`. See also
 `RecommendationSeed`.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/#recommendations-response-object
 */
public struct RecommendationsResponse: Codable, Hashable {

    /**
     An array of [recomendation seed objects][1].

     Consider using the `seedArtists`, `seedTracks`, or `seedGenres`
     convenience properties.
     
     The seeds will be returned based on the `seedArtists`, `seedTracks`, and
     `seedGenres` parameters of `TrackAttributes`, *in that order*. They will
     then be ordered by the order of each artist, track, and genre URI/id
     that was provided.
     
     Usually, there will be one seed object for each artist, track, and genre.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/#recommendation-seed-object
     */
    public let seeds: [RecommendationSeed]
    
    /// An array of simplified track objects ordered according to the parameters
    /// supplied.
    public let tracks: [Track]
    
    /// The seed artists. Equivalent to `seeds.filter { $0.type == .artist }`.
    public var seedArtists: [RecommendationSeed] {
        return seeds.filter { $0.type == .artist }
    }
    
    /// The seed tracks. Equivalent to `seeds.filter { $0.type == .track }`.
    public var seedTracks: [RecommendationSeed] {
        return seeds.filter { $0.type == .track }
    }
    
    /// The seed genres. Equivalent to `seeds.filter { $0.type == .genre }`.
    public var seedGenres: [RecommendationSeed] {
        return seeds.filter { $0.type == .genre }
    }
    

}
