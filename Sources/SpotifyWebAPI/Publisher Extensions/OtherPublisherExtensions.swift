import Foundation
import Combine
import Logger



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
                return error.anyFailingPublisher(
                    NewPublisher.Output.self
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
