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

        func makeHeaders(_ accessToken: String) -> [String: String] {
            return Headers.bearerAuthorization(accessToken)
        }
        
        return apiRequest(
            path: path,
            queryItems: queryItems,
            requiredScopes: requiredScopes,
            makeHeaders: makeHeaders,
            httpMethod: "GET",
            body: nil as Data?,
            responseType: ResponseType.self
        )
        
    }
    
    
    func postRequest<Body: Encodable, ResponseType: Decodable>(
        path: String,
        queryItems: [String : LosslessStringConvertible?],
        requiredScopes: Set<Scope>,
        body: Body,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {

        
        func makeHeaders(_ accessToken: String) -> [String: String] {
            return Headers.bearerAuthorization(accessToken) +
            Headers.acceptApplicationJSON
        }
        
        return apiRequest(
            path: path,
            queryItems: queryItems,
            requiredScopes: requiredScopes,
            makeHeaders: makeHeaders,
            httpMethod: "POST",
            body: body,
            responseType: ResponseType.self
        )
        
    }
    

    /// All requests to endpoints other than those
    /// for authorizing the app and retrieving/refreshing the tokens
    /// call through to this method.
    func apiRequest<Body: Encodable, ResponseType: Decodable>(
        path: String,
        queryItems: [String : LosslessStringConvertible?],
        requiredScopes: Set<Scope>,
        makeHeaders: @escaping (_ accessToken: String) -> [String: String],
        httpMethod: String,
        body: Body?,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {
        
        do {
            
            let encodedBody = try body.map {
                try JSONEncoder().encode($0)
            }
            let endpoint = Endpoints.apiEndpoint(
                path, queryItems: removeIfNil(queryItems)
            )
            
            self.logger.trace("endpoint: '\(endpoint)'")
            
            return self.refreshAccessToken()
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
    
}
