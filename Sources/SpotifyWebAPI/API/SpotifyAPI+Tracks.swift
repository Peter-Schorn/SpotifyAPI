import Foundation
import Combine

public extension SpotifyAPI {
    
    /**
     Get a Track.
     
     See also `tracks(_:market:)` (gets multiple tracks).
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uri: The URI for a track.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][3] or
             the string "from_token". Provide this parameter if you want
             to apply [Track Relinking][2].
     - Returns: The full version of a track.

     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-track/
     [2]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     [3]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func track(
        _ uri: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<Track, Error> {
        
        do {
            
            let trackId = try SpotifyIdentifier(uri: uri).id
            
            return self.getRequest(
                path: "/tracks/\(trackId)",
                queryItems: ["market": market],
                requiredScopes: []
            )
            .spotifyDecode(Track.self)
            
        } catch {
            return error.anyFailingPublisher(Track.self)
        }
        
    }
    
    /**
     Get multiple Tracks.
     
     See also `track(_:market:)` (gets a single track).
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uris: An array of track URIs. Maximum: 50.
       - market: *Optional*. An [ISO 3166-1 alpha-2 country code][3] or
             the string "from_token". Provide this parameter if you want
             to apply [Track Relinking][2].
     - Returns: The full versions of up to 50 `Track` object . Tracks are returned
           in the order requested. If a track is not found, `nil` is
           returned in the appropriate position. Duplicate tracks URIs
           in the request will result in duplicate tracks in the response.
           
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-several-tracks/
     [2]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     [3]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func tracks(
        _ uris: [SpotifyURIConvertible],
        market: String? = nil
    ) -> AnyPublisher<[Track?], Error> {
        
        do {
            
            let trackIds = try SpotifyIdentifier
                    .commaSeparatedIdsString(uris)
            
            return self.getRequest(
                path: "/tracks",
                queryItems: [
                    "ids": trackIds,
                    "market": market
                ],
                requiredScopes: []
            )
            .spotifyDecode([String: [Track?]].self)
            .tryMap { dict -> [Track?] in
                if let tracks = dict["tracks"] {
                    return tracks
                }
                throw SpotifyLocalError.topLevelKeyNotFound(
                    key: "tracks", dict: dict
                )
            }
            .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher([Track?].self)
        }
        
    }
    
    
    /**
     Get audio analysis for a track.
     
     See also `trackAudioFeatures(_:)` (gets the audio features for
     a single track) and `tracksAudioFeatures(_:)` (get the audio features
     for multiple tracks).
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uri: The URI for a track.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/
     */
    func trackAudioAnalysis(
        _ uri: SpotifyURIConvertible
    ) -> AnyPublisher<AudioAnalysis, Error> {
        
        do {
            
            let trackId = try SpotifyIdentifier(uri: uri).id
            
            return self.getRequest(
                path: "/audio-analysis/\(trackId)",
                queryItems: [:],
                requiredScopes: []
            )
            .spotifyDecode(AudioAnalysis.self)
            
        } catch {
            return error.anyFailingPublisher(AudioAnalysis.self)
        }
        
    }
    
    /**
     Get audio features for a track.

     See also `tracksAudioFeatures(_:)` (gets the audio features for
     multiple tracks) and `trackAudioAnalysis(_:)`.
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uri: The URI for a track.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/
     */
    func trackAudioFeatures(
        _ uri: SpotifyURIConvertible
    ) -> AnyPublisher<AudioFeatures, Error> {
        
        do {
            
            let trackId = try SpotifyIdentifier(uri: uri).id
            
            return self.getRequest(
                path: "/audio-features/\(trackId)",
                queryItems: [:],
                requiredScopes: []
            )
            .spotifyDecode(AudioFeatures.self)
            
        } catch {
            return error.anyFailingPublisher(AudioFeatures.self)
        }
        
    }
    
    /**
     Get audio features for multiple tracks.
     
     See also `trackAudioFeatures(_:)` (gets the audio features for
     a single track) and `trackAudioAnalysis(_:)`.
     
     No scopes are required for this endpoint.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameter uris: An array of up to 100 URIs for tracks.
     - Returns: Results are returned in the order requested.
           If the audio features for a track  is not found, `nil` is returned
           in the appropriate position. Duplicate ids in the request will
           result in duplicate results in the response.
     
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/tracks/get-several-tracks/
     */
    func tracksAudioFeatures(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<[AudioFeatures?], Error> {
        
        do {
            
            let trackIds = try SpotifyIdentifier
                    .commaSeparatedIdsString(uris)
            
            return self.getRequest(
                path: "/audio-features",
                queryItems: ["ids": trackIds],
                requiredScopes: []
            )
            .spotifyDecode([String: [AudioFeatures?]].self)
                .tryMap { dict -> [AudioFeatures?] in
                    if let audioFeatures = dict["audio_features"] {
                        return audioFeatures
                    }
                    throw SpotifyLocalError.topLevelKeyNotFound(
                        key: "audio_features", dict: dict
                    )
                }
                .eraseToAnyPublisher()
            
            
        } catch {
            return error.anyFailingPublisher([AudioFeatures?].self)
        }
        
    }
    
    
}
