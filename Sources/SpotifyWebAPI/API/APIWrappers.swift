import Foundation
import Combine
import Logger

extension SpotifyAPI {
    
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
     All requests to endpoints other than those
     for authorizing the app and retrieving/refreshing the tokens
     call through to this method.
     
     The refresh token will be refreshed automatically if needed
     before the request is made.
     
     If you are making a get request,
     use `self.getRequest(path:queryItems:requiredScopes:responseType:)`
     instead, which is a thin wrapper that calls though to this method.
     
     The base url that the path and query items are appended to is
     ```
     "https://api.spotify.com/v1"
     ```
    
     A closure that accepts the access token must be used
     to make the headers because the access token will not
     be accessed until a call to `self.refreshAccessToken(onlyIfExpired: true)`
     is made.
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
            
            return self.refreshAccessToken(onlyIfExpired: true)
                .tryMap { _ in
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
    
    // func makeDefaultPostPutDeleteHeaders(
    //     accessToken: String
    // ) -> [String: String] {
    //     return Headers.bearerAuthorization(accessToken) +
    //     Headers.acceptApplicationJSON
    // }
    //
    // /// Use for an http request other than a GET request.
    // func postPutDeleteRequest<Body: Encodable, ResponseType: Decodable>(
    //     path: String,
    //     queryItems: [String : LosslessStringConvertible?],
    //     httpMethod: String,
    //     makeHeaders:
    //         @escaping (_ accessToken: String) -> [String: String] =
    //         makeDefaultPostPutDeleteHeaders(accessToken:),
    //     body: Body,
    //     requiredScopes: Set<Scope>,
    //     responseType: ResponseType.Type
    // ) -> AnyPublisher<ResponseType, Error> {
    //
    //     return apiRequest(
    //         path: path,
    //         queryItems: queryItems,
    //         httpMethod: httpMethod,
    //         makeHeaders: makeHeaders,
    //         body: body,
    //         requiredScopes: requiredScopes,
    //         responseType: ResponseType.self
    //     )
    //
    // }
    //
    //
    // func postRequest<Body: Encodable, ResponseType: Decodable>(
    //     path: String,
    //     queryItems: [String : LosslessStringConvertible?],
    //     body: Body,
    //     requiredScopes: Set<Scope>,
    //     responseType: ResponseType.Type
    // ) -> AnyPublisher<ResponseType, Error> {
    //
    //
    //     func makeHeaders(_ accessToken: String) -> [String: String] {
    //         return Headers.bearerAuthorization(accessToken) +
    //         Headers.acceptApplicationJSON
    //     }
    //
    //     return apiRequest(
    //         path: path,
    //         queryItems: queryItems,
    //         httpMethod: "POST",
    //         makeHeaders: makeHeaders,
    //         body: body,
    //         requiredScopes: requiredScopes,
    //         responseType: ResponseType.self
    //     )
    //
    // }
    //
    // func deleteRequest<Body: Encodable, ResponseType: Decodable>(
    //     path: String,
    //     queryItems: [String : LosslessStringConvertible?],
    //     body: Body,
    //     requiredScopes: Set<Scope>,
    //     responseType: ResponseType.Type
    // ) -> AnyPublisher<ResponseType, Error> {
    //
    //     func makeHeaders(_ accessToken: String) -> [String: String] {
    //         return Headers.bearerAuthorization(accessToken) +
    //         Headers.acceptApplicationJSON
    //     }
    //
    //     return apiRequest(
    //         path: path,
    //         queryItems: queryItems,
    //         httpMethod: "DELETE",
    //         makeHeaders: makeHeaders,
    //         body: body,
    //         requiredScopes: requiredScopes,
    //         responseType: ResponseType.self
    //     )
    //
    // }
    
}
