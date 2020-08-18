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
            .flatMap { accessToken in
                URLSession.shared.dataTaskPublisher(
                    url: endpoint,
                    httpMethod: "GET",
                    headers: Headers.bearerAuthorization(accessToken)
                )
                .spotifyDecode(ResponseType.self)
            }
            .eraseToAnyPublisher()
        
    }
    
    
    func postRequest<Body: Encodable, ResponseType: Decodable>(
        path: String,
        queryItems: [String : LosslessStringConvertible?],
        requiredScopes: Set<Scope>,
        body: Body,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {
        do {
            
            let encodedBody = try JSONEncoder().encode(body)
            
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
                    
                    let headers =
                        Headers.bearerAuthorization(accessToken) +
                        Headers.acceptApplicationJSON
                    
                    return URLSession.shared.dataTaskPublisher(
                        url: endpoint,
                        httpMethod: "POST",
                        headers: headers,
                        body: encodedBody
                    )
                    .spotifyDecode(ResponseType.self)
                    
                }
                .eraseToAnyPublisher()
            
        } catch {
            return error.anyFailingPublisher(ResponseType.self)
        }
        
    }
    

    func apiRequest<Body: Encodable, ResponseType: Decodable>(
        path: String,
        queryItems: [String : LosslessStringConvertible?],
        requiredScopes: Set<Scope>,
        headers: [String: String],
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
                        headers: headers,
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
