import Foundation
import Combine
import Logger

let publisherLogger = Logger(label: "publisher")

public extension Publisher {
    
    /// Wraps all upstream elements in an optional.
    typealias MapToNil = Publishers.Map<Self, Optional<Output>>
    /// Replaces all errors in the stream with `nil`.
    typealias MapErrorToNil = Publishers.ReplaceError<MapToNil>
    
    /// Returns a new publisher in which the output is wrapped in an optional
    /// and errors are replaced with nil.
    /// Therefore, the new publisher never fails.
    func mapErrorToNil() -> MapErrorToNil {
        
        return self
            .map(Optional.init)
            .replaceError(with: nil)
    }
    
    /// Assigns each element from the upstream publisher to
    /// an **optional** property on an object. If the upsteam publisher
    /// fails with an error, then `nil` is assigned to the property.
    ///
    /// - Parameters:
    ///   - keyPath: The key path of the property to assign.
    ///   - object: The object on which to assign the value.
    /// - Returns: A cancellable instance; used when you end assignment
    ///       of the received value. Deallocation of the result
    ///       will tear down the subscription stream.
    func assignToOptional<Root>(
        _ keyPath: ReferenceWritableKeyPath<Root, Optional<Self.Output>>,
        on object: Root
    ) -> AnyCancellable {
        
        return self
            .mapErrorToNil()
            .assign(to: keyPath, on: object)
    }

    /// Logs any errors in the stream.
    func logError(
        _ prefix: String = "",
        to logger: Logger,
        level: Logger.Level = .error
    ) -> Publishers.MapError<Self, Failure>  {
        
        return self.mapError { error in
            logger.log(level: level, "\(prefix) \(error)")
            return error
        }
    }
    
    func logOutput(
        _ prefix: String = "",
        to logger: Logger,
        level: Logger.Level = .trace
    ) -> Publishers.HandleEvents<Self> {
        
        return self.handleEvents(
            receiveOutput: { output in
                logger.log(level: level, "\(prefix) \(output)")
            }
        )
        
    }
    
    
    
    /// Type erases the error to `Error`
    ///
    /// Equivalent to `self.mapError { $0 as Error }`.
    func typeEraseError() -> Publishers.MapError<Self, Error> {
        return self.mapError { $0 as Error }
    }
    
    
    /**
     Transforms all elements from an upstream publisher
     into a new or existing publisher.
    
     `tryFlatMap` merges the output from all returned publishers
     into a single stream of output.
    
     - Parameters:
       - maxPublishers: The maximum number of publishers produced by this method.
       - transform: A **throwing** closure that takes an element as a parameter
             and returns a publisher that produces elements of that type.
     - Returns: A publisher that transforms elements from an
           upstream publisher into a publisher of that element’s type.
     */
    func tryFlatMap<NewPublisher: Publisher>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Self.Output) throws -> NewPublisher
    ) -> Publishers.FlatMap<AnyPublisher<NewPublisher.Output, Error>, Self> {
        
        return flatMap(
            maxPublishers: maxPublishers
        ) { output -> AnyPublisher<NewPublisher.Output, Error> in
            do {
                return try transform(output)
                    .typeEraseError()
                    .eraseToAnyPublisher()
                
            } catch {
                return error.anyFailingPublisher(
                    NewPublisher.Output.self
                )
            }
        }
    }
    
}

public extension Publisher where Output == Data {
    
    /// Decodes the data from upstream into a type
    /// that conforms to `CustomDecodable` by calling its
    /// `decoded(from:)` type method.
    func customDecode<T: CustomDecodable>(
        _ type: T.Type
    ) -> Publishers.TryMap<Self, T> {
        
        return self.tryMap { data in
            try type.decoded(from: data)
        }
        
    }

}

public extension Publisher where Output: CustomEncodable {
    
    /// Encodes the output from upstream that conforms to
    /// `CustomEncodable` into data by calling its `encoded()` method.
    func customEncode() -> Publishers.TryMap<Self, Data> {
        
        return self.tryMap { output in
            try output.encoded()
        }
        
    }
    
}


public extension Publisher where Output == (Data, URLResponse) {

    /// First tries to decode the data into the specified type
    /// that conforms to `CustomDecodable`. If that fails, then
    /// the data is decoded into one of the [errors][1] returned by spotify:
    /// `SpotifyAuthenticationError` and `SpotifyError`.
    /// As a last resort, a `SpotifyLocalError.other` is thrown.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#response-schema:~:text=again.-,Response%20Schema,Web%20API%20uses%20two%20different%20formats%20to%20describe%20an%20error%3A
    func spotifyDecode<ResponseObject: CustomDecodable>(
        _ responseObject: ResponseObject.Type
    ) -> Publishers.TryMap<Publishers.Map<Self,
                (data: Data, response: URLResponse)>, ResponseObject>
    {
       
        return self.map { data, response in
            return (data: data, response: response)
        }
        .spotifyDecode(responseObject.self)
        
    }
    
}

public extension Publisher where Output == (data: Data, response: URLResponse) {
    
    /// First tries to decode the data into the specified type
    /// that conforms to `CustomDecodable`. If that fails, then
    /// the data is decoded into one of the [errors][1] returned by spotify:
    /// `SpotifyAuthenticationError` and `SpotifyError`.
    /// As a last resort, a `SpotifyLocalError.other` is thrown.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/#response-schema:~:text=again.-,Response%20Schema,Web%20API%20uses%20two%20different%20formats%20to%20describe%20an%20error%3A
    func spotifyDecode<ResponseObject: CustomDecodable>(
        _ responseObject: ResponseObject.Type
    ) -> Publishers.TryMap<Self, ResponseObject> {
        
        
        return self.tryMap { data, response -> ResponseObject in
            
            do {
                return try responseObject.decoded(from: data)
            
            } catch {
                
                publisherLogger.warning("couldn't decode response object")
                
                // the two error objects that spotify can return.
                if let error = try? SpotifyAuthenticationError.decoded(from: data) {
                    throw error
                }
                if let error = try? SpotifyError.decoded(from: data) {
                    throw error
                }

                // It's usually a bug if we get to this point.
                publisherLogger.error("couldn't decode a spotify error")
                throw SpotifyLocalError.decodingError(
                    rawData: data,
                    reponseObject: responseObject,
                    statusCode: (response as? HTTPURLResponse)?.statusCode
                )
               
            }
            
        }
        
    }
    
    
    
}


public extension Result.Publisher where Failure == Error {
    
    /// Creates a new publisher by evaluating a throwing closure,
    /// capturing the returned value as a success and
    /// sending it downstream, or immediately failing
    /// with the error thrown from `body`.
    ///
    /// - Parameter body: A throwing closure to evaluate.
    static func catching(_ body: () throws -> Success) -> Self {
        return Self(Result(catching: body))
    }
    
}
