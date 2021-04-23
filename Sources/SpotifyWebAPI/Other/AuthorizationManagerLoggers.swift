import Foundation
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
