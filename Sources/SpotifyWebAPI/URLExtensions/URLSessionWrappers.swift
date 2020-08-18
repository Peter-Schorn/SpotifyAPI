import Foundation
import Combine


public extension URLSession {
    
    func dataTaskPublisher(
        url: URL,
        httpMethod: String,
        headers: [String: String]?,
        body: Data? = nil
    ) -> DataTaskPublisher {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return self.dataTaskPublisher(for: request)

    }
    
}
