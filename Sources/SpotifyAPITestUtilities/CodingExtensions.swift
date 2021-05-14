import Foundation
import SpotifyWebAPI
import XCTest

/**
 Encodes the object into data, then decodes it again (2x) and ensures that the
 decoded version matches the value that was originally passed in. This ensures
 that no information was lost or changed during encoding and decoding.
 
 - Parameters:
   - object: The object to encode and decode.
   - file: A file name. Defaults to the file name of the test case in which this
         function was called.
   - line: A line number. Defaults to the line number on which this function was
         called.
 - Returns: The data converted into a string.
 */
@discardableResult
public func encodeDecode<T: Codable & ApproximatelyEquatable>(
    _ object: T,
    file: StaticString = #file,
    line: UInt = #line
) -> String? {

    return encodeDecode(
        object,
        areEqual: { $0.isApproximatelyEqual(to: $1) },
        file: file,
        line: line
    )

}


/**
 Encodes the object into data, then decodes it again (2x) and ensures that the
 decoded version matches the value that was originally passed in. This ensures
 that no information was lost or changed during encoding and decoding.
 
 - Parameters:
   - object: The object to encode and decode.
   - areEqual:  Used to compare the object for equality.
   - file: A file name. Defaults to the file name of the test case in which this
         function was called.
   - line: A line number. Defaults to the line number on which this function was
         called.
 - Returns: The data converted into a string.
 */
@discardableResult
public func encodeDecode<T: Codable>(
    _ object: T,
    areEqual: @escaping (_ lhs: T, _ rhs: T) throws -> Bool,
    file: StaticString = #file,
    line: UInt = #line
) rethrows -> String? {
    
    do {
        
        let encodedData = try JSONEncoder().encode(object)
        
        let decodedObject = try JSONDecoder().decode(
            T.self, from: encodedData
        )
        
        let errorMessage = "\(T.self) changed after encoding and decoding"

        XCTAssert(
            try areEqual(object, decodedObject),
            errorMessage,
            file: file,
            line: line
        )

        return try decodeEncodeDecode(
            encodedData,
            type: T.self,
            areEqual: areEqual,
            file: file,
            line: line
        )

    } catch {
        
        let rawData = try? JSONEncoder().encode(object)
        
        let decodingError = SpotifyDecodingError(
            url: nil,
            rawData: rawData,
            responseType: T.self,
            statusCode: nil,
            underlyingError: error
        )
        
        XCTFail(
            "\(decodingError)",
            file: file, line: line
        )
        
        return nil
    }
    
    
}


/**
 Decodes the data into the specified type, encodes the data, then re-decodes it
 again. Ensures that the decoded version matches the re-decoded version, which
 ensures that no information was lost or changed during encoding and decoding.
 
 - Parameters:
   - data: The data to decode and encode.
   - type: The type to decode the data from.
   - areEqual: Used to compare the object for equality.
   - file: A file name. Defaults to the file name of the test case in which this
         function was called.
   - line: A line number. Defaults to the line number on which this function was
         called.
 - Returns: The data converted into a string.
 */
@discardableResult
public func decodeEncodeDecode<T: Codable & ApproximatelyEquatable>(
    _ data: Data,
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
) -> String? {
    
    return decodeEncodeDecode(
        data,
        type: type,
        areEqual: { $0.isApproximatelyEqual(to: $1) },
        file: file,
        line: line
    )

}

/**
 Decodes the data into the specified type, encodes the data, then re-decodes it
 again. Ensures that the decoded version matches the re-decoded version, which
 ensures that no information was lost or changed during encoding and decoding.
 
 - Parameters:
   - data: The data to decode and encode.
   - type: The type to decode the data from.
   - areEqual:  Used to compare the object for equality.
   - file: A file name. Defaults to the file name of the test case in which this
         function was called.
   - line: A line number. Defaults to the line number on which this function
         was called.
 - Returns: The data converted into a string.
 */
@discardableResult
public func decodeEncodeDecode<T: Codable>(
    _ data: Data,
    type: T.Type,
    areEqual: (_ lhs: T, _ rhs: T) throws -> Bool,
    file: StaticString = #file,
    line: UInt = #line
) rethrows -> String? {
    
    do {
        
        let decodedObject = try JSONDecoder().decode(
            T.self, from: data
        )
        let encodedObject = try JSONEncoder().encode(decodedObject)
        
        let reDecodedObject = try JSONDecoder().decode(
            T.self, from: encodedObject
        )
        
        let errorMessage = "\(T.self) changed after decoding, " +
            "encoding, and re-decoding"
        
        XCTAssert(
            try areEqual(decodedObject, reDecodedObject),
            errorMessage,
            file: file,
            line: line
        )
        
        let string = String(data: encodedObject, encoding: .utf8)
        
        XCTAssertNotNil(string, file: file, line: line)

        return string
        
    } catch {
        
        let decodingError = SpotifyDecodingError(
            url: nil,
            rawData: data,
            responseType: T.self,
            statusCode: nil,
            underlyingError: error
        )
        
        XCTFail(
            "\(decodingError)",
            file: file,
            line: line
        )
        
        return nil
        
    }
    
}
