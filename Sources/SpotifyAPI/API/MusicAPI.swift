import Foundation
import Combine
import Logger

// MARK: The methods for retrieving music content (e.g., songs, albums, artists)

public extension SpotifyAPI {
    
    /**
     Gets a single artist.
     
     No scopes are required for this endpoint.
    
     See also `getArtists(uris:)` (gets several artists).

     Read more at the [web API reference][1].
    
     - Parameter uri: The uri for the artist.
     - Returns: The full version of a Spotify [artist object][2].

     [1]: https://developer.spotify.com/documentation/web-api/reference/artists/get-artist/
     [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-full
     */
    func getArtist<URI: SpotifyURIConvertible>(
        uri: URI
    ) -> AnyPublisher<Artist, Error>  {
        
        do {
            let id = try SpotifyIdentifier(uri: uri.uri).id
            
            logger.trace("uri: \(uri)")
            return self.getRequest(
                endpoint: Endpoints.apiEndpoint("/artists/\(id)"),
                requiredScopes: [],
                responseType: Artist.self
            )
            
        } catch {
            return error.anyFailingPublisher(Artist.self)
        }
        
    }
    
    /**
     Gets several artists.
     
     No scopes are required for this endpoint.

     Objects are returned in the order requested.
     If an object is not found, a nill value is returned in the
     appropriate position.
     Duplicate ids in the query will result in duplicate objects in the response.
     
     See also `getArtist(uri:)` (gets a single artist).
     
     - Parameter uri: The uri for the artist.
     - Returns: An array of the full versions of [artist objects][2].
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/artists/get-several-artists/
     [2]: https://developer.spotify.com/documentation/web-api/reference/object-model/#artist-object-full
     */
    func getArtists<URI: SpotifyURIConvertible>(
        uris: [URI]
    ) -> AnyPublisher<[Artist?], Error> {
        
        do {

            let idsString = try SpotifyIdentifier
                    .commaSeparatedIdsString(uris)
            
            return self.getRequest(
                endpoint: Endpoints.apiEndpoint(
                    "/artists",
                    queryItems: ["ids": idsString]
                ),
                requiredScopes: [],
                responseType: [String: [Artist?]].self
            )
            .tryMap { dict -> [Artist?] in
                if let artists = dict["artists"] {
                    return artists
                }
                throw SpotifyLocalError.other(
                    "SpotifyAPI: getArtists: artists key for " +
                    "top-level dict was missing. raw data:\n\n" +
                    "\(dict)"
                )
            }
            .eraseToAnyPublisher()
            
            
        } catch {
            return error.anyFailingPublisher([Artist?].self)
        }
        
    }
    
    func search() {
        
        
        
        
    }
    

}
