import Foundation
import Combine
import Logger

extension SpotifyAPI {
    
    func getRequest<ResponseType: CustomDecodable>(
        endpoint: URL,
        requiredScopes: Set<Scope>,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {

        logger.trace("")
        
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
