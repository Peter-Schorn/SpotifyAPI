import Foundation

/**
 Represents a range for a track attribute. Has a minimum, target (ideal), and
 maximum value. See `TrackAttributes` and the endpoint for
 [getting recommendations based on seeds][1].
 
 Note that all of the properties are mutable.
 
 The target value should not be smaller than the minimum or larger than the
 maximum.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/#query-parameters
 */
public struct AttributeRange<Number: Numeric & Codable & Hashable &
        LosslessStringConvertible>: Codable, Hashable {
    
    /// The minimum value for the attribute.
    public var min: Number?
    
    /// The target (ideal) value for the attribute.
    ///
    /// Should not be smaller than the minimum or larger than the
    /// maximum.
    public var target: Number?
    
    /// The maximum value for the attribute.
    public var max: Number?

    /**
     Creates a new attribute range. All parameters are optional.
     
     - Parameters:
       - min: The minimum value for the attribute.
       - target: The target (ideal) value for the attribute.
             Should not be smaller than the minimum or larger than the
             maximum.
       - max: The maximum value for the attribute.
     */
    public init(
        min: Number? = nil,
        target: Number? = nil,
        max: Number? = nil
    ) {
        self.min = min
        self.target = target
        self.max = max
    }
    
    
    /**
     Creates a dictionary in which the keys are the provided attribute name
     prefixed with `min`, `target` and `max`, and the values are the values
     for these properties converted to a string. Properties that are `nil`
     will not appear in the dictionary.
     
     For example, if the attribute name was "tempo", then the dictionary would be:
     ```
     [
     "min_tempo": min,
     "target_tempo": target,
     "max_tempo": max
     ]
     ```
     
     - Parameter attributeName: The name of the attribute.
     */
    public func queryDictionary(
        attributeName: String
    ) -> [String: String] {

        return removeIfNil([
            "min_\(attributeName)": min,
            "target_\(attributeName)": target,
            "max_\(attributeName)": max
        ])
        
    }
    
}
