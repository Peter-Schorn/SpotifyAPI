import Foundation

#if TEST
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

@testable import SpotifyWebAPI

public final class NetworkAdaptorManager {
    
    public static let shared = NetworkAdaptorManager()
    
    #if TEST
    private let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    #endif
    
    private init() { }
    
    deinit {
        #if TEST
        try? self.httpClient.syncShutdown()
        #endif
    }
    
    public func networkAdaptor(
        request: URLRequest
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        
        #if TEST
        return self.nioNetworkAdaptor(request: request)
        #else
        print("NetworkAdaptorManager:networkAdaptor:URLSession.defaultNetworkAdaptor(request: request)")
        return URLSession.__defaultNetworkAdaptor(request)
        #endif
        
    }
    
    #if TEST
    private func nioNetworkAdaptor(
        request: URLRequest
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        
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
        
    }
    #endif
    
}
