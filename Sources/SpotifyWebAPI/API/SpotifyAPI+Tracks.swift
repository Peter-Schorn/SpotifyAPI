import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public extension SpotifyAPI {

    // MARK: Tracks
    
    /**
     Get a Track.
     
     See also ``tracks(_:market:)`` - gets multiple tracks
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uri: The URI for a track.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". Provide this parameter if you want to apply [Track
             Relinking][3].
     - Returns: The full version of a track.

     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-track
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    func track(
        _ uri: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<Track, Error> {
        
        do {
            
            let trackId = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.track]
            ).id
            
            return self.getRequest(
                path: "/tracks/\(trackId)",
                queryItems: ["market": market],
                requiredScopes: []
            )
            .decodeSpotifyObject(Track.self)
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Get multiple Tracks.
     
     See also ``track(_:market:)`` - gets a single track
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uris: An array of track URIs. Maximum: 50. Passing in an empty array
             will immediately cause an empty array of results to be returned
             without a network request being made.
       - market: An [ISO 3166-1 alpha-2 country code][3] or the string
             "from_token". Provide this parameter if you want to apply [Track
             Relinking][2].
     - Returns: The full versions of up to 50 ``Track`` objects. Tracks are
           returned in the order requested. If a track is not found, `nil` is
           returned in the appropriate position. Duplicate tracks URIs in the
           request will result in duplicate tracks in the response.
           
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-several-tracks
     [2]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     [3]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func tracks(
        _ uris: [SpotifyURIConvertible],
        market: String? = nil
    ) -> AnyPublisher<[Track?], Error> {
        
        do {
            
            if uris.isEmpty {
                return ResultPublisher([])
                    .eraseToAnyPublisher()
            }
            
            let trackIds = try SpotifyIdentifier
                .commaSeparatedIdsString(
                    uris, ensureCategoryMatches: [.track]
                )
            
            return self.getRequest(
                path: "/tracks",
                queryItems: [
                    "ids": trackIds,
                    "market": market
                ],
                requiredScopes: []
            )
            .decodeSpotifyObject([String: [Track?]].self)
            .tryMap { dict -> [Track?] in
                if let tracks = dict["tracks"] {
                    return tracks
                }
                throw SpotifyGeneralError.topLevelKeyNotFound(
                    key: "tracks", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Get audio analysis for a track.
     
     The Audio Analysis endpoint provides low-level audio analysis for all of
     the tracks in the Spotify catalog. The Audio Analysis describes the track’s
     structure and musical content, including rhythm, pitch, and timbre. All
     information is precise to the audio sample.

     Many elements of analysis include confidence values, a floating-point
     number ranging from 0.0 to 1.0. Confidence indicates the reliability of its
     corresponding attribute. Elements carrying a small confidence value should
     be considered speculative. There may not be sufficient data in the audio to
     compute the attribute with high certainty.
     
     See also:
     
     * ``trackAudioFeatures(_:)`` - gets the audio features for a single track
     * ``tracksAudioFeatures(_:)`` - gets the audio features for multiple tracks
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uri: The URI for a track.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-audio-analysis
     */
    func trackAudioAnalysis(
        _ uri: SpotifyURIConvertible
    ) -> AnyPublisher<AudioAnalysis, Error> {
        
        do {
            
            let trackId = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.track]
            ).id
            
            return self.getRequest(
                path: "/audio-analysis/\(trackId)",
                queryItems: [:],
                requiredScopes: []
            )
            .decodeSpotifyObject(AudioAnalysis.self)
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Get audio features for a track.

     See also:
     
     * ``tracksAudioFeatures(_:)`` - gets the audio features for multiple tracks
     * ``trackAudioAnalysis(_:)`` - gets audio analysis for a track
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uri: The URI for a track.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-audio-features
     */
    func trackAudioFeatures(
        _ uri: SpotifyURIConvertible
    ) -> AnyPublisher<AudioFeatures, Error> {
        
        do {
            
            let trackId = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.track]
            ).id
            
            return self.getRequest(
                path: "/audio-features/\(trackId)",
                queryItems: [:],
                requiredScopes: []
            )
            .decodeSpotifyObject(AudioFeatures.self)
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
    /**
     Get audio features for multiple tracks.
     
     See also:
     
     * ``trackAudioFeatures(_:)`` - gets the audio features for a single track
     * ``trackAudioAnalysis(_:)`` - gets audio analysis for a track.
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uris: An array of up to 100 URIs for tracks. Passing in an
             empty array will immediately cause an empty array of results to be
             returned without a network request being made.
     - Returns: Results are returned in the order requested. If the audio
           features for a track is not found, `nil` is returned in the
           appropriate position. Duplicate ids in the request will result in
           duplicate results in the response.
     
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-several-audio-features
     */
    func tracksAudioFeatures(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<[AudioFeatures?], Error> {
        
        do {
            
            if uris.isEmpty {
                return ResultPublisher([])
                    .eraseToAnyPublisher()
            }
            
            let trackIds = try SpotifyIdentifier
                .commaSeparatedIdsString(
                    uris, ensureCategoryMatches: [.track]
                )
            
            return self.getRequest(
                path: "/audio-features",
                queryItems: ["ids": trackIds],
                requiredScopes: []
            )
            .decodeSpotifyObject([String: [AudioFeatures?]].self)
            .tryMap { dict -> [AudioFeatures?] in
                if let audioFeatures = dict["audio_features"] {
                    return audioFeatures
                }
                throw SpotifyGeneralError.topLevelKeyNotFound(
                    key: "audio_features", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
            
        } catch {
            return error.anyFailingPublisher()
        }
        
    }
    
}
