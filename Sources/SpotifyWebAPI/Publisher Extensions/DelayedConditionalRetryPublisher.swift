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

        func receive<Sub: Subscriber>(
            subscriber: Sub
        ) where Sub.Failure == Failure, Sub.Input == Output {

            guard self.times > 0 else {
                return self.publisher.subscribe(subscriber)
            }

            self.publisher
                .catch { error -> AnyPublisher<Output, Failure> in
                    
                    if let delay = self.condition(self.times, error) {
                        // if let magnitude = delay.magnitude as? Int {
                        //     let secondsDelay = Double(magnitude) / 1_000_000_000
                        //     Swift.print(
                        //         "times: \(self.times); delaying for \(secondsDelay) seconds\n"
                        //     )
                        // }

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
     
     - Parameter maxRetryDelay: The maximum delay in seconds (accumulated over
           all retries before the publisher finishes with a error, e.g., ``RateLimitedError``. Default: 180 secs (3 minutes).
     - Returns: A publisher that retries depending on the error received and
           can fail with an error after a max retry delay has elasped
           (deault: 3 minutes).
     */
    func retryOnSpotifyErrors(
        maxRetryDelay: Int = 180  // 3 minutes
    ) -> AnyPublisher<Output, Failure> {

        // captured by the closure
        var accumulatedDelayMS = 0

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


                // MARK: don't retry at all if max retry delay is 0
                if maxRetryDelay == 0 {
                    return nil
                }

                let secondsDelay = (rateLimitedError.retryAfter ?? 3) + 1

                var millisecondsDelay = secondsDelay * 1_000

                switch additionalRetries {
                    case 3:
                        break  // do not add any delay

                    // Adding random delays improves the success rate of
                    // concurrent requests. If all requests were serialized
                    // (with respect to all of those made with the same
                    // *client ID*, not just the same access token), then we
                    // would never get a rate limited error more than once per
                    // request in the first place.
                    case 2:
                        // + 1...5 seconds
                        millisecondsDelay += Int.random(in: 1_000...5_000)
                    default /* 1 */:
                        // + 5...10 seconds
                        millisecondsDelay += Int.random(in: 5_000...10_000)
                }

                accumulatedDelayMS += millisecondsDelay

                let maxRetryDelayMS = maxRetryDelay * 1_000

                if accumulatedDelayMS >= maxRetryDelayMS {
                    // don't retry the request if the total accumulated
                    // retry delay is >= maxRetryDelay
                    return nil
                }
                else {
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
                // retry with a 1-2 second delay
                return .milliseconds(
                    Int.random(in: 1_000...2_000)
                )
            }
            
            return nil

        }
        .eraseToAnyPublisher()

    }
    
}
