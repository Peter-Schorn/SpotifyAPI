import Foundation
#if canImport(Combine)
import Combine
public typealias PlatformDataTaskPublisher = URLSession.DataTaskPublisher
#else
import OpenCombine
import OpenCombineFoundation
public typealias PlatformDataTaskPublisher = URLSession.OCombine.DataTaskPublisher
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
    func dataTaskPublisher(
        url: URL,
        httpMethod: String,
        headers: [String: String]?,
        body: Data? = nil
    ) -> PlatformDataTaskPublisher {
        
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
