import Foundation
#if canImport(Combine)
import Combine

/// `URLSession.DataTaskPublisher` If `Combine` can be imported; else,
/// `URLSession.OCombine.DataTaskPublisher` from `OpenCombine`.
public typealias URLSessionDataTaskPublisher = URLSession.DataTaskPublisher
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation

/// `URLSession.DataTaskPublisher` If `Combine` can be imported; else,
/// `URLSession.OCombine.DataTaskPublisher` from `OpenCombine`.
public typealias URLSessionDataTaskPublisher = URLSession.OCombine.DataTaskPublisher
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension URLSession {
    
    /**
     A convenience method for creating a data task publisher.

     Equivalent to
     ```
     var request = URLRequest(url: url)
     request.httpMethod = httpMethod
     request.allHTTPHeaderFields = headers
     request.httpBody = body
     
     return self.dataTaskPublisher(for: request)
     ```
     
     - Parameters:
       - url: The URL for the task.
       - httpMethod: The HTTP method.
       - headers: The headers.
       - body: The body of the request
     - Returns: A data task publisher.
     */
    @available(*, deprecated)
    func dataTaskPublisher(
        url: URL,
        httpMethod: String,
        headers: [String: String]?,
        body: Data? = nil
    ) -> URLSessionDataTaskPublisher {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        #if canImport(Combine)
        return self.dataTaskPublisher(for: request)
        #else
        return OCombine(self).dataTaskPublisher(for: request)
        #endif

    }
    
}

extension URLSession {
    
    // #if canImport(Combine)
    // static let combineShared = URLSession.shared
    // #else
    // static let combineShared = URLSession.OCombine(.shared)
    // #endif

    /**
     The network adaptor that this library uses by default for all
     network requests. Uses `URLSession`.
    
     - Parameter request: The request to send.
     */
    static func defaultNetworkAdaptor(
        request: URLRequest
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        
        return Self._defaultNetworkAdaptor(request)

    }

    /// This property exists so that it can be replaced with a different
    /// networking client during testing. Other than in the test targets,
    /// it will not be modified.
    static var _defaultNetworkAdaptor: (
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
