import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
@testable import SpotifyWebAPI
import SpotifyExampleContent



private let serialMockQueue = DispatchQueue(label: "serialMockQueue")

public extension SpotifyAPI {
    

    /**
     Throws the error that you pass in to downstream subscribers in order to
     test the retry logic.
     
     - Parameters:
       - error: The error to throw.
       - times: The number of times to throw the error before returning a
             successful response.
     */
    func mockThrowError(
        _ error: Error,
        times: Int
    ) -> AnyPublisher<Album, Error> {

        var times = times

        return Deferred {
            Future<(data: Data, response: HTTPURLResponse), Error> { promise in
                if times > 0 {
                    self.logger.trace("returning error. times: \(times)")
                    if case .httpError(let data, let response) = error as?
                            SpotifyGeneralError {
                        let output = (data: data, response: response)
                        promise(.success(output))
                    }
                    else {
                        promise(.failure(error))
                    }
                }
                else {
                    self.logger.trace("returning successful response")
                    let album = Album.darkSideOfTheMoon
                    let albumData = try! JSONEncoder().encode(album)
                    let url = URL(
                        string: "https://api.spotify.com/v1/albums/4LH4d3cOWNNsVw41Gqt2kv"
                    )!
                    let httpResponse = HTTPURLResponse(
                        url: url,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )!
                    let output = (data: albumData, response: httpResponse)
                    promise(.success(output))
                }
                times -= 1
            }
        }
        .delay(
            for: .milliseconds(Int.random(in: 100...1000)),
            scheduler: serialMockQueue
        )
        .decodeSpotifyObject(Album.self)

    }
    
    func mockDecodeOptionalSpotifyObject<T: Decodable>(
        statusCode: Int,
        data: Data,
        responseType: T.Type
    ) -> AnyPublisher<T?, Error> {
        
        return Deferred {
            Future<(data: Data, response: HTTPURLResponse), Error> { promise in
                
                let url = URL(string: "http://example.com/")!

                let httpResponse = HTTPURLResponse(
                    url: url,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                )!
                let output = (data: data, response: httpResponse)
                promise(.success(output))
            }
        }
        .delay(
            for: .milliseconds(Int.random(in: 100...1000)),
            scheduler: serialMockQueue
        )
        .decodeOptionalSpotifyObject(T.self)

    }

}
