import Foundation

#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

import XCTest
import SpotifyWebAPI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Assert that a url exists by making a data task request
/// and asserting that the status code is 200.
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
#if (canImport(AppKit) || canImport(UIKit)) && canImport(SwiftUI)
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
#endif

/**
 Opens the authorization URL and waits for the user to login
 and copy and paste the redirect URL into standard input or starts
 a server to listen for the redirect URL if the USEVAPOR flag is enabled.
 
 - Parameter authorizationURL: The authorization URL.
 - Returns: The redirect URI with the query, which is used for
       requesting access and refresh tokens
 */
public func openAuthorizationURLAndWaitForRedirect(
    _ authorizationURL: URL
) -> URL? {
    
    #if USEVAPOR
    // MARK: start the server
    
    var redirectURIWithQuery: URL? = nil
    
    var redirectListener = RedirectListener(url: localHostURL)
    
    let dispatchGroup = DispatchGroup()
    
    dispatchGroup.enter()
    do {
        try redirectListener.start(receiveURL: { url in
            redirectURIWithQuery = url
//            for (name, value) in url.queryItemsDict {
//                print("'\(name)': '\(value)'")
//            }
            dispatchGroup.leave()
        })
        
    } catch {
        fatalError("couldn't run listener: \(error)")
    }
    
    #endif

    // MARK: open the authorization URL
    
    #if canImport(AppKit)
    NSWorkspace.shared.open(authorizationURL)
    #elseif canImport(UIKit)
    UIApplication.shared.open(authorizationURL)
    #else
    print(
        """

        ======================================================\
        ===============================================
        Open the following URL in your browser:

        \(authorizationURL)
        """
    )
    #endif
    
    #if USEVAPOR
    print(
        """

        ======================================================\
        ===============================================
        Running local server to wait for redirect
        """
    )
    
    // MARK: retrieve the redirect URI from the server

    dispatchGroup.wait()
    redirectListener.shutdown()
    
    if let redirectURIWithQuery = redirectURIWithQuery {
        return redirectURIWithQuery
    }
    fatalError("couldn't get redirect URI from listener")
    
    #else
    print(
        """

        ======================================================\
        ===============================================
        After You approve the application and are redirected, \
        paste the url that you were redirected to here:
        """
    )
    
    // MARK: get the redirect URI from standard input
    
    guard var redirectURIWithQueryString = readLine() else {
        fatalError("couldn't read redirect URI from standard input")
    }
    
    // see the documentation for `readLine`
    // see also https://en.wikipedia.org/wiki/Specials_(Unicode_block)#Unicode_chart
    let replacementCharacters: [Character] = [
        "\u{FFF9}", "\u{FFFA}", "\u{FFFB}", "\u{FFFC}", "\u{FFFD}",
        "\u{F702}"
    ]
    
    redirectURIWithQueryString.removeAll(where: { character in
        replacementCharacters.contains(character)
    })
    
    return URL(string: redirectURIWithQueryString.strip())
    
    #endif

}
