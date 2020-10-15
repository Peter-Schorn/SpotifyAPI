
import Foundation
import Combine
import Logging
import XCTest
import SpotifyWebAPI

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
    /// last ":".
    var spotifyId: String? {
        return self.split(separator: ":").last.map { String($0) }
    }

}

/// Assert the Spotify user is "petervschorn".
public func assertUserIsPeter(_ user: SpotifyUser) {
 
    XCTAssertEqual(user.id, "petervschorn")
    XCTAssertEqual(user.href, "https://api.spotify.com/v1/users/petervschorn")
    XCTAssertEqual(user.type, .user)
    XCTAssertEqual(user.uri, "spotify:user:petervschorn")
    
}

/**
 Assert that a publisher finished normally. If not, call through to
 `XCTFail`.
 
 - Parameters:
   - completion: A completion from a publisher.
   - message: A message to prefix the error with.
   - file: The file in which the error occured.
   - line: The line in which the error occured.
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

