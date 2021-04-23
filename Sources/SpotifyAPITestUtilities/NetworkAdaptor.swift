import Foundation

#if !TEST
import NIO
import NIOHTTP1
import AsyncHTTPClient
#endif

#if canImport(Combine)
import Combine
#else
import OpenCombine
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import SpotifyWebAPI

public final class NetworkAdaptorManager {
    
    public static let shared = NetworkAdaptorManager()
    
    #if !TEST
    private let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    #endif
    
    private init() { }
    
    deinit {
        #if !TEST
        try? self.httpClient.syncShutdown()
        #endif
    }
    
    public func networkAdaptor(
        request: URLRequest
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        
        #if !TEST
        // transform the dictionary to an array of tuples
        let headers: [(String, String)] = (request.allHTTPHeaderFields ?? [:])
            .map { key, value in return (key, value) }
        
        let httpRequest: HTTPClient.Request
        do {
            httpRequest = try HTTPClient.Request(
                url: request.url!,
                method: HTTPMethod.RAW(value: request.httpMethod!),
                headers: HTTPHeaders(headers),
                body: request.httpBody.map { HTTPClient.Body.data($0) }
            )
            
        } catch {
            return error.anyFailingPublisher()
        }
        
        return Future<(data: Data, response: HTTPURLResponse), Error> { promise in
            
            self.httpClient.execute(
                request: httpRequest
            ).whenComplete { result in
                
                do {
                    let response = try result.get()
                    
                    // transform the headers into a standard swift dictionary
                    let headers: [String: String] = response.headers
                        .reduce(into: [:], { dict, header in
                            dict[header.name] = header.value
                        })
                    
                    let httpURLResponse = HTTPURLResponse(
                        url: httpRequest.url,
                        statusCode: Int(response.status.code),
                        httpVersion: nil,
                        headerFields: headers
                    )!
                    
                    let data: Data
                    if let bytesBuffer = response.body?.readableBytesView {
                        data = Data(bytesBuffer)
                    }
                    else {
                        data = Data()
                    }
                    
                    promise(.success((data: data, response: httpURLResponse)))
                    
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
        
        #else
        
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
        
        #endif
    }
    
}
