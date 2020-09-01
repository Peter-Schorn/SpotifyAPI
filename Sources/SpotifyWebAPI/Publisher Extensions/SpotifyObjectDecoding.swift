import Foundation
import Combine
import Logger

public let spotifyDecodeLogger = Logger(
    label: "spotifyDecode", level: .warning
)

// MARK: - Decode Spotify Objects -

/**
 Tries to decode the raw data from a Spotify web API request
 into one of the error objects that Spotify returns for
 most endpoints.
 
 It is recommended to use the combine operator `decodeSpotifyErrors()`
 instead of this function, whenever possible.
 
 The error objects are:
 
 * `SpotifyAuthenticationError`
 * `SpotifyError`,
 * `RateLimitedError`.
 
 If the data cannot be decoded into one of these errors,
 then `nil` is returned.
 
 - Parameters:
   - data: The data from the server.
   - httpURLResponse: The http response metadata.
 */
public func decodeSpotifyErrors(
    data: Data, httpURLResponse: HTTPURLResponse
) -> Error? {
    
    if httpURLResponse.statusCode == 429 {
        
        let retryAfter = httpURLResponse.value(
            forHTTPHeaderField: "Retry-After"
        ).map(Int.init) as? Int
        
        if let retryAfter = retryAfter {
            spotifyDecodeLogger.notice(
                "hit rate limit; retry after \(retryAfter) seconds"
            )
        }
        else {
            spotifyDecodeLogger.error(
                "got 429 rate limit error, but couldn't " +
                "get value for Retry-After header and/or " +
                "convert to Int"
            )
        }
        
        return RateLimitedError(retryAfter: retryAfter)
        
    }

    let decoder = JSONDecoder()
    
    if let error = try? decoder.decode(
        SpotifyAuthenticationError.self, from: data
    ) {
        return error
    }

    if let error = try? decoder.decode(
        SpotifyError.self, from: data
    ) {
        return error
    }
    
    let statusCode = httpURLResponse.statusCode
    
    // the error status codes. If one of these is returned,
    // then it should have been possible to decode the Data into one
    // of the error objects. A Violation of this assumption
    // is a serious error.
    if [401, 401, 403, 404, 500, 502, 503].contains(statusCode) {
        spotifyDecodeLogger.critical(
            "http response status code was \(statusCode) (error), " +
            "but couldn't decode error response objects"
        )
    }
    
    return nil
}

/**
 Tries to decode the raw data from a Spotify web API request.
 You normally don't need to call this method directly.
 
 It is recommended to use the combine operator `decodeSpotifyObject(_:)`
 instead of this function, whenever possible.
 
 First tries to decode the data into `responseType`.
 If that fails, then the data is decoded into one of
 the [errors][1] returned by spotify:
 
 * `SpotifyAuthenticationError`
 * `SpotifyError`
 * `RateLimitedError`
 
 If decoding into the error objects fails, `SpotifyDecodingError` is thrown
 as a last resort.
 
 **Note**: `SpotifyDecodingError` represents the error encountered
 when decoding the `responseType`, not the error objects.
 
 - Parameter responseType: The json response that you are
       are expecting from the Spotify web API.
 - Parameter data: The data from the server.
 - Parameter httpURLResponse: The http response metadata.
 - Throws: If the data cannot be decoded into the specified `responseType`.
 - Returns: The decoded object.
 
 [1]: https://developer.spotify.com/documentation/web-api/#response-schema
 */
