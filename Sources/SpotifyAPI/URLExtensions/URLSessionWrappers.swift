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
    
    // private func spotifyDecodeJSONCompletionWrapper<
    //     ResponseObject: CustomDecodable
    // >(
    //     responseObject: ResponseObject.Type,
    //     completion: @escaping (Result<ResponseObject, Error>) -> Void
    // ) -> (Data?, URLResponse?, Error?) -> Void {
    //
    //     return { data, urlResponse, error in
    //
    //         // guard let data = data else {
    //         //     completion(.failure(error ?? SpotifyLocalError.other(
    //         //         errorDescription: "An unknown error ocurred"
    //         //     )))
    //         //     return
    //         // }
    //         //
    //         // if let response = try? responseObject.decoded(from: data) {
    //         //     completion(.success(response))
    //         // }
    //         // else if let response = try? SpotifyError.decoded(from: data) {
    //         //     completion(.failure(response))
    //         // }
    //         // else if let response = try? SpotifyAuthenticationError.decoded(from: data) {
    //         //     completion(.failure(response))
    //         // }
    //         // else {
    //         //     let dataString = String(data: data, encoding: .utf8)
    //         //             ?? "the data could not be decoded"
    //         //     completion(.failure(SpotifyLocalError.other(errorDescription: dataString)))
    //         // }
    //
    //     }
    // }
    //
    // @discardableResult
    // func spotifyDecodeJSON<
    //     ReponseObject: CustomDecodable
    // >(
    //     request: URLRequest,
    //     responseObject: ReponseObject.Type,
    //     completion: @escaping (Result<ReponseObject, Error>) -> Void
    // ) -> URLSessionDataTask {
    //
    //     let task = URLSession.shared.dataTask(
    //         with: request,
    //         completionHandler: spotifyDecodeJSONCompletionWrapper(
    //             responseObject: responseObject,
    //             completion: completion
    //         )
    //     )
    //     task.resume()
    //     return task
    //
    // }
    //
    // @discardableResult
    // func spotifyDecodeJSON<
    //     ReponseObject: CustomDecodable
    // >(
    //     url: URL,
    //     httpMethod: String,
    //     headers: [String: String],
    //     httpBody: Data,
    //     responseObject: ReponseObject.Type,
    //     completion: @escaping (Result<ReponseObject, Error>) -> Void
    // ) -> URLSessionDataTask {
    //
    //
    //     var request = URLRequest(url: url)
    //     request.httpMethod = httpMethod
    //     request.allHTTPHeaderFields = headers
    //     request.httpBody = httpBody
    //
    //     return spotifyDecodeJSON(
    //         request: request,
    //         responseObject: responseObject,
    //         completion: completion
    //     )
    //
    // }
    //
    // func spotifyDecodeJSONPublisher<ReponseObject: CustomDecodable>(
    //     request: URLRequest,
    //     responseObject: ReponseObject.Type
    // ) {
    //
    //     let result = self.dataTaskPublisher(for: request)
    //     //     .map(\.data)
    //     //     .tryMap { data -> ReponseObject in
    //     //         if let responseObject = try? ReponseObject.decoded(from: data) {
    //     //             return responseObject
    //     //         }
    //     //         throw SpotifyLocalError.other(errorDescription: "oh no")
    //     //     }
    //
    //         // .customDecode(ReponseObject)
    //         // .mapError { error -> Error in
    //         //     let x = error
    //         // }
    //
    //         // .decode(type: ReponseObject.self, decoder: JSONDecoder())
    //     }
    
}
