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

extension Publishers {
    
    /**
     Conditionally retries the request for the specified delay.
     
     Adapted from [here][1].
     
     [1]: https://stackoverflow.com/a/64942348/12394554
     */
    struct DelayedConditionalRetry<P: Publisher, S: Scheduler>: Publisher {
        
        typealias Output = P.Output
        typealias Failure = P.Failure
        
        let publisher: P
        let times: Int
        let scheduler: S
        let options: S.SchedulerOptions?

        /**
         A predicate that determines whether the request should be retried and
         the delay to add before retrying it. Return `nil` to indicate that the
         request should not be retried.
         */
        let condition: (
            _ additionalRetries: Int,
            _ error: Failure
        ) -> S.SchedulerTimeType.Stride?
        
        init(
            publisher: P,
            times: Int,
            scheduler: S,
            options: S.SchedulerOptions?,
            condition: @escaping (
                _ additionalRetries: Int,
                _ error: Failure
            ) -> S.SchedulerTimeType.Stride?
        ) { 
            self.publisher = publisher
            self.times = times
            self.scheduler = scheduler
            self.options = options
            self.condition = condition
        }

        func receive<S: Subscriber>(
            subscriber: S
        ) where S.Failure == Failure, S.Input == Output {

            guard self.times > 0 else {
                return self.publisher.subscribe(subscriber)
            }

            self.publisher
                .catch { error -> AnyPublisher<Output, Failure> in
                    
                    if let delay = self.condition(self.times, error) {
//                        if let magnitude = delay.magnitude as? Int {
//                            let secondsDelay = Double(magnitude) / 1_000_000_000
//                            Swift.print(
//                                "times: \(self.times); delaying for \(secondsDelay) seconds\n"
//                            )
//                        }
                        
                        // using a Result.Publisher along with the delay
                        // operator leads to data race issues that sometimes
                        // cause the completion event to be sent before the
                        // value.
                        
                        return Future<Void, Failure> { promise in
                            
                            self.scheduler.schedule(
                                after: self.scheduler.now.advanced(by: delay),
                                tolerance: self.scheduler.minimumTolerance,
                                options: self.options
                            ) {
                                promise(.success(()))
                            }
                            
                        }
                        .flatMap {
                            DelayedConditionalRetry(
                                publisher: self.publisher,
                                times: self.times - 1,
                                scheduler: self.scheduler,
                                options: self.options,
                                condition: self.condition
                            )
                        }
                        .eraseToAnyPublisher()
                    
                    }
                    else {
                        return Fail(error: error)
                            .eraseToAnyPublisher()
                    }
                    
                }
                .subscribe(subscriber)
            
        }
    }
    
    static let retryQueue = DispatchQueue(
        label: "SpotifyAPI.DelayedConditionalRetry"
    )

}

extension Publisher {
    
    func retry<S: Scheduler>(
        times: Int,
        scheduler: S,
        options: S.SchedulerOptions? = nil,
        if condition: @escaping (
            _ additionalRetries: Int,
            _ error: Failure
        ) -> S.SchedulerTimeType.Stride?
    ) -> Publishers.DelayedConditionalRetry<Self, S> {
        return Publishers.DelayedConditionalRetry(
            publisher: self,
            times: times,
            scheduler: scheduler,
            options: options,
            condition: condition
        )
    }
    
    /**
     Retries the request up to three times depending on the error received.
     
     Retries upon receiving a ``RateLimitedError``. If a ``SpotifyError``,
     ``SpotifyPlayerError``, or
     ``SpotifyGeneralError``.``SpotifyGeneralError/httpError(_:_:)`` is
     received, then retries if the status code is 500, 502, 503, or 504.
     */
    func retryOnSpotifyErrors() -> AnyPublisher<Output, Failure> {
        
        return self.retry(
            times: 3,
            scheduler: Publishers.retryQueue
        ) { additionalRetries, error in
//            Swift.print(
//                "retryOnSpotifyError: additionalRetries: " +
//                    "\(additionalRetries). Error: \(error)"
//            )
            
            if let rateLimitedError = error as? RateLimitedError {
                #if DEBUG
                DebugHooks.receiveRateLimitedError.send(rateLimitedError)
                #endif
    //            Swift.print("retryOnRateLimitedError: \(rateLimitedError)")
                let secondsDelay = (rateLimitedError.retryAfter ?? 3) + 1
                
                switch additionalRetries {
                    case 3:
                        return .seconds(secondsDelay)
                    // Adding random delays improves the success rate
                    // of concurrent requests. If all requests were
                    // serialized, then we would never get a rate
                    // limited error more than once per request in the
                    // first place.
                    case 2:
                        var millisecondsDelay = secondsDelay * 1_000
                        // + 0...5 seconds
                        millisecondsDelay += Int.random(in: 0...5_000)
                        return .milliseconds(millisecondsDelay)
                    default /* 1 */:
                        var millisecondsDelay = secondsDelay * 1000
                        // + 5...10 seconds
                        millisecondsDelay += Int.random(in: 5_000...10_000)
                        return .milliseconds(millisecondsDelay)
                }
            }

            // the status codes for which it makes sense to retry the request.
            // https://developer.spotify.com/documentation/web-api/#response-status-codes
            let retryableStatusCodes = [500, 502, 503, 504]

            let statusCode: Int
            
            if let spotifyError = error as? SpotifyError {
                statusCode = spotifyError.statusCode
            }
            else if let spotifyPlayerError = error as? SpotifyPlayerError {
                statusCode = spotifyPlayerError.statusCode
            }
            else if case .httpError(_, let response) = error as? SpotifyGeneralError {
                statusCode = response.statusCode
            }
            else {
                return nil
            }
            
            if retryableStatusCodes.contains(statusCode) {
                return .seconds(1)
            }
            
            return nil

        }
        .eraseToAnyPublisher()

    }
    
}
