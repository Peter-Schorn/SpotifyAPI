import Foundation
import Combine

public extension String {
    
    /// Alias for self.trimmingCharacters(in: characterSet)
    /// The default argument strips all trailing and leading white space,
    /// including new lines.
    func strip(
        _ characterSet: CharacterSet = .whitespacesAndNewlines
    ) -> String {
        
        return self.trimmingCharacters(in: characterSet)
    }
    
    /// Base64-encodes self.
    func base64Encoded(
        _ options: Data.Base64EncodingOptions = []
    ) -> String? {
        
        return self.data(using: .utf8)?
            .base64EncodedString(options: options)
    }
    
    /// Base64-decodes self.
    func base64Decoded(
        encoding: Encoding = .utf8,
        options: Data.Base64DecodingOptions = []
    ) -> String? {
        
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: encoding)
        
    }
        
}


public extension Dictionary {
    
    /**
     Merges the two dictionaries.
    
     Duplicate keys in the left hand side will
     replace those in the right hand side.
     
     - Warning: This operation is non-commutative.
     */
    @inlinable
    static func + (lhs: Self, rhs: Self) -> Self {
        return lhs.merging(rhs) { lhsKey, rhsKey in
            return lhsKey
        }
    }
    
}

public extension Error {
    
    
    /// Returns `AnyPublisher` with the specified output type.
    /// The error type is `self` type-erased to `Error`.
    ///
    /// - Parameter outputType: The output type for the publisher.
    func anyFailingPublisher<Output>(
        _ outputType: Output.Type
    ) -> AnyPublisher<Output, Error> {
        
        return Fail<Output, Error>(error: self)
            .eraseToAnyPublisher()
    
    }
    
}

extension String {
    
    init(from decoder: Decoder) throws {
        fatalError("not implemented")
    }
    
}


public extension DecodingError {
    
    /// The context of the error.
    /// Each of the enum cases have a context.
    var context: Context? {
        switch self {
            case .dataCorrupted(let context):
                return context
            case .keyNotFound(_, let context):
                return context
            case .typeMismatch(_, let context):
                return context
            case .valueNotFound(_, let context):
                return context
            @unknown default:
                return nil
                
            
        }
    }
    
    
    /// Formats the coding path as if you
    /// were
    var prettyCodingPath: String? {
    
        guard let context = self.context else {
            return nil
        }

        var formattedPath = ""
        for codingKey in context.codingPath {
            if let intValue = codingKey.intValue {
                formattedPath += "[\(intValue)]"
            }
            else {
                if !formattedPath.isEmpty {
                    formattedPath += "."
                }
                formattedPath += codingKey.stringValue
            }
        }
        return formattedPath
    }
    
}



// MARK: - Comma separated string -

public extension Sequence where
    Element: RawRepresentable,
    Element.RawValue: StringProtocol
{
    
    /// Creates a comma separated string of the raw values of
    /// the sequence's elements.
    /// No spaces are added between the commas.
    ///
    /// Equivalent to `self.map(\.rawValue).joined(separator: ",")`.
    @inlinable
    func commaSeparatedString() -> String {
        return self.map(\.rawValue).joined(separator: ",")
    }
    
}


// MARK: - Optional Extensions -



/**
 Returns a new dictionary in which the key-value pairs
 for which the values are nil are removed from the dictionary
 and the remaining values are converted to strings.
 
 The LosslessStringConvertible protocol prevents you from using
 types that cannot be converted to strings without losing information.
 
 `String` and `Int` are examples of conforming types.
 
 - Parameter dictionary: A dictionary in which the keys are strings
       and the values are optional types with a wrapped type that
       conforms to `LosslessStringConvertible`; that is, a type
       that can be represented as a string in a lossless,
       unambiguous way.
 */
@inlinable
public func removeIfNil(
    _ dictionary: [String: LosslessStringConvertible?]
) -> [String: String] {
    let unwrapped = dictionary.compactMapValues { $0 }
    return unwrapped.mapValues { "\($0)" }
}


/**
 Type-erases the wrapped value for Optional.
 This protocol allows for extending other protocols
 contingent on one or more of their associated types
 being any optional type.
 
 For example, this extension to Array adds an instance method
 that returns a new array in which each of the elements
 are either unwrapped or removed if nil. You must use self.optional
 for swift to recognize that the generic type is an Optional.
 ```
 extension Array where Element: AnyOptional {

     func removedIfNil() -> [Self.Element.Wrapped] {
         return self.compactMap { $0.optional }
     }

 }
 ```
 Body of protocol:
 ```
 associatedtype Wrapped
 var value: Wrapped? { get set }
 ```
 */
public protocol AnyOptional {

    associatedtype Wrapped
    var optional: Wrapped? { get set }
}

extension Optional: AnyOptional {

    /// A computed property that directly gets and sets `self`.
    /// **Does not unwrap self**. This must be used
    /// for swift to recognize the generic type
    /// conforming to `AnyOptional` as an `Optional`.
    @inlinable @inline(__always)
    public var optional: Wrapped? {
        get { return self }
        set { self = newValue }
    }

}

public extension Sequence where Element: AnyOptional {

    /// Returns a new array in which each element in the Sequence
    /// is either unwrapped and added to the new array,
    /// or not added to the new array if nil.
    ///
    /// Equivalent to `self.compactMap { $0 }`.
    @inlinable
    func removedIfNil() -> [Element.Wrapped] {
        return self.compactMap { $0.optional }
    }
    
}
