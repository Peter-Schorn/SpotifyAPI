
import Foundation
import Combine
import Logging
import XCTest
import SpotifyWebAPI

/// Assert that a url exists by making a data task request
/// and asserting that the status code is 200.
public func assertURLExists(
    _ url: URL,
    file: StaticString = #file,
    line: UInt = #line
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


/**
 Assert the the Spotify Images exist.
 
 - Parameter images: An array of Spotify images.
 - Returns: An array of expectations that will be fullfilled when
       each image is loaded from its URL.
 */
public func XCTAssertImagesExist(
    _ images: [SpotifyImage],
    file: StaticString = #file,
    line: UInt = #line
) -> (expectations: [XCTestExpectation], cancellables: Set<AnyCancellable>) {
    var cancellables: Set<AnyCancellable> = []
    var imageExpectations: [XCTestExpectation] = []
    for (i, image) in images.enumerated() {
        XCTAssertNotNil(image.height)
        XCTAssertNotNil(image.width)
        guard let url = URL(string: image.url) else {
            XCTFail("couldn't convert to URL: '\(image.url)'")
            continue
        }
        let existsExpectation = XCTestExpectation(
            description: "image exists \(i)"
        )
        imageExpectations.append(existsExpectation)
        
        assertURLExists(url, file: file, line: line)
            .sink(receiveCompletion: { _ in
                existsExpectation.fulfill()
            })
            .store(in: &cancellables)

        let loadExpectation = XCTestExpectation(
            description: "load image \(i)"
        )
        imageExpectations.append(loadExpectation)
        
        image.load()
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in
                    loadExpectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    return (expectations: imageExpectations, cancellables: cancellables)
}
