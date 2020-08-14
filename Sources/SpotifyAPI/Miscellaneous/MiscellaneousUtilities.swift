import Foundation
import Combine

public extension String {
    
    /// Alias for self.trimmingCharacters(in: characterSet)
    /// The default argument strips all trailing and leading white space,
    /// including new-lines.
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

public extension Date {
    
    /// Returns a date-string formatted for the
    /// current locale.
    ///
    /// Equivalent to `self.description(with: .autoupdatingCurrent)`.
    var localDescription: String {
        return self.description(with: .autoupdatingCurrent)
    }
    
}


public extension Error {
    
    /// Returns a failing publisher with the specified output type.
    ///
    /// The error type is `self` type-erased to `Error`.
    ///
    /// - Parameter outputType: The output type for the publisher.
    func failingPublisher<Output>(
        _ outputType: Output.Type
    ) -> Fail<Output, Error> {
        
        return Fail<Output, Error>(error: self)
        
    }
    
    /// Returns `AnyPublisher` with the specified output type.
    /// The error type is `self` type-erased to `Error`.
    ///
    /// - Parameter outputType: The output type for the publisher.
    @inlinable
    func anyFailingPublisher<Output>(
        _ outputType: Output.Type
    ) -> AnyPublisher<Output, Error> {
        
        return self
            .failingPublisher(outputType.self)
            .eraseToAnyPublisher()
    
    }
    
}


public extension Collection {
    
    /// Retrieves an element from the end of the collection backwards.
    /// self[back: 1] retrieves the last element, self[back: 2] retrieves
    /// the second to last element, and so on.
    ///
    /// - Parameter back: the negative index of an element in the collection.
    subscript(back i: Int) -> Element {
        let indx = self.index(self.endIndex, offsetBy: -i)
        return self[indx]
    }
    
    /// Returns an element of the colletion at the specified index
    /// as an optional. Returns nil if the index is out of bounds.
    /// This can be useful for optional chaining.
    subscript(safe i: Index?) -> Element? {
        guard let i = i else { return nil }
        return self.indices.contains(i) ? self[i] : nil
    }

    /// Combines `subscript(back:)` and `subscript(safe:)`
    /// That is, elements are retrieved from the end of the
    /// collection backwards and are returned as optional values.
    subscript(backSafe i: Int?) -> Element? {
        
        guard let i = i else { return nil }
        
        let indx = self.index(self.endIndex, offsetBy: (-i))
        
        if self.indices.contains(indx) {
            return self[back: i]
        }
        
        return nil
    }
    
}

public extension RangeReplaceableCollection {
    
    /// Retrieves (and sets the value of) an element
    /// from the end of the collection backwards.
    /// self[back: 1] retrieves the last element,
    /// self[back: 2] retrieves
    /// the second to last element, and so on.
    ///
    /// - Parameter back: the negative index
    ///       of an element in the collection.
    subscript(back i: Int) -> Element {
        get {
            let indx = self.index(self.endIndex, offsetBy: (-i))
            return self[indx]
        }
        
        set {
            let indx = self.index(self.endIndex, offsetBy: (-i))
            self.replaceSubrange(indx...indx, with: [newValue])
        }
    }
    
    
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

    /// Gets and sets self. **Does not unwrap the value**.
    /// This computed property must be used
    /// for swift to recognize the generic type
    /// conforming to `AnyOptional` as an Optional.
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
    @inlinable @inline(__always)
    func removedIfNil() -> [Element.Wrapped] {
        return self.compactMap { $0.optional }
    }
    
}
