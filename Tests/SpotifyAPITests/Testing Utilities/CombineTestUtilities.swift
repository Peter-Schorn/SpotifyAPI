import Foundation
import Combine
import XCTest


extension Publisher {
    
    /// Calls through to `XCTFail` when an error is received.
    func XCTAssertNoFailure(
        _ message: @autoclosure @escaping () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
     ) -> AnyPublisher<Output, Failure> {
        
        return self.handleEvents(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("\(message()): \(error)", file: file, line: line)
                }
            }
        )
        .eraseToAnyPublisher()
        
    }
    
    /// Calls through to `sink` and uses an empty closure
    /// to receive the completion.
    func sinkIgnoringCompletion(
        _ receiveValue: @escaping ((Self.Output) -> Void)
    ) -> AnyCancellable {
        
        return self.sink(
            receiveCompletion: { _ in },
            receiveValue: receiveValue
        )
        
    }

}
