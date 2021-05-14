import Foundation

/**
 A type that can compare two of its values for approximate equality.
 
 This is particularly useful for types that have been decoded from data:
 Decoding floating point types can lead to floating point imprecision.
 */
public protocol ApproximatelyEquatable {
    
    /**
     Determines whether two values are approximately equal to each other.
     
     - Parameter other: Another instance of `Self`.
     */
    func isApproximatelyEqual(to other: Self) -> Bool

}

extension Date: ApproximatelyEquatable {
    
    /// Compares the dates for approximate equality using
    /// `timeIntervalSince1970` with an absolute tolerance of 1.
    public func isApproximatelyEqual(to other: Date) -> Bool {
        return self.timeIntervalSince1970.isApproximatelyEqual(
            to: other.timeIntervalSince1970,
            absoluteTolerance: 1
        )
        
    }

}

extension Optional: ApproximatelyEquatable where Wrapped: ApproximatelyEquatable {
    
    public func isApproximatelyEqual(to other: Optional<Wrapped>) -> Bool {
        switch (self, other) {
            case (.some(let lhs), .some(let rhs)):
                return lhs.isApproximatelyEqual(to: rhs)
            case (nil, nil):
                return true
            default:
                return false
        }
    }

}

extension Sequence where Element: ApproximatelyEquatable {
    
    /**
     Compares each element in the sequences, in order, for approximate equality.
     
     Returns `false` if the sequences produce a different number of elements.

     - Parameter other: Another sequence.
     */
    @inlinable @inline(__always)
    public func isApproximatelyEqual<S: Sequence>(
        to other: S
    ) -> Bool where S.Element == Self.Element {
        
        return self.elementsEqual(other) { lhs, rhs in
            lhs.isApproximatelyEqual(to: rhs)
        }

    }
    
//    @usableFromInline
//    func _isApproximatelyEqual<S: Sequence>(
//        toSequence other: S
//    ) -> Bool where S.Element == Self.Element {
//
//        var lhsIterator = self.makeIterator()
//        var rhsIterator = other.makeIterator()
//
//        /*
//         Ensure that this method returns `false` if the sequences
//         produce a different number of elements.
//
//         Simply using `zip` is not sufficient because it will
//         stop iterating after the shortest sequence has exhausted
//         its elements.
//         */
//
//        return self.elementsEqual(other, by: { lhs, rhs in
//            lhs.isApproximatelyEqual(to: rhs)
//        })
//
//        while true {
//            let lhsNext = lhsIterator.next()
//            let rhsNext = rhsIterator.next()
//            if let lhs = lhsNext, let rhs = rhsNext {
//                if !lhs.isApproximatelyEqual(to: rhs) {
//                    return false
//                }
//            }
//            else {
//                // If only one of the two is `nil`, then
//                // the sequences have a different number of
//                // elements, so we return `false`.
//                return lhsNext == nil && rhsNext == nil
//            }
//        }
//
//    }

}

extension RandomAccessCollection where Element: ApproximatelyEquatable {

    /**
     Compares each element in the collections, in order, for approximate
     equality.

     Returns `false` if the collections have a different number of elements.

     - Parameter other: Another collection.
     */
    @inlinable @inline(__always)
    public func isApproximatelyEqual<C: RandomAccessCollection>(
        to other: C
    ) -> Bool where C.Element == Self.Element {

        // fast path:
        // `count` is only guaranteed to have O(1) complexity if the collection
        // is random access.
        if self.count != other.count {
            return false
        }

        return self.elementsEqual(other) { lhs, rhs in
            lhs.isApproximatelyEqual(to: rhs)
        }

    }

}

extension Array: ApproximatelyEquatable where Element: ApproximatelyEquatable { }

extension Set: ApproximatelyEquatable where Element: ApproximatelyEquatable {
    
    @inlinable @inline(__always)
    public func isApproximatelyEqual(to other: Self) -> Bool {
        // the documented complexity of `count` is O(1).
        if self.count != other.count {
            return false
        }
        return self.elementsEqual(other) { lhs, rhs in
            lhs.isApproximatelyEqual(to: rhs)
        }
    }

}
