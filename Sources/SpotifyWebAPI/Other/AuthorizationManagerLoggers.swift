import Foundation
import Logging

enum AuthorizationManagerLoggers {
    
    /*
     These loggers are publicy exposed though computed properties on the
     authorization managers.
     */

    static var authorizationCodeFlowManagerBaseLogger = Logger(
        label: "AuthorizationCodeFlowManagerBase",
        level: .critical
    )

    static var authorizationCodeFlowManagerLogger = Logger(
        label: "AuthorizationCodeFlowManager",
        level: .critical
    )
    
    static var authorizationCodeFlowPKCEManagerLogger = Logger(
        label: "AuthorizationCodeFlowPKCEManager",
        level: .critical
    )
    
    static var clientCredentialsFlowManagerLogger = Logger(
        label: "ClientCredentialsFlowManager",
        level: .critical
    )

}
