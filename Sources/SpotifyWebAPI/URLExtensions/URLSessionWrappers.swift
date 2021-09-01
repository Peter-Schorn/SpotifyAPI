import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
    
    // #if canImport(Combine)
    // static let combineShared = URLSession.shared
    // #else
    // static let combineShared = URLSession.OCombine(.shared)
    // #endif

    /**
     The network adaptor that this library uses by default for all network
     requests. Uses `URLSession`.
    
     During tests it will sometimes use a different network adaptor.

     - Parameter request: The request to send.
     */
    public static func defaultNetworkAdaptor(
        request: URLRequest
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        
        return Self._defaultNetworkAdaptor(request)

    }

    /// This property exists so that it can be replaced with a different
    /// networking client during testing. Other than in the test targets, it
    /// will not be modified.
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
               // let dataString = String(data: data, encoding: .utf8) ?? "nil"
               // print("_defaultNetworkAdaptor: \(response.url!): \(dataString)")
                return (data: data, response: httpURLResponse)
            }
            .eraseToAnyPublisher()
        #else
        // the OpenCombine implementation of `DataTaskPublisher` has some
        // concurrency issues.
        return Future<(data: Data, response: HTTPURLResponse), Error> { promise in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let response = response {
                    guard let httpURLResponse = response as? HTTPURLResponse else {
                        fatalError(
                            "could not cast URLResponse to HTTPURLResponse:\n\(response)"
                        )
                    }
                   // let dataString = String(data: data, encoding: .utf8) ?? "nil"
                   // print("_defaultNetworkAdaptor: \(response.url!): \(dataString)")
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
