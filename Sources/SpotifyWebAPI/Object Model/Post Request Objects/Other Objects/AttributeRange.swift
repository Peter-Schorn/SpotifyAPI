import Foundation

/**
 Represents a range for a track attribute. Has a minimum, target (ideal), and
 maximum value. See ``TrackAttributes`` and the endpoint for getting
 recommendations based on seeds.

 Note that all of the properties are mutable.

 The target value should not be smaller than the minimum or larger than the
 maximum.
 
 Read more at the [Spotify web API reference][1].

 [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-recommendations
 */
public struct AttributeRange<Value: Numeric & Codable & Hashable &
        LosslessStringConvertible>: Codable, Hashable {
    
    /// The minimum value for the attribute.
    public var min: Value?
    
    /// The target (ideal) value for the attribute.
    ///
    /// Should not be smaller than the minimum or larger than the maximum.
    public var target: Value?
    
    /// The maximum value for the attribute.
    public var max: Value?

    /**
     Creates a new attribute range. All parameters are optional.
     
     - Parameters:
       - min: The minimum value for the attribute.
       - target: The target (ideal) value for the attribute. Should not be
             smaller than the minimum or larger than the maximum.
       - max: The maximum value for the attribute.
     */
    public init(
        min: Value? = nil,
        target: Value? = nil,
        max: Value? = nil
    ) {
        self.min = min
        self.target = target
        self.max = max
    }
    
    
    /**
     Creates a dictionary in which the keys are the provided attribute name
     prefixed with "min", "target" and "max", and the values are the values for
     these properties converted to a string. Properties that are `nil` will not
     appear in the dictionary.
     
     For example, if the `attributeName` is "tempo", then the dictionary will
     be:
     ```
     [
         "min_tempo": self.min,
         "target_tempo": self.target,
         "max_tempo": self.max
     ]
     ```
     
     - Parameter attributeName: The name of the attribute.
     */
    public func queryDictionary(
        attributeName: String
    ) -> [String: String] {

        return urlQueryDictionary([
            "min_\(attributeName)": self.min,
            "target_\(attributeName)": self.target,
            "max_\(attributeName)": self.max
        ])
        
    }
    
}

extension AttributeRange: ApproximatelyEquatable where Value: BinaryFloatingPoint {
    
    /**
     Returns `true` if all the properties of `self` are approximately equal to
     those of `other` within an absolute tolerance of 0.001. Else, returns
     `false`.

     Available when `Value` conforms to `BinaryFloatingPoint`.

     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
    
        for (lhs, rhs) in [
            (self.min, other.min),
            (self.target, other.target),
            (self.max, other.max)
        ] {
            if let lhs = lhs, let rhs = rhs {
                if !lhs.isApproximatelyEqual(
                    to: rhs, absoluteTolerance: 0.001
                ) {
                    return false
                }
            }
            else if (lhs == nil) != (rhs == nil) {
                return false
            }
        }
        
        return true
        
    }
    

}
