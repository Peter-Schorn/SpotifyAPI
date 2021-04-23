import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol AuthorizationCodeFlowBackend: Codable, Hashable {
	
    var clientId: String { get }
	
	func makeTokenRequest(
        code: String,
        redirectURIWithQuery: URL
    ) throws -> URLRequest
	
    func makeRefreshTokenRequest(refreshToken: String) throws -> URLRequest
    
}

public protocol AuthorizationCodeFlowPKCEBackend: Codable, Hashable {
    
    var clientId: String { get }

	func makePKCETokenRequest(
        code: String,
        codeVerifier: String,
        redirectURIWithQuery: URL
    ) throws -> URLRequest
    
	func makePKCERefreshTokenRequest(refreshToken: String) throws -> URLRequest
    
}


// MARK: TODO
public protocol ClientCredentialsFlowBackend: Codable, Hashable {
    
    var clientId: String { get }
    
    func makeTokensRequest() throws -> URLRequest

}
