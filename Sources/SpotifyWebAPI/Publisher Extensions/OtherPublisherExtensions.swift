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
     Retrieves additional pages of results from a ``Paginated`` type.
     
     See also ``SpotifyAPI/extendPages(_:maxExtraPages:)``.
     
     Compare with `Publisher.extendPagesConcurrently(_:maxExtraPages:)`.

     Each time an additional page is received, its `next` property is used to
     retrieve the next page of results, and so on, until `next` is `nil` or
     `maxExtraPages` is reached. This means that the next page will not be
     requested until the previous one is received and that the pages will always
     be returned in order.
     
     See <doc:Working-with-Paginated-Results>.

     - Parameters:
       - spotify: An instance of ``SpotifyAPI``, which is required for
             accessing the access token required to make requests to the Spotify
             web API. The access token will also be refreshed if needed.
       - maxExtraPages: The maximum number of additional pages to retrieve. For
             example, to just get the next page, use `1`. Leave as `nil`
             (default) to retrieve all pages of results.
     - Returns: A publisher that immediately republishes the page received from
           the upstream publisher, as well as additional pages that are returned
           by the Spotify web API.
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

public extension Publisher where Output: PagingObjectProtocol {
    
    // Publishers.MergeMany is not implemented in OpenCombine yet :(
    #if canImport(Combine)
    /**
     Retrieves additional pages of results from a paging object *concurrently*.

     See also ``SpotifyAPI/extendPagesConcurrently(_:maxExtraPages:)``.

     Compare with `Publisher.extendPages(_:maxExtraPages:)`.

     This method immediately republishes the page of results that were passed in
     and then requests additional pages *concurrently*. This method has better
     performance than ``SpotifyAPI/extendPages(_:maxExtraPages:)``, which must
     wait for the previous page to be received before requesting the next page.
     **However, the order in which the pages are received is unpredictable.** If
     you need to wait for all pages to be received before processing them, then
     always use this method.
     
     See <doc:Working-with-Paginated-Results>.

     See also `Publisher.collectAndSortByOffset()`.
     
     - Parameters:
       - spotify: An instance of ``SpotifyAPI``, which is required for
             accessing the access token required to make requests to the Spotify
             web API. The access token will also be refreshed if needed.
       - maxExtraPages: The maximum number of additional pages to retrieve. For
             example, to just get the next page, use `1`. Leave as `nil`
             (default) to retrieve all pages of results.
     - Returns: A publisher that immediately republishes the page received from
           the upstream publisher, as well as additional pages that are returned
           by the Spotify web API.
     */
    func extendPagesConcurrently<AuthorizationManager: SpotifyAuthorizationManager>(
        _ spotify: SpotifyAPI<AuthorizationManager>,
        maxExtraPages: Int? = nil
    ) -> AnyPublisher<Output, Error> {
        
        return self
            .mapError { $0 as Error }
            .flatMap { page -> AnyPublisher<Output, Error> in
                spotify.extendPagesConcurrently(
                    page, maxExtraPages: maxExtraPages
                )
            }
            .eraseToAnyPublisher()
        
    }
    #endif

    /**
     Collects the items from all the pages that are delivered by the upstream
     publisher and then sorts the items based on the offset of each page they
     were received in.

     This method is particularly useful in combination with
     `Publisher.extendPagesConcurrently(_:maxExtraPages:)`, which delivers pages
     in an unpredictable order. It waits for all pages to be delivered and then
     sorts them by their offset and returns just the items in the pages.

     See <doc:Working-with-Paginated-Results>.
     */
    func collectAndSortByOffset() -> AnyPublisher<[Output.Item], Failure> {
        
        return self
            .collect()
            .map { pages in
                return pages
                    .sorted(by: { $0.offset < $1.offset })
                    .flatMap(\.items)
            }
            .eraseToAnyPublisher()

    }

}

public extension Publisher where Output == Void {
    
    /**
     A convenience wrapper for sink that only requires a `receiveCompletion`
     closure. Available when `Output` == `Void`.
     
     You are discouraged from using trailing closure syntax with this method in
     order to avoid confusion with `sink(receiveValue:)` (available when
     `Failure` == `Never`).

     This method creates the subscriber and immediately requests an unlimited
     number of values, prior to returning the subscriber.

     - Parameter receiveCompletion: The closure to execute on completion.
     - Returns: A subscriber that performs the provided closure upon receiving
           completion.
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

public extension Error {
    
    /**
     Returns `AnyPublisher` with the specified output type. The error type is
     `self` type-erased to `Error`.
    
     Equivalent to
     ```
     Fail<Output, Error>(error: self).eraseToAnyPublisher()
     ```
    
     - Parameter outputType: The output type for the publisher. It can usually
           be inferred from the context.
     */
    func anyFailingPublisher<Output>(
        _ outputType: Output.Type = Output.self
    ) -> AnyPublisher<Output, Error> {
        
        return Fail<Output, Error>(error: self)
            .eraseToAnyPublisher()
    
    }
    
}

#if canImport(Combine)
typealias ResultPublisher<Success, Failure: Error> =
    Result<Success, Failure>.Publisher
#else
typealias ResultPublisher<Success, Failure: Error> =
    Result<Success, Failure>.OCombine.Publisher
#endif
