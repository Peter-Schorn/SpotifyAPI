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

public extension SpotifyAPI {

    // MARK: Utilities
    
    /**
     Retrieves the data linked to by an href and decodes it into `responseType`.

     An href is a URL provided in many of the responses from the Spotify web API
     which links to additional data instead of including it in the current
     response in order to limit the size.

     Always prefer using a different method whenever possible because this
     method adds the additional complexity of determining the appropriate
     `ResponseType`.
     
     - Parameters:
       - href: The full URL to a Spotify web API endpoint.
       - responseType: The expected response from the server.
     - Returns: The data decoded into `responseType`.
     */
    func getFromHref<ResponseType: Decodable>(
        _ href: URL,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {
        
        return self.apiRequest(
            url: href,
            httpMethod: "GET",
            makeHeaders: Headers.bearerAuthorization(_:),
            bodyData: nil,
            requiredScopes: []
        )
        .decodeSpotifyObject(ResponseType.self)
        
    }

    /**
     Retrieves additional pages of results from a ``Paginated`` type.

     This method is also available as a combine operator of the same name for
     all publishers where `Output`: ``Paginated``.

     Compare with ``SpotifyAPI/extendPagesConcurrently(_:maxExtraPages:)``.

     Each time an additional page is received, its ``PagingObject/next``
     property is used to retrieve the next page of results, and so on, until
     ``PagingObject/next`` is `nil` or `maxExtraPages` is reached. This means
     that the next page will not be requested until the previous one is received
     and that the pages will always be returned in order.

     See <doc:Working-with-Paginated-Results>.

     - Parameters:
       - page: A ``Paginated`` type; that is, a type that contains a link for
             retrieving the next page of results.
       - maxExtraPages: The maximum number of additional pages to retrieve. For
             example, to just get the next page, use `1`. Leave as `nil`
             (default) to retrieve all pages of results.
     - Returns: A publisher that immediately republishes the page that was
           passed in, as well as additional pages that are returned by the
           Spotify web API.
     */
    func extendPages<Page: Paginated>(
        _ page: Page, maxExtraPages: Int? = nil
    ) -> AnyPublisher<Page, Error> {

        // indicates that there are no more pages to return
        let emptyCompletionPublisher = Empty<Page, Error>(
            completeImmediately: true
        )
        .eraseToAnyPublisher()
        
        var nextPageIndex = 1
        
        let currentPageSubject =
                CurrentValueSubject<Page, Error>(page)
        
        let nextPagePublisher = currentPageSubject
            .flatMap { nextPage -> AnyPublisher<Page, Error> in
        
                self.logger.trace("got page at index \(nextPageIndex)")
        
                guard let next = nextPage.next else {
                    // the last page of results has been reached
                    self.logger.trace("next was nil")
                    currentPageSubject.send(completion: .finished)
                    return emptyCompletionPublisher
                }
        
                if let max = maxExtraPages, nextPageIndex > max {
                    // the maximum number of pages requested by the caller
                    // have been reached
                    self.logger.debug(
                        "nextPageIndex (\(nextPageIndex)) > maxPages (\(max))"
                    )
                    currentPageSubject.send(completion: .finished)
                    return emptyCompletionPublisher
                }
        
                nextPageIndex += 1
        
                self.logger.trace("requesting next page")
                return self.getFromHref(
                    next, responseType: Page.self
                )
                .handleEvents(receiveOutput: currentPageSubject.send(_:))
                .eraseToAnyPublisher()
        
            }
        
        return nextPagePublisher
            // A page of results (not necessarily the first) was already
            // retrieved before this method was called, so pass it through
            // to downstream subscribers.
            .prepend(page)
            .eraseToAnyPublisher()
        
    }
    
    // Publishers.MergeMany is not implemented in OpenCombine yet :(
    #if canImport(Combine)
    /**
     Retrieves additional pages of results from a paging object *concurrently*.
     
     This method is also available as a combine operator of the same name for
     all publishers where the output is a paging object.

     Compare with ``SpotifyAPI/extendPages(_:maxExtraPages:)``.

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
       - page: A paging object.
       - maxExtraPages: The maximum number of additional pages to retrieve. For
             example, to just get the next page, use `1`. Leave as `nil`
             (default) to retrieve all pages of results.
     - Returns: A publisher that immediately republishes the `page` that was
           passed in, as well as additional pages that are returned by the
           Spotify web API.
     */
    func extendPagesConcurrently<Page: PagingObjectProtocol>(
        _ page: Page,
        maxExtraPages: Int? = nil
    ) -> AnyPublisher<Page, Error> {
        
        guard var hrefComponents = URLComponents(
            url: page.href, resolvingAgainstBaseURL: false
        ) else {
            return SpotifyGeneralError.other(
                #"couldn't create URLComponents from href "\#(page.href)""#
            )
            .anyFailingPublisher()
        }
        // remove the offset and limit query items from the URL if
        // they exist
        hrefComponents.queryItems?.removeAll(where: { queryItem in
            ["offset", "limit"].contains(queryItem.name)
        })
        if hrefComponents.queryItems == nil {
            // ensure that append operations to the query items
            // succeed
            hrefComponents.queryItems = []
        }
        
        hrefComponents.queryItems!.append(
            URLQueryItem(name: "limit", value: "\(page.limit)")
        )
        
        var pagePublishers: [AnyPublisher<Page, Error>] = []

        // republish the current page that was passed in
        let currentPagePublisher = Result<Page, Error>
            .Publisher(page)
            .eraseToAnyPublisher()
        
        pagePublishers.append(currentPagePublisher)

        let maxOffset: Int

        if let maxExtraPages = maxExtraPages {
            let theoreticalOffset = page.offset + (page.limit * maxExtraPages)
//            print("theoreticalOffset:", theoreticalOffset)
            maxOffset = min(theoreticalOffset, page.total - 1)
        }
        else {
            maxOffset = (page.total - 1)
        }
        
//        print("maxOffset:", maxOffset, terminator: "\n\n")

        // generate the offsets for each page that needs to be requested
        for offset in stride(
            // the offset of the page after the current one
            from: page.offset + page.limit,
            through: maxOffset,
            // the number of items in each page
            by: page.limit
        ) {
            
            var pageHrefComponents = hrefComponents
            // to create an href for a different page, all we need
            // to do is change the offset query item
            pageHrefComponents.queryItems!.append(
                URLQueryItem(name: "offset", value: "\(offset)")
            )
            guard let pageHref = pageHrefComponents.url else {
                self.logger.error(
                    #"couldn't create URL for page from "\#(pageHrefComponents)""#
                )
                continue
            }
            let pagePublisher = self.getFromHref(
                pageHref, responseType: Page.self
            )
            pagePublishers.append(pagePublisher)

        }
        
        return Publishers.MergeMany(pagePublishers)
            .eraseToAnyPublisher()

    }
    #endif
    
}
