import Foundation

#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

import XCTest
@testable import SpotifyWebAPI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension StringProtocol {
    
    /// Parses an id from a uri by returning all characters after the last ":".
    var spotifyId: String? {
        return self.split(separator: ":").last.map { String($0) }
    }

}

/// Assert the Spotify user is "petervschorn".
public func assertUserIsPeter(
    _ user: SpotifyUser,
    file: StaticString = #filePath,
    line: UInt = #line
) {
 
    XCTAssertEqual(
        user.href,
        URL(string: "https://api.spotify.com/v1/users/petervschorn")!,
        file: file, line: line
    )
    XCTAssertEqual(
        user.id, "petervschorn",
        file: file, line: line
    )
    XCTAssertEqual(
        user.uri,
        "spotify:user:petervschorn",
        file: file, line: line
    )
    XCTAssertEqual(
        user.type, .user,
        file: file, line: line
    )
    
}

public extension Scope {
    
    /**
     All the scopes that are related to playlists.
     
     * ``Scope/playlistReadCollaborative``
     * ``Scope/playlistModifyPublic``
     * ``Scope/playlistReadPrivate``
     * ``Scope/playlistModifyPrivate``
     * ``Scope/ugcImageUpload`` (required for uploading an image to a playlist)
     */
    static let playlistScopes: Set<Scope> = [
        .playlistReadCollaborative,
        .playlistModifyPublic,
        .playlistReadPrivate,
        .playlistModifyPrivate,
        .ugcImageUpload
    ]

}

public extension URLSession {
    
    /**
     Sets the `cachePolicy` of the `URLRequest` to
     `reloadIgnoringLocalAndRemoteCacheData`.
     
     Useful for tests that need to produce a rate limited error.
     */
    func noCacheNetworkAdaptor(
        request: URLRequest
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        
        var request = request
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { $0 as Error }
            .map { data, response -> (data: Data, response: HTTPURLResponse) in
                guard let httpURLResponse = response as? HTTPURLResponse else {
                    fatalError(
                        "could not cast URLResponse to HTTPURLResponse:\n\(response)"
                    )
                }
                return (data: data, response: httpURLResponse)
            }
            .eraseToAnyPublisher()

    }
    

    static let __defaultNetworkAdaptor: (
        URLRequest
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> = { request in
        
        #if canImport(Combine)
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { $0 as Error }
            .map { data, response -> (data: Data, response: HTTPURLResponse) in
                guard let httpURLResponse = response as? HTTPURLResponse else {
                    fatalError(
                        "could not cast URLResponse to HTTPURLResponse:\n\(response)"
                    )
                }
//                let dataString = String(data: data, encoding: .utf8) ?? "nil"
//                print("_defaultNetworkAdaptor: \(response.url!): \(dataString)")
                return (data: data, response: httpURLResponse)
            }
            .eraseToAnyPublisher()
        #else
        // the OpenCombine implementation of `DataTaskPublisher` has
        // some concurrency issues.
        return Future<(data: Data, response: HTTPURLResponse), Error> { promise in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let response = response {
                    guard let httpURLResponse = response as? HTTPURLResponse else {
                        fatalError(
                            "could not cast URLResponse to HTTPURLResponse:\n\(response)"
                        )
                    }
//                    let dataString = String(data: data, encoding: .utf8) ?? "nil"
//                    print("_defaultNetworkAdaptor: \(response.url!): \(dataString)")
                    promise(.success((data: data, response: httpURLResponse)))
                }
                else {
                    let error = error ?? URLError(.unknown)
                    promise(.failure(error))
                }
            }
            .resume()
        }
        .eraseToAnyPublisher()
        #endif

    }

}

public extension String {
    
    func append(to file: URL, terminator: String = "\n") throws {

        guard var data = self.data(using: .utf8) else {
            return
        }
        guard let terminatorData = terminator.data(using: .utf8) else {
            return
        }
        data.append(terminatorData)

        let manager = FileManager.default

        if manager.fileExists(atPath: file.path) {
            let handle = try FileHandle(forUpdating: file)
            do {
                if #available(macOS 10.15.4, iOS 13.4, macCatalyst 13.4, tvOS 13.4, watchOS 6.2, *) {
                    try handle.seekToEnd()
                }
                else {
                    handle.seekToEndOfFile()
                }
                handle.write(data)
                try handle.close()

            } catch {
                try handle.close()
                throw error
            }
            
        }
        else {
            let directory = file.deletingLastPathComponent()
            if !manager.fileExists(atPath: directory.path) {
                try manager.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true
                )
            }
            
            try data.write(to: file, options: [.atomic])
        }
        
    }

}

public struct VaporServerError: Error, Codable {
    
    /// The reason for the error.
    public let reason: String
    
    /// Always set to `true` to indicate that the JSON payload represents an
    /// error response.
    public let error: Bool
}

extension VaporServerError: CustomStringConvertible {
    public var description: String {
        return """
            \(Self.self)(reason: "\(self.reason)")
            """
    }
}

extension VaporServerError {
    
    public static func decodeFromNetworkResponse(
        data: Data, response: HTTPURLResponse
    ) -> Error? {
        
        guard (400..<500).contains(response.statusCode) else {
            return nil
        }
        
        return try? JSONDecoder().decode(
            Self.self, from: data
        )
        
    }
    
}
