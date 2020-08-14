import Foundation

/**
 A type that provides its own method
 for decoding itself from data.
 
 Instead of creating a JSONDecoder, call the `decoded(from:)`
 type method, which accepts the raw data.
 */
public protocol CustomDecodable: Decodable {
    
    /// Use this method to decode an instance of this type
    /// from data rather than creating your own `JSONDecoder`.
    static func decoded(from data: Data) throws -> Self
    
}

public extension CustomDecodable {
    
    static func decoded(from data: Data) throws -> Self {
        return try JSONDecoder().decode(Self.self, from: data)
    }
    
}


/**
 A type that provides its own method
 for encoding an instance of itself into data.
 
 Instead of creating a JSONEncoder, call the `encoded()`
 instance method to encode an instance of this type to data.
 */
public protocol CustomEncodable: Encodable {
    
    /// Use this method to encode an instance of this type
    /// into data rather than creating your own `JSONEncoder`.
    func encoded() throws -> Data
}

public extension CustomEncodable {
    
    func encoded() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

public typealias CustomCodable = CustomDecodable & CustomEncodable


// MARK: - Standard Library Conformances -

extension String: CustomCodable { }
extension Int: CustomCodable { }
extension Double: CustomCodable { }

extension Optional: CustomDecodable where Wrapped: CustomDecodable { }
extension Optional: CustomEncodable where Wrapped: CustomEncodable { }

// collections

extension Array: CustomDecodable where Element: CustomDecodable { }
extension Array: CustomEncodable where Element: CustomEncodable { }

extension Dictionary: CustomDecodable where
        Key: CustomDecodable, Value: CustomDecodable { }

extension Dictionary: CustomEncodable where
        Key: CustomEncodable, Value: CustomEncodable { }
