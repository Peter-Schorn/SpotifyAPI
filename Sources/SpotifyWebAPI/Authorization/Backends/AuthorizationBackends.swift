import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public protocol AuthorizationCodeFlowBackend: Codable, Hashable {
	
    var clientId: String { get }
	
	func makeTokensRequest(
        code: String,
        redirectURIWithQuery: URL
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
	
    func makeRefreshTokenRequest(
        refreshToken: String
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
    
}

public protocol AuthorizationCodeFlowPKCEBackend: Codable, Hashable {
    
    var clientId: String { get }

	func makePKCETokensRequest(
        code: String,
        codeVerifier: String,
        redirectURIWithQuery: URL
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
    
	func makePKCERefreshTokenRequest(
        refreshToken: String
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
    
}

public protocol ClientCredentialsFlowBackend: Codable, Hashable {
    
    func makeClientCredentialsTokensRequest(
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>

}
