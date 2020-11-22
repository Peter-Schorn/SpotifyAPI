import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineFoundation
#endif
import Logging

/**
 Logs messages related to the decoding of data.
 
 Set the `logLevel` to `trace` to print the raw data received from
 each request to the Spotify web API to the standard outuput.
 
 Set the `logLevel` to `warning` to print various warning and error
 messages to the standard output.
 */
public var spotifyDecodeLogger = Logger(
    label: "spotifyDecode", level: .critical
)

// MARK: - Decode Spotify Objects -

/**
 Tries to decode the raw data from a Spotify web API request
 into one of the error objects that Spotify returns for
 most endpoints.
 
 It is recommended to use the combine operator `decodeSpotifyErrors()`
 instead of this function, whenever possible.
 
 The error objects that this method tries to decode are:
 
 * `SpotifyAuthenticationError`
 * `SpotifyError`
 * `SpotifyPlayerError`
 * `RateLimitedError`
 
 If the data cannot be decoded into one of these errors,
 then `nil` is returned.
 
 - Parameters:
   - data: The data from the server.
   - httpURLResponse: The http response metadata.
 */
public func decodeSpotifyErrors(
    data: Data, httpURLResponse: HTTPURLResponse
) -> Error? {
    
    if spotifyDecodeLogger.logLevel == .trace {
        let dataString = String(data: data, encoding: .utf8) ?? "nil"
        let urlString = httpURLResponse.url?.absoluteString ?? "nil"
        spotifyDecodeLogger.trace(
            """
            will try to decode data from URL '\(urlString)' into error objects:
            \(dataString)
            """
        )
    }
    
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
                """
                got 429 rate limit error, but couldn't \
                get value for "Retry-After" header and/or \
                convert to Int. `HTTPURLResponse.allHeaderFields`:
                \(httpURLResponse.allHeaderFields)
                """
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
        SpotifyPlayerError.self, from:  data
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
        spotifyDecodeLogger.error(
            """
            http response status code was \(statusCode) (error) \
            but couldn't decode error response objects"
            """
        )
    }
    
    spotifyDecodeLogger.trace(
        "couldn't decode above data into error objects"
    )
    return nil
}

/**
 Tries to decode the raw data from a Spotify web API request.
 You normally don't need to call this method directly.
 
 It is recommended to use the combine operator `decodeSpotifyObject(_:)`
 or `decodeOptionalSpotifyObject` instead of this function, whenever
 possible.
 
 First tries to decode the data into `responseType`. If that fails,
 then the data is decoded into one of the [errors][1] returned by
 spotify:
 
 * `SpotifyAuthenticationError`
 * `SpotifyError`
 * `SpotifyPlayerError`
 * `RateLimitedError`
 
 If decoding into the error objects fails, `SpotifyDecodingError` is thrown
 as a last resort.
 
 - Note: `SpotifyDecodingError` represents the error encountered
       when decoding the `responseType`, not the error objects.
 
 - Parameters:
   - responseType: The json response that you are
         are expecting from the Spotify web API.
   - data: The data from the server.
   - httpURLResponse: The http response metadata.
 - Throws: If the data cannot be decoded into the specified `responseType`.
 - Returns: The object decoded into `ResponseType`.
 
 [1]: https://developer.spotify.com/documentation/web-api/#response-schema
 */
