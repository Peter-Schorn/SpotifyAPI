import Foundation
import Logging

enum AuthorizationManagerLoggers {
    
    /*
     These loggers are publicly exposed though computed properties on the
     authorization managers.
     */

    /// Publicly exposed via ``AuthorizationCodeFlowManagerBase/baseLogger``.
    static var authorizationCodeFlowManagerBaseLogger = Logger(
        label: "AuthorizationCodeFlowManagerBase",
        level: .critical
    )

    /// Publicly exposed via ``AuthorizationCodeFlowBackendManager/logger``
    static var authorizationCodeFlowManagerLogger = Logger(
        label: "AuthorizationCodeFlowManager",
        level: .critical
    )
    
    /// Publicly exposed via ``AuthorizationCodeFlowPKCEBackendManager/logger``
    static var authorizationCodeFlowPKCEManagerLogger = Logger(
        label: "AuthorizationCodeFlowPKCEManager",
        level: .critical
    )
    
    /// Publicly exposed via ``ClientCredentialsFlowBackendManager/logger``.
    static var clientCredentialsFlowManagerLogger = Logger(
        label: "ClientCredentialsFlowManager",
        level: .critical
    )

}
