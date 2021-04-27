import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

enum AuthorizationManagerLoggers {
    
    // TODO: add notes about accessing these loggers via computed
    // properties

    static var authorizationCodeFlowManagerBaseLogger = Logger(
        label: "AuthorizationCodeFlowManagerBase", level: .critical
    )

    /// The logger for this class. By default, its level is `critical`.
    static var authorizationCodeFlowManagerLogger = Logger(
        label: "AuthorizationCodeFlowManager", level: .critical
    )
    

    static var authorizationCodeFlowPKCEManagerLogger = Logger(
        label: "AuthorizationCodeFlowPKCEManager", level: .critical
    )
    
    static var clientCredentialsFlowManagerLogger = Logger(
        label: "ClientCredentialsFlowManager", level: .critical
    )

}

public protocol AuthorizationCodeFlowBackend: Codable, Hashable {
    
    var clientId: String { get }
    
    func makeTokenRequest(
        code: String,
        redirectURIWithQuery: URL
    ) -> URLRequest
    
    func makeRefreshTokenRequest(refreshToken: String) -> URLRequest
    
}

public protocol AuthorizationCodeFlowPKCEBackend: Codable, Hashable {
    
    var clientId: String { get }

    func makePKCETokenRequest(
        code: String,
        codeVerifier: String,
        redirectURIWithQuery: URL
    ) -> URLRequest
    
    func makePKCERefreshTokenRequest(refreshToken: String) -> URLRequest
    
}


// MARK: TODO
public protocol ClientCredentialsFlowBackend: Codable, Hashable {
    
    var clientId: String { get }
    
    func makeTokensRequest()

}
