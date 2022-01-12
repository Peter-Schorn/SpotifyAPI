import Foundation
import Logging

/**
 The logging backend for this library.
 
 See [swift-log][1].
 
 [1]: https://github.com/apple/swift-log
 */
public struct SpotifyAPILogHandler: LogHandler {

    private static var handlerIsInitialized = false
    
    private static let initializeHandlerDispatchQueue = DispatchQueue(
        label: "SpotifyAPI.SpotifyAPILogHandler.initializeHandler"
    )
    
    /**
     Calls `LoggingSystem.bootstrap(_:)` and configures this type as the logging
     backend. The default log level is `info`.
    
     This method should only be called once. Calling it additional times is
     safe, but has no effect.

     **Thread Safety**
     
     This method is thread-safe.
     */
    public static func bootstrap() {
        Self.initializeHandlerDispatchQueue.sync {
            if !Self.handlerIsInitialized {
                LoggingSystem.bootstrap { label in
                    Self(label: label, logLevel: .info)
                }
                Self.handlerIsInitialized = true
            }
        }
    }
    
    
    /// A label for the logger.
    public let label: String

    public var logLevel: Logger.Level
    
    public var metadata: Logger.Metadata

    /**
     Creates a logger.
     
     - Parameters:
       - label: A label for the logger.
       - logLevel: The log level.
       - metadata: Metadata for this logger.
     */
    public init(
        label: String,
        logLevel: Logger.Level,
        metadata: Logger.Metadata = Logger.Metadata()
    ) {
        self.label = label
        self.logLevel = logLevel
        self.metadata = metadata
    }
    
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let logMessage = """
            [\(label): \(level): \(function) line \(line)] \(message)
            """
        print(logMessage)
    }

}

public extension Logger {
    
    /**
     Calls through to `init(label:)`, then sets the log level.
     
     - Parameters:
       - label: An identifier for the creator of a `Logger`.
       - level: The log level for the logger.
     */
    init(label: String, level: Logger.Level) {
        self.init(label: label)
        self.logLevel = level
    }
    

    /**
     Construct a `Logger` given a `label` identifying the creator of the
     `Logger` or a non-standard `LogHandler`.
          
     The `label` should identify the creator of the `Logger`. This can be an
     application, a sub-system, or even a datatype. This initializer provides an
     escape hatch in case the global default logging backend implementation (set
     up using `LoggingSystem.bootstrap`) is not appropriate for this particular
     logger.
     
     - parameters:
       - label: An identifier for the creator of a `Logger`.
       - level: The log level for the logger.
       - factory: A closure creating non-standard `LogHandler`s.
     */
    init(
        label: String,
        level: Logger.Level,
        factory: (_ label: String) -> LogHandler
    ) {
        self.init(label: label, factory: factory)
        self.logLevel = level
        
    }
    

}
