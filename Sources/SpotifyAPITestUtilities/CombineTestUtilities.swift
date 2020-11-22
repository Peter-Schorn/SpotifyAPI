
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineFoundation
#endif
import XCTest

public extension Publisher {
    
    /**
     Calls through to `XCTFail` when an error is received
     and replaces the error with a publisher that completes
     immediately successfully: `Empty<Output, Failure>`. This ensures that,
     when this method is used multiple times in a publishing stream,
     the same error will not get logged by additional downstream calls.
     
     - Parameters:
       - message: A message to prefix the error with.
       - file: The file in which the error occured.
       - line: The line in which the error occured.
     */
    func XCTAssertNoFailure(
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
     ) -> AnyPublisher<Output, Failure> {
        
        return self.catch { error -> Empty<Output, Failure> in
            let msg = message.isEmpty ? "" : "\(message): "
            XCTFail("\(msg)\(error)", file: file, line: line)
            return Empty<Output, Failure>(completeImmediately: true)
        }
        .eraseToAnyPublisher()
        
    }
    
    /**
     Calls through to `sink(receiveCompletion:receiveValue:)` and uses
     an empty closure to receive the completion.
     
     - Parameter receiveValue: A function to call when a value is
           received.
     - Returns: An `AnyCancellable`.
     */
    func sinkIgnoringCompletion(
        _ receiveValue: @escaping ((Self.Output) -> Void)
    ) -> AnyCancellable {
        
        return self.sink(
            receiveCompletion: { _ in },
            receiveValue: receiveValue
        )
        
    }

}
