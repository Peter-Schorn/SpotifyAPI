import Foundation
import Combine
import Logger

extension SpotifyAPI {
    
    /**
     Makes a get request to the Spotify web API.
     Automatically refreshes the access token if necessary.
     
     The base url that the path and query items are appended to is
     ```
     "https://api.spotify.com/v1"
     ```
     - Parameters:
       - path: The path to the endpoint, which will be appended to the
             base url above.
       - queryItems: The URL query items.
       - requiredScopes: The scopes required for this endpoint.
       - responseType: The expected response type from the Spotify
             web API.
     */
    func getRequest<ResponseType: Decodable>(
        path: String,
        queryItems: [String : LosslessStringConvertible?],
        requiredScopes: Set<Scope>,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {
        
        return apiRequest(
            path: path,
            queryItems: queryItems,
            httpMethod: "GET",
            makeHeaders: Headers.bearerAuthorization(_:),
            body: nil as Data?,
            requiredScopes: requiredScopes,
            responseType: ResponseType.self
        )
        
    }
    
    /**
     Makes a request to the Spotify Web API.
     All requests to endpoints other than those for authorizing
     the app and retrieving/refreshing the tokens call through
     to this method.
     
     The refresh token will be refreshed automatically if needed
     before the request is made.
     
     If you are making a get request, use
     `self.getRequest(path:queryItems:requiredScopes:responseType:)`
     instead, which is a thin wrapper that calls though to this method.
     
     The base url that the path and query items are appended to is
     ```
     "https://api.spotify.com/v1"
     ```
     
     A closure that accepts the access token must be used
     to make the headers because the access token will not
     be accessed until a call to `self.refreshAccessToken(onlyIfExpired: true)`
     is made. This function may return a new access token to be
     used in the headers.
     
     - Parameters:
       - path: The path to the endpoint, which will be appended to the
             base url above.
       - queryItems: The URL query items.
       - httpMethod: The http method.
       - makeHeaders: A function that accepts an access token and
             returns a dictionary of headers.
       - body: The body of the request.
       - requiredScopes: The scopes required for this endpoint.
       - responseType: The expected response type from the Spotify
             web API.
     */
    func apiRequest<Body: Encodable, ResponseType: Decodable>(
        path: String,
        queryItems: [String : LosslessStringConvertible?],
        httpMethod: String,
        makeHeaders: @escaping (_ accessToken: String) -> [String: String],
        body: Body?,
        requiredScopes: Set<Scope>,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {
        
        do {
            
            let encodedBody = try body.map {
                try JSONEncoder().encode($0)
            }
            let endpoint = Endpoints.apiEndpoint(
                path, queryItems: removeIfNil(queryItems)
            )
            
            self.spotifyAPI.trace("endpoint: '\(endpoint)'")
            if let body = body {
                self.spotifyAPI.trace("body:\n\(body)")
            }
            
            return self.refreshAccessToken(onlyIfExpired: true)
                .tryMap {
                    return try self.ensureAuthorized(
                        forScopes: requiredScopes
                    ).accessToken
                }
                .flatMap { accessToken -> AnyPublisher<ResponseType, Error> in
                    
                    return URLSession.shared.dataTaskPublisher(
                        url: endpoint,
                        httpMethod: httpMethod,
                        headers: makeHeaders(accessToken),
                        body: encodedBody
                    )
                    .spotifyDecode(ResponseType.self)
                    
                }
                .eraseToAnyPublisher()
                
        } catch {
            return error.anyFailingPublisher(ResponseType.self)
        }
        
        
    }
    
   
}
