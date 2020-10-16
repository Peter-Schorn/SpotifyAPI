import Foundation
import Combine
import Logging

public extension Publisher where Output: Paginated {
   
    /**
     Retrieves additional pages of results from a `Paginated`
     type.
     
     Each time an additional page is received, its `next` property
     is used to retrieve the next page of results, and so on, until
     `next` is `nil` or `maxExtraPages` is reached. This means that
     the next page will not be requested until the previous one
     is received. This also means that the pages will always be
     returned in order.
     
     - Parameters:
       - spotify: An instance of `SpotifyAPI`, which is required for
             accessing the access token required to make requests to
             the Spotify web API. The access token will also be refreshed if
             needed.
       - maxExtraPages: The maximum number of additional pages to retrieve.
             For example, to just get the next page, use `1`. Leave as
             `nil` (default) to retrieve all pages of results.
     - Returns: A publisher that immediately republishes the output
           from the upstream publisher, as well as additional pages that are
           returned by the Spotify web API.
     */
    func extendPages<AuthorizationManager: SpotifyAuthorizationManager>(
        _ spotify: SpotifyAPI<AuthorizationManager>,
        maxExtraPages: Int? = nil
    ) -> AnyPublisher<Output, Error> {
    
        return self
            .mapError { $0 as Error }
            .flatMap { results in
                spotify.extendPages(
                    results, maxExtraPages: maxExtraPages
                )
            }
            .eraseToAnyPublisher()
        
    }
    
}

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
    
    /**
     Assigns each element from the upstream publisher to
     an **optional** property on an object. If the upsteam publisher
     fails with an error, then `nil` is assigned to the property.
    
     - Parameters:
       - keyPath: The key path of the property to assign.
       - object: The object on which to assign the value.
     - Returns: A cancellable instance; used when you end assignment
           of the received value. Deallocation of the result
           will tear down the subscription stream.
     */
    func assignToOptional<Root>(
        _ keyPath: ReferenceWritableKeyPath<Root, Optional<Self.Output>>,
        on object: Root
    ) -> AnyCancellable {
        
        return self
            .mapErrorToNil()
            .assign(to: keyPath, on: object)
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
    ) -> Publishers.FlatMap<
            AnyPublisher<NewPublisher.Output, Error>, Self> {
        
        return flatMap(
            maxPublishers: maxPublishers
        ) { output -> AnyPublisher<NewPublisher.Output, Error> in
            
            do {
                return try transform(output)
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
                
            } catch {
                return error.anyFailingPublisher()
            }
            
        }
        
    }
    
}

public extension Publisher where Output == Void {
    
    /**
     A convience wrapper for sink that only requires a `receiveCompletion`
     closure. Available when `Output` == `Void`.
     
     You are discouraged from using trailing closure syntax with this
     method in order to avoid confusion with `sink(receiveValue:)`
     (available when `Failure` == `Never`).
     
     This method creates the subscriber and immediately requests an
     unlimited number of values, prior to returning the subscriber.
     
     - Parameter receiveCompletion: The closure to execute on completion.
     - Returns: A subscriber that performs the provided closure upon
           receiving completion.
     */
    func sink(
        receiveCompletion: @escaping (Subscribers.Completion<Self.Failure>) -> Void
    ) -> AnyCancellable {
        
        return self
            .sink(
                receiveCompletion: receiveCompletion,
                receiveValue: { }
            )
        
    }
    
}

public extension Result.Publisher where Failure == Error {
    
    /**
     Creates a new publisher by evaluating a throwing closure,
     capturing the returned value as a success and
     sending it downstream, or immediately failing
     with the error thrown from `body`.
    
     - Parameter body: A throwing closure to evaluate.
     */
    static func catching(_ body: () throws -> Success) -> Self {
        return Self(Result(catching: body))
    }
    
}

public extension Error {
    
    /**
     Returns `AnyPublisher` with the specified output type.
     The error type is `self` type-erased to `Error`.
    
     Equivalent to
     ```
     Fail<Output, Error>(error: self).eraseToAnyPublisher()
     ```
    
     - Parameter outputType: The output type for the publisher.
           It can usually be inferred from the context.
     */
    func anyFailingPublisher<Output>(
        _ outputType: Output.Type = Output.self
    ) -> AnyPublisher<Output, Error> {
        
        return Fail<Output, Error>(error: self)
            .eraseToAnyPublisher()
    
    }
    
}
