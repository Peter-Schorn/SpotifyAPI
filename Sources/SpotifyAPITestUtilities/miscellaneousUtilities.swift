#if canImport(XCTest)
import Foundation
import Combine

import XCTest

/// Assert that a url exists by making a data task request
/// and asserting that the status code is 200.
public func assertURLExists(
    _ url: URL, file: StaticString = #file, line: UInt = #line
) -> AnyPublisher<Void, URLError> {
    
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    
    return URLSession.shared.dataTaskPublisher(for: request)
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

public extension StringProtocol {
    
    /// Parses an id from a uri by returning all characters after the
    /// last ":"
    var spotifyId: String? {
        return self.split(separator: ":").last.map { String($0) }
    }

}
#endif
