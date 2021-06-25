import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import Logging

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 Logs messages related to the decoding of data.
 
 Set the `logLevel` to `trace` to log the raw data received from each request
 to the Spotify web API.

 Set the `logLevel` to `warning` to log various warning and error messages.
 */
public var spotifyDecodeLogger = Logger(
    label: "spotifyDecode", level: .critical
)

// MARK: - Decode Spotify Objects -

/**
 Tries to decode the raw data from a Spotify web API request into one of the
 error objects that Spotify returns.

 You are encouraged to use the combine operator `decodeSpotifyErrors()` instead
 of this function, whenever possible. The combine operator version will
 automatically retry the request up to three times depending on the error
 received. This function does not.

 **If the http response contains a successful status code, then returns** `nil`.

 If the status code of the http response is in the 4xx or 5xx range, then tries
 to decode the data into one of the following objects:
 
 * ``SpotifyAuthenticationError``
 * ``SpotifyError``
 * ``SpotifyPlayerError``
 * ``RateLimitedError``
 
 If the data cannot be decoded into one of these errors then
 ``SpotifyGeneralError``.``SpotifyGeneralError/httpError(_:_:)`` is returned.
 
 - Parameters:
   - data: The data from the server.
   - httpURLResponse: The http response metadata.
 */
public func decodeSpotifyErrors(
    data: Data, httpURLResponse: HTTPURLResponse
) -> Error? {
    
    let errorStatusCodeRange = 400..<600
    guard errorStatusCodeRange.contains(httpURLResponse.statusCode) else {
        return nil
    }

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
    
    // indicates that there was a rate-limited error
    if httpURLResponse.statusCode == 429 {
        
        let lowercasedHeaders: [String: String] = httpURLResponse.allHeaderFields
            .reduce(into: [:], { dict, header in
                if let key = header.key as? String,
                        let value = header.value as? String {
                    dict[key.lowercased()] = value
                }
            })
        
        let retryAfter = lowercasedHeaders["retry-after"]
            .flatMap(Int.init)
            
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
    
    return SpotifyGeneralError.httpError(data, httpURLResponse)
    
}

/**
 Tries to decode the raw data from a Spotify web API request. You normally don't
 need to call this method directly.

 You are encouraged to use the combine operator `decodeSpotifyObject(_:)` or
 `decodeOptionalSpotifyObject` instead of this function, whenever possible. The
 combine operator version will automatically retry the request up to three times
 depending on the error received. This function does not.

 If the status code of the http response is in the 4xx or 5xx range, then the
 data will be decoded into one of the [errors][1] returned by Spotify via
 ``decodeSpotifyErrors(data:httpURLResponse:)``:
 
 * ``SpotifyAuthenticationError``
 * ``SpotifyError``
 * ``SpotifyPlayerError``
 * ``RateLimitedError``
 * ``SpotifyGeneralError``.``SpotifyGeneralError/httpError(_:_:)``
 
 If a successful status code is returned, then tries to decode the data into
 `responseType`. If that fails, then ``SpotifyDecodingError`` is thrown as a
 last resort.
 
 - Note: ``SpotifyDecodingError`` represents the error encountered when decoding
       the `responseType`, not the error objects.
 
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

    if let spotifyError = decodeSpotifyErrors(
        data: data, httpURLResponse: httpURLResponse
    ) {
        throw spotifyError
    }

    if spotifyDecodeLogger.logLevel == .trace {
        let dataString = String(data: data, encoding: .utf8)
            ?? "Couldn't decode data into string"
        let urlString = httpURLResponse.url?.absoluteString ?? "nil"
        spotifyDecodeLogger.trace(
            """
            will try to decode the raw data from the URL '\(urlString)' \
            into '\(responseType)':
            \(dataString)
            """
        )
    }
    
    do {
        
        return try JSONDecoder().decode(
            ResponseType.self, from: data
        )
    
    } catch let responseTypeDecodingError {

        spotifyDecodeLogger.warning(
            "couldn't decode response object for '\(responseType)'"
        )
        
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

public extension Publisher where Output == (data: Data, response: HTTPURLResponse) {

    /**
     Tries to decode the raw data from a Spotify web API request
     into one of the error objects that Spotify returns.
     
     If a successful status code is returned, then the data is passed through
     unmodified to downstream subscribers.

     If the status code is in the 4xx or 5xx range, then tries to decode
     the data into one of the following objects and throws it as an error
     to downstream subscribers:

     * ``SpotifyAuthenticationError``
     * ``SpotifyError``
     * ``SpotifyPlayerError``
     * ``RateLimitedError``
     
     If the data cannot be decoded into one of these errors, then
     ``SpotifyGeneralError``.``SpotifyGeneralError/httpError(_:_:)`` is thrown
     as an error to downstream subscribers.
     
     Automatically retries the request up to three times, depending on the
     error received. Retries upon receiving a ``RateLimitedError``. If a
     ``SpotifyError``, ``SpotifyPlayerError``, or
     ``SpotifyGeneralError``.``SpotifyGeneralError/httpError(_:_:)`` is
     received, then retries if the status code is 500, 502, 503, or 504.
     */
    func decodeSpotifyErrors() -> AnyPublisher<Self.Output, Error> {
        return self.tryMap { data, response in
            
            if let error = SpotifyWebAPI.decodeSpotifyErrors(
                data: data, httpURLResponse: response
            ) {
                throw error
            }
            
            return (data, response)
            
        }
        .retryOnSpotifyErrors()
        
    }

    /**
     Tries to decode the raw data from a Spotify web API request.
     You normally don't need to call this method directly.

     Use `decodeOptionalSpotifyObject(_:)` instead if the data might be empty.
     Simply passing in an optional type does not work because empty data is
     not considered valid json.
     
     If the status code of the http response is in the 4xx or 5xx range,
     then the data will be decoded into one of the [errors][1] returned by
     Spotify via ``decodeSpotifyErrors(data:httpURLResponse:)``:
     
     * ``SpotifyAuthenticationError``
     * ``SpotifyError``
     * ``SpotifyPlayerError``
     * ``RateLimitedError``
     * ``SpotifyGeneralError``.``SpotifyGeneralError/httpError(_:_:)``
     
     If a successful status code is returned, then tries to decode the data into
     `responseType`. If that fails, then ``SpotifyDecodingError`` is thrown as a
     last resort.
     
     Automatically retries the request up to three times, depending on the error
     received. Retries upon receiving a ``RateLimitedError``. If a
     ``SpotifyError``, ``SpotifyPlayerError``, or
     ``SpotifyGeneralError``.``SpotifyGeneralError/httpError(_:_:)`` is
     received, then retries if the status code is 500, 502, 503, or 504.
     
     - Note: ``SpotifyDecodingError`` represents the error encountered when
           decoding the `responseType`, not the error objects.

     - Parameter responseType: The json response that you are expecting from the
           Spotify web API.
     
     [1]: https://developer.spotify.com/documentation/web-api/#response-schema
     */
    func decodeSpotifyObject<ResponseType: Decodable>(
        _ responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {

        return self.tryMap { data, response -> ResponseType in

            return try SpotifyWebAPI.decodeSpotifyObject(
                data: data,
                httpURLResponse: response,
                responseType: responseType
            )

        }
        .retryOnSpotifyErrors()

    }

    /**
     Tries to decode the raw data from a Spotify web API request. You normally
     don't need to call this method directly.

     Unlike `decodeSpotifyObject(_:)`, first checks to see if the data is empty.
     If so, returns `nil`. Simply passing in an optional type to
     `decodeSpotifyObject(_:)` does not work because empty data is not
     considered valid json.

     If the status code of the http response is in the 4xx or 5xx range, then
     the data will be decoded into one of the [errors][1] returned by Spotify
     via ``decodeSpotifyErrors(data:httpURLResponse:)``:
     
     * ``SpotifyAuthenticationError``
     * ``SpotifyError``
     * ``SpotifyPlayerError``
     * ``RateLimitedError``
     * ``SpotifyGeneralError``.``SpotifyGeneralError/httpError(_:_:)``
     
     If a successful status code is returned, then tries to decode the data into
     `responseType`. If that fails, then ``SpotifyDecodingError`` is thrown as a
     last resort.

     Automatically retries the request up to three times, depending on the error
     received. Retries upon receiving a ``RateLimitedError``. If a
     ``SpotifyError``, ``SpotifyPlayerError``, or
     ``SpotifyGeneralError``.``SpotifyGeneralError/httpError(_:_:)`` is
     received, then retries if the status code is 500, 502, 503, or 504.
     
     - Note: ``SpotifyDecodingError`` represents the error encountered when
           decoding the `responseType`, not the error objects.

     - Parameter responseType: The json response that you are expecting from the
           Spotify web API.

     [1]: https://developer.spotify.com/documentation/web-api/#response-schema
     */
    func decodeOptionalSpotifyObject<ResponseType: Decodable>(
        _ responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, Error> {
        
        return self.tryMap { data, response -> ResponseType? in

            let errorStatusCodeRange = 400..<600

            if data.isEmpty &&
                    !errorStatusCodeRange.contains(response.statusCode) {
                // only return `nil` if a successful status code is returned
                return nil
            }
            
            return try SpotifyWebAPI.decodeSpotifyObject(
                data: data,
                httpURLResponse: response,
                responseType: responseType
            )

        }
        .retryOnSpotifyErrors()

    }

}