public func decodeSpotifyObject<ResponseType: Decodable>(
    data: Data,
    httpURLResponse: HTTPURLResponse,
    responseType: ResponseType.Type
) throws -> ResponseType {

    do {
        
        return try JSONDecoder().decode(
            ResponseType.self, from: data
        )
    
    } catch let responseTypeDecodingError {

        spotifyDecodeLogger.warning("couldn't decode response object")
        
        if let spotifyError = decodeSpotifyErrors(
            data: data, httpURLResponse: httpURLResponse
        ) {
            throw spotifyError
        }
        
        spotifyDecodeLogger.error(
            "couldn't decode \(responseType) or " +
            "the spotify error objects"
        )
        
        /*
         If the data can't be decoded into one of the Spotify
         error objects, then it is probably because Spotify
         did not return an error object; instead, it returned
         the data that was requested, but the data is not properly
         modeled by `responseType`. Therefore, it is more useful to
         throw the error encountered when decoding the
         expected `responseType` (`responseTypeDecodingError`)
         back to the caller.
         */
        throw SpotifyDecodingError(
            rawData: data,
            responseType: responseType,
            statusCode: httpURLResponse.statusCode,
            underlyingError: responseTypeDecodingError
        )
        
    }
    
}

// MARK: - Publisher Extensions -

public extension Publisher where Output == (data: Data, response: URLResponse) {

    /**
     Tries to decode the raw data from a Spotify web API request
     into one of the error objects that Spotify returns for
     most endpoints: `SpotifyAuthenticationError`, `SpotifyError`,
     or `RateLimitedError`.
     
     If the data can be decoded into one of these errors,
     then this error object is thrown as an error to downstream subscribers.
     Otherwise, the data is passed through unmodified to downstream
     subscribers.
     */
    func decodeSpotifyErrors() -> AnyPublisher<Self.Output, Error> {

        return self.tryMap { data, response in

            guard let httpURLResponse = response as? HTTPURLResponse else {
                fatalError("could not cast URLResponse to HTTPURLResponse")
            }

            if let error = SpotifyWebAPI.decodeSpotifyErrors(
                data: data, httpURLResponse: httpURLResponse
            ) {
                throw error
            }

            return (data, response)

        }
        .eraseToAnyPublisher()


    }

    /**
     Tries to decode the raw data from a Spotify web API request.
     You normally don't need to call this method directly.

     First tries to decode the data into the specified type
     that conforms to `Decodable`. If that fails, then
     the data is decoded into one of the [errors][1] returned by spotify:

     * `SpotifyAuthenticationError`
     * `SpotifyError`
     * `RateLimitedError`

     If decoding into the error objects fails, `SpotifyDecodingError` is thrown
     as a last resort.

     **Note**: `SpotifyDecodingError` represents the error encountered
     when decoding the `responseType`, not the error objects.

     - Parameter responseType: The json response that you are
     are expecting from the Spotify web API.

     [1]: https://developer.spotify.com/documentation/web-api/#response-schema
     */
    func decodeSpotifyObject<ResponseType: Decodable>(
        _ responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {

        return self.tryMap { data, response -> ResponseType in

            guard let httpURLResponse = response as? HTTPURLResponse else {
                fatalError("could not cast URLResponse to HTTPURLResponse")
            }

            return try SpotifyWebAPI.decodeSpotifyObject(
                data: data,
                httpURLResponse: httpURLResponse,
                responseType: responseType
            )

        }
        .eraseToAnyPublisher()

    }

}

extension Publisher where Output == (data: Data, response: URLResponse) {
    
    
    func decodeSpotifyPagingObject<ResponseType: Decodable>(
        _ wrappedType: ResponseType.Type,
        getPage: @escaping (_ atOffset: Int, _ limit: Int?)
                -> AnyPublisher<PagingObject<ResponseType>, Error>
    ) -> AnyPublisher<PagingObject<ResponseType>, Error> {
        
        
        return self.tryMap { data, response -> PagingObject<ResponseType> in

            guard let httpURLResponse = response as? HTTPURLResponse else {
                fatalError("could not cast URLResponse to HTTPURLResponse")
            }

            var pagingObject = try SpotifyWebAPI.decodeSpotifyObject(
                data: data,
                httpURLResponse: httpURLResponse,
                responseType: PagingObject<ResponseType>.self
            )

            pagingObject._getPage = getPage
            return pagingObject
        }
        .eraseToAnyPublisher()
        
        
    }

}
