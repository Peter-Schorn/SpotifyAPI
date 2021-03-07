#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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
     A convenience wrapper for sink that only requires a `receiveCompletion`
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

#if canImport(Combine)
typealias ResultPublisher<Success, Failure: Error> =
    Result<Success, Failure>.Publisher
#else
typealias ResultPublisher<Success, Failure: Error> =
    Result<Success, Failure>.OCombine.Publisher
#endif


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

extension Publisher where Output == (data: Data, response: HTTPURLResponse) {
    
    /**
     Casts `(data: Data, response: HTTPURLResponse)` to
     `(data: Data, response: URLResponse)`.
    
     `URLResponse` is a superclass of `HTTPURLResponse`, so this cast
     can never fail.
     */
    func castToURLResponse() -> AnyPublisher<(data: Data, response: URLResponse), Failure> {
        return self.map { data, response in
            let urlResponse = response as URLResponse
            return (data: data, response: urlResponse)
        }
        .eraseToAnyPublisher()
    }

} 
