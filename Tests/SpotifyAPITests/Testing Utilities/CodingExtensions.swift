import Foundation
import SpotifyWebAPI
import SpotifyContent
import XCTest

/// Encodes the object into data, then decodes it again (2x) and ensures that
/// the decoded version exactly matches the value that was originally passed in.
/// This ensures that no information was lost during encoding and decoding.
@discardableResult
func encodeDecode<T: Codable & Equatable>(
    _ object: T,
    file: StaticString = #file,
    line: UInt = #line
) -> String? {
    
    do {
        
        let encodedData = try JSONEncoder().encode(object)
        let decodedObject = try JSONDecoder().decode(
            T.self, from: encodedData
        )
        let reEncodedData = try JSONEncoder().encode(decodedObject)
        let reDecodedData = try JSONDecoder().decode(
            T.self, from: reEncodedData
        )
        
        XCTAssertEqual(
            object, reDecodedData,
            "\(T.self) changed after encoding and decoding",
            file: file, line: line
        )
        
        return String(data: reEncodedData, encoding: .utf8)
    
    } catch {
        
        let rawData = try? JSONEncoder().encode(object)
        
        let decodingError = SpotifyDecodingError(
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

/// Decodes the data into the specified type, encodes the data, then
/// re-decodes it again. Ensures that the decoded version matches the
/// re-decoded version, which ensures that no information was lost
/// during encoding and decoding.
@discardableResult
func decodeEncodeDecode<T: Codable & Equatable>(
    _ data: Data,
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
) -> String? {
    
    do {
        
        let decodedObject = try JSONDecoder().decode(
            T.self, from: data
        )
        let encodedObject = try JSONEncoder().encode(decodedObject)
        
        let reDecodedObject = try JSONDecoder().decode(
            T.self, from: encodedObject
        )
        
        XCTAssertEqual(
            decodedObject, reDecodedObject,
            "\(T.self) changed after decoding, encoding, and re-decoding",
            file: file, line: line
        )
        
        return String(data: encodedObject, encoding: .utf8)
        
    } catch {
        
        let decodingError = SpotifyDecodingError(
            rawData: data,
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
