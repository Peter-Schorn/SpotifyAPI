import Foundation
import Combine

// MARK: Utilities

public extension SpotifyAPI {
    
    /**
     Retrieves the data linked to by an href and decodes it
     into `responseType`.
     
     The access token is automatically refreshed if necessary.
     
     An href is a property provided in many of the responses from
     the Spotify web API which links to addtional data instead of
     including it in the current response in order to limit the size.
     
     For example, the endpoint for getting all of a user's playlists
     returns an href inside of each playlist object which provides
     the full list of tracks.
     
     - Parameters:
       - href: The full URL to a Spotify web API endpoint.
       - responseType: The expected response from the server.
     - Returns: The data decoded into `responseType`.
     */
    func getFromHref<ResponseType: Decodable>(
        _ href: String,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, Error> {
        
        do {
            
            guard let url = URL(string: href) else {
                throw SpotifyLocalError.other(
                    "couldn't convert href to URL: '\(href)'"
                )
            }
            
            return self.refreshTokensAndEnsureAuthorized(for: [])
                .flatMap { accessToken -> AnyPublisher<ResponseType, Error> in
                    
                    self.apiRequestLogger.trace("href: \(href)")
                    
                    return URLSession.shared.dataTaskPublisher(
                        url: url,
                        httpMethod: "GET",
                        headers: Headers.bearerAuthorization(accessToken)
                    )
                    .spotifyDecode(ResponseType.self)
                }
                .eraseToAnyPublisher()
        
        } catch {
            return error.anyFailingPublisher(ResponseType.self)
        }
        
    }

    /**
     Retrieves additional pages of results from a `Paginated`
     type.
     
     This method is also available as a combine operator
     for all publishers where `Output`: `Paginated`.
     
     See also `PagingObject.getPage(atOffset:limit:)`, which
     can be used to request multiple pages asyncronously.
     
     Each time an additional page is received, its `next` property
     is used to retrieve the next page of results, and so on, until
     `next` is `nil` or `maxExtraPages` is reached. This means that
     the next page will not be requested until the previous one
     is received. This also means that the pages will always be
     returned in order.
     
     - Parameters:
       - results: A `Paginated` type; that is, a type that contains
             a link for retrieving the next page of results.
       - maxExtraPages: The maximum number of additional pages to retrieve.
             For example, to just get the next page, use `1`. Leave as
             `nil` (default) to retrieve all pages of results.
     - Returns: A publisher that immediately republishes the `results`
           that were passed in, as well as additional pages that are
           returned by the Spotify web API.
     */
    func extendPages<PaginatedResult: Paginated>(
        _ results: PaginatedResult, maxExtraPages: Int? = nil
    ) -> AnyPublisher<PaginatedResult, Error> {

        let emptyCompletionPublisher = Empty<PaginatedResult, Error>(
            completeImmediately: true
        )
        .eraseToAnyPublisher()
        
        var nextPageIndex = 1
        
        let currentPageSubject =
                CurrentValueSubject<PaginatedResult, Error>(results)
        
        let nextPagePublisher = currentPageSubject
            .flatMap { nextPage -> AnyPublisher<PaginatedResult, Error> in
        
                self.logger.trace("got page at index \(nextPageIndex)")
        
                guard let next = nextPage.next else {
                    // the last page of results has been reached
                    self.logger.trace("next was nil")
                    return emptyCompletionPublisher
                }
        
                // guard nextPageIndex <= maxPages
                guard maxExtraPages.map({ nextPageIndex <= $0 }) ?? true else {
                    // the maximum number of pages requested by the caller
                    // has been reached
                    self.logger.debug(
                        "nextPageIndex > maxPages (\(maxExtraPages as Any))"
                    )
                    return emptyCompletionPublisher
                }
        
                nextPageIndex += 1
        
                self.logger.trace("requesting next page")
                return self.getFromHref(
                    next, responseType: PaginatedResult.self
                )
                .handleEvents(receiveOutput: currentPageSubject.send(_:))
                .eraseToAnyPublisher()
        
            }
            .eraseToAnyPublisher()
        
        return nextPagePublisher
            // the first page was already retrieved before this method
            // was called, so pass it through to downstream subscribers
            .prepend(results)
            .eraseToAnyPublisher()
        
    }
    
}
