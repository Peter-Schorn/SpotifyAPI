import Foundation


/// The data from the Spotify web API could not be decoded
/// into any of the expected types.
///
/// This is almost always due to an error in this library.
/// Report a bug if you get this error.
public struct SpotifyDecodingError2: LocalizedError, CustomStringConvertible {
    
    /// The file to write the json data to when this
    /// error is created. By default, it is nil.
    ///
    /// The data will be converted to a string, then written
    /// to the file, unless it can't be converted to a string.
    public static var dataDumpfileURL: URL? {
        let dateString = DateFormatter.shortTime.string(from: Date())
        return URL(fileURLWithPath:
            "/Users/pschorn/Desktop/response_\(dateString).json"
        )
    }
    
    /// The raw data returned by the server.
    /// You should almost always be able to decode
    /// this into a string.
    public let rawData: Data?
    
    /// The `rawData` decoded into a string or nil
    /// if it couldn't be decoded.
    public var dataString: String?
    
    /// The expected response object.
    public let expectedResponseObject: Any.Type
    
    /// The http status code.
    public let statusCode: Int?
    
    /// Usually one of the JSON decoding error types.
    public let underlyingError: Error?
    
    public init (
        rawData: Data?,
        responseObject: Any.Type,
        statusCode: Int?,
        underlyingError: Error?
    ) {
        self.rawData = rawData
        
        self.dataString = rawData.map {
            String(data: $0, encoding: .utf8)
        } as? String
        
        self.expectedResponseObject = responseObject
        self.statusCode = statusCode
        self.underlyingError = underlyingError
        
        if let fileURL = Self.dataDumpfileURL,
                let data = rawData,
                let dataString = String(data: data, encoding: .utf8) {
            
            try? dataString.write(
                to: fileURL, atomically: true, encoding: .utf8
            )
        }
    }
    
    public var description: String {
        
        let dataString = self.dataString
                ?? "The data could not be decoded into a string"
        
        let underlyingErrorString = underlyingError.map { "\($0)" }
                ?? "nil"

        let statusCodeString = statusCode.map(String.init) ?? "nil"
        
        return """
            SpotifyDecodingError: The data from the Spotify web API \
            could not be decoded into '\(expectedResponseObject)'.
            http status code: \(statusCodeString)
            Underlying error:
            \(underlyingErrorString)
            raw data:
            \(dataString)
            """
    }
    
    public var errorDescription: String? { description }
    

}
