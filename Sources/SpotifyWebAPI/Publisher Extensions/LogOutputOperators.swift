
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineFoundation
#endif
import Logging

public extension Publisher {
    
    /// Logs any errors in the stream.
    func logError(
        _ prefix: String = "",
        to logger: Logger,
        level: Logger.Level = .trace,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> Publishers.MapError<Self, Failure>  {
        
        return self.mapError { error in
            logger.log(
                level: level,
                "\(prefix) \(error)",
                file: file,
                function: function,
                line: line
            )
            return error
        }
    }
    
    /// Logs all values in the stream, but, unlike the `print()` operator,
    /// not notifications about completion, cancellations, or subscriptions.
    func logOutput(
        _ prefix: String = "",
        to logger: Logger,
        level: Logger.Level = .trace,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) -> Publishers.HandleEvents<Self> {
        
        return self.handleEvents(
            receiveOutput: { output in
                logger.log(
                    level: level,
                    "\(prefix) \(output)",
                    file: file,
                    function: function,
                    line: line
                )
            }
        )
        
    }
    
}
