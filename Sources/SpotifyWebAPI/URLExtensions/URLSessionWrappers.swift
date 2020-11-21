import Foundation
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation


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
    ) -> OCombine.DataTaskPublisher {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return OCombine(self).dataTaskPublisher(for: request)

    }
    
}
