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


public extension SpotifyAPI {
    
    /**
     Throws the error that you pass in to downstream subscribers in order
     to test the retry logic.
     
     - Parameters:
       - error: The error to throw.
       - times: The number of times to throw the error before returning
             a successful response.
     */
    func mockThrowError(
        _ error: Error,
        times: Int
    ) -> AnyPublisher<Album, Error> {

        var times = times

        return Deferred {
            Future<(data: Data, response: URLResponse), Error> { promise in
                if times > 0 {
                    self.logger.trace("returning error. times: \(times)")
                    promise(.failure(error))
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
            scheduler: DispatchQueue.global()
        )
        .decodeSpotifyObject(Album.self)
        .eraseToAnyPublisher()

    }

}
