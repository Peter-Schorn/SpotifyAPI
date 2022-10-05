import Foundation

/**
 A Recommendations Response Object. Returned by
 ``SpotifyAPI/recommendations(_:limit:market:)``.
 
 See also ``RecommendationSeed``.
 */
public struct RecommendationsResponse: Codable, Hashable {

    /**
     An array of recommendation seed objects.

     Consider using the ``seedArtists``, ``seedTracks``, or ``seedGenres``
     computed properties, which are backed by this property.
      
     The seeds will be returned based on the ``seedArtists``, ``seedTracks``,
     and ``seedGenres`` parameters of ``TrackAttributes``, *in that order*. They
     will then be ordered by the order of each artist, track, and genre URI/id
     that was provided.
     
     Usually, there will be one seed object for each artist, track, and genre.
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
    
    /**
     A Recommendations Response Object. Returned by
     ``SpotifyAPI/recommendations(_:limit:market:)``.
     
     See also ``RecommendationSeed``.
     
     - Parameters:
       - seeds: An array of recommendation seed objects.
       - tracks: An array of track objects.
     */
    public init(
        seeds: [RecommendationSeed],
        tracks: [Track]
    ) {
        self.seeds = seeds
        self.tracks = tracks
    }

}

extension RecommendationsResponse: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.

     Dates are compared using `timeIntervalSince1970`, so they are considered
     floating point properties for the purposes of this method.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {

        return self.seeds == other.seeds &&
                self.tracks.isApproximatelyEqual(to: other.tracks)

    }

}
