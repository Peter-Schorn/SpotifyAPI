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
            path,
            queryItems: removeIfNil(queryItems)
        )
        
        self.logger.trace("for endpoint: \(endpoint)")
        
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
    

}
