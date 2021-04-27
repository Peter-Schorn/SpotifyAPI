import Foundation
import Logging

/// Container for loggers related to authorization managers
enum AuthorizationManagerLoggers {
    static var codeFlowBaseLogger = Logger(
        label: "AuthorizationCodeFlowManagerBase", level: .critical
    )

    static var codeFlowLogger = Logger(
        label: "AuthorizationCodeFlowManager", level: .critical
    )

    static var codeFlowPKCELogger = Logger(
        label: "AuthorizationCodeFlowPKCEManager", level: .critical
    )

    static var clientCredentialsFlowLogger = Logger(
        label: "ClientCredentialsFlowManager", level: .critical
    )
}