public func decodeSpotifyObject<ResponseType: Decodable>(
    data: Data,
    httpURLResponse: HTTPURLResponse,
    responseType: ResponseType.Type
) throws -> ResponseType {

    do {
        
        if spotifyDecodeLogger.logLevel == .trace {
            let dataString = String(data: data, encoding: .utf8)
                    ?? "Couldn't decode data into string"
            let urlString = httpURLResponse.url?.absoluteString ?? "nil"
            spotifyDecodeLogger.trace(
                """
                will try to decode the raw data from the URL '\(urlString)' into \
                '\(responseType)':
                \(dataString)
                """
            )
        }
        
        return try JSONDecoder().decode(
            ResponseType.self, from: data
        )
    
    } catch let responseTypeDecodingError {

        spotifyDecodeLogger.warning(
            "couldn't decode response object for '\(responseType)'"
        )
        
        if let spotifyError = decodeSpotifyErrors(
            data: data, httpURLResponse: httpURLResponse
        ) {
            throw spotifyError
        }
        
        spotifyDecodeLogger.error(
            "couldn't decode '\(responseType)' or the spotify error objects"
        )
        
        /*
         If the data can't be decoded into one of the Spotify
         error objects, then it is probably because Spotify
         did not return an error object; instead, it returned
         the data that was requested, but the data is not properly
         modeled by `responseType`. Therefore, it makes more sense to
         throw the error encountered when decoding the
         expected `responseType` (`responseTypeDecodingError`)
         back to the caller.
         */
        throw SpotifyDecodingError(
            url: httpURLResponse.url,
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
     most endpoints.
     
     The error objects that this method tries to decode are:
     
     * `SpotifyAuthenticationError`
     * `SpotifyError`
     * `SpotifyPlayerError`
     * `RateLimitedError`
     
     If the data can be decoded into one of these errors,
     then this error object is thrown as an error to downstream subscribers.
     Otherwise, the data is passed through unmodified to downstream
     subscribers.
     
     - Warning: This method force-downcasts `URLResponse` to
           `HTTPURLResponse`. Only use this method if you are making an
            HTTP request.
     */
    func decodeSpotifyErrors() -> AnyPublisher<Self.Output, Error> {

        return self.tryMap { data, response in

            guard let httpURLResponse = response as? HTTPURLResponse else {
                fatalError(
                    "could not cast URLResponse to HTTPURLResponse:\n\(response)"
                )
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

     Use `decodeOptionalSpotifyObject(_:)` instead if the data might be empty.
     Simply passing in an optional type does not work because empty data is
     not considered valid json.
     
     First tries to decode the data into `responseType`. If that fails,
     then the data is decoded into one of the [errors][1] returned by
     spotify:

     * `SpotifyAuthenticationError`
     * `SpotifyError`
     * `SpotifyPlayerError`
     * `RateLimitedError`

     If decoding into the error objects fails, `SpotifyDecodingError` is thrown
     as a last resort.

     **Note**: `SpotifyDecodingError` represents the error encountered
     when decoding the `responseType`, not the error objects.

     - Parameter responseType: The json response that you are
     are expecting from the Spotify web API.

     - Warning: This method force-downcasts `URLResponse` to
           `HTTPURLResponse`. Only use this method if you are making an
            HTTP request.
     
     [1]: https://developer.spotify.com/documentation/web-api/#response-schema
     */
    func decodeSpotifyObject<ResponseType: Decodable>(
        _ responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {

        return self.tryMap { data, response -> ResponseType in

            guard let httpURLResponse = response as? HTTPURLResponse else {
                fatalError(
                    "could not cast URLResponse to HTTPURLResponse:\n\(response)"
                )
            }

            return try SpotifyWebAPI.decodeSpotifyObject(
                data: data,
                httpURLResponse: httpURLResponse,
                responseType: responseType
            )

        }
        .eraseToAnyPublisher()

    }

    /**
     Tries to decode the raw data from a Spotify web API request.
     You normally don't need to call this method directly.

     Unlike `decodeSpotifyObject(_:)`, first checks to see if the data
     is empty. If so, returns `nil`. Simply passing in an optional type
     to `decodeSpotifyObject(_:)` does not work because empty data is not
     considered valid json.
     
     First tries to decode the data into `responseType`. If that fails,
     then the data is decoded into one of the [errors][1] returned by
     spotify:

     * `SpotifyAuthenticationError`
     * `SpotifyError`
     * `SpotifyPlayerError`
     * `RateLimitedError`

     If decoding into the error objects fails, `SpotifyDecodingError` is thrown
     as a last resort.

     **Note**: `SpotifyDecodingError` represents the error encountered
     when decoding the `responseType`, not the error objects.

     - Parameter responseType: The json response that you are
     are expecting from the Spotify web API.

     - Warning: This method force-downcasts `URLResponse` to
           `HTTPURLResponse`. Only use this method if you are making an
            HTTP request.
     
     [1]: https://developer.spotify.com/documentation/web-api/#response-schema
     */
    func decodeOptionalSpotifyObject<ResponseType: Decodable>(
        _ responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, Error> {
        
        return self.tryMap { data, response -> ResponseType? in

            guard let httpURLResponse = response as? HTTPURLResponse else {
                fatalError(
                    "could not cast URLResponse to HTTPURLResponse:\n\(response)"
                )
            }

            if data.isEmpty { return nil }
            
            return try SpotifyWebAPI.decodeSpotifyObject(
                data: data,
                httpURLResponse: httpURLResponse,
                responseType: responseType
            )

        }
        .eraseToAnyPublisher()

    }

}
