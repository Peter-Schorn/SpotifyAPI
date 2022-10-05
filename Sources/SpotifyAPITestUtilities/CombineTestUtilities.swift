#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import XCTest
import SpotifyWebAPI

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension Publisher {
    
    /**
     Calls through to `XCTFail` when an error is received and replaces the error
     with a publisher that completes immediately successfully: `Empty<Output,
     Failure>`. This ensures that, when this method is used multiple times in a
     publishing stream, the same error will not get logged by additional
     downstream calls.
     
     - Parameters:
       - message: A message to prefix the error with.
       - file: The file in which the error occurred.
       - line: The line in which the error occurred.
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
     Calls through to `sink(receiveCompletion:receiveValue:)` and uses an empty
     closure to receive the completion.
     
     - Parameter receiveValue: A function to call when a value is received.
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
    
    func receiveOnMain() -> AnyPublisher<Output, Failure> {
        return self.receive(on: DispatchQueue.combineMain)
            .eraseToAnyPublisher()
    }

    func receiveOnMain(
        delay: Double
    ) -> AnyPublisher<Output, Failure> {
        return self.delay(
            for: .seconds(delay),
            scheduler: DispatchQueue.combineMain
        )
        .eraseToAnyPublisher()
    }

}

public extension DispatchQueue {
    
    #if canImport(Combine)
    static let combineMain = DispatchQueue.main
    #else
    static let combineMain = DispatchQueue.OCombine(.main)
    #endif

}

/**
 Assert that a publisher finished normally. If not, call through to `XCTFail`.
 
 - Parameters:
 - completion: A completion from a publisher.
 - message: A message to prefix the error with.
 - file: The file in which the error occurred.
 - line: The line in which the error occurred.
 */
public func XCTAssertFinishedNormally<E: Error>(
    _ completion: Subscribers.Completion<E>,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    if case .failure(let error) = completion {
        let msg = message.isEmpty ? "" : "\(message): "
        XCTFail("\(msg)\(error)", file: file, line: line)
    }
}

/// Assert that a url exists by making a data task request and asserting that
/// the status code is 200.
public func assertURLExists(
    _ url: URL,
    file: StaticString = #file,
    line: UInt = #line
) -> AnyPublisher<Void, URLError> {
    
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    
    #if canImport(Combine)
    let publisher = URLSession.shared.dataTaskPublisher(for: request)
    #else
    let publisher = URLSession.OCombine(.shared).dataTaskPublisher(for: request)
    #endif
    return publisher
        .XCTAssertNoFailure(file: file, line: line)
        .map { data, response in
            let httpURLResponse = response as! HTTPURLResponse
            XCTAssertEqual(
                httpURLResponse.statusCode, 200,
                "unexpected status code for \(url)",
                file: file, line: line
            )
        }
        .eraseToAnyPublisher()
    
    
}

/**
 Assert the Spotify Images exist.
 
 Calls `image.load()` for each image on platforms that support SwiftUI. Else,
 calls `assertURLExists(_:file:line:)` for each image.
 
 - Parameters:
   - images: An array of Spotify images.
   - assertSizeNotNil: whether or not to assert that the height and width of the
         images is not `nil`.
 */
public func XCTAssertImagesExist(
    _ images: [SpotifyImage]?,
    assertSizeNotNil: Bool,
    file: StaticString = #file,
    line: UInt = #line
) {

    guard let images = images else {
        XCTFail("images was nil")
        return
    }

    var cancellables: Set<AnyCancellable> = []
    var expectations: [XCTestExpectation] = []
    
    let waiter = XCTWaiter()

    for (i, image) in images.enumerated() {

        if assertSizeNotNil {
            XCTAssertNotNil(image.height, "image[\(i)].height")
            XCTAssertNotNil(image.width, "image[\(i)].width")
        }

#if (canImport(AppKit) || canImport(UIKit)) && canImport(SwiftUI) && !targetEnvironment(macCatalyst)
        let loadExpectation = XCTestExpectation(
            description: "load image \(i)"
        )
        expectations.append(loadExpectation)
        
        image.load()
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in
                    loadExpectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
#else
        let existsExpectation = XCTestExpectation(
            description: "image exists \(i)"
        )
        expectations.append(existsExpectation)
        
        assertURLExists(image.url, file: file, line: line)
            .sink(receiveCompletion: { _ in
                existsExpectation.fulfill()
            })
            .store(in: &cancellables)
#endif
        
    }
    
    waiter.wait(for: expectations, timeout: TimeInterval(60 * images.count))
    
}
