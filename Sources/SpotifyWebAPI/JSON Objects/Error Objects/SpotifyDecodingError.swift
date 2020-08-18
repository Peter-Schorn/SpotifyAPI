import Foundation

/// The data from the Spotify web API could not be decoded
/// into any of the expected types.
///
/// This is almost always due to an error in this library.
/// Report a bug if you get this error.
public struct SpotifyDecodingError: LocalizedError, CustomStringConvertible {
    
    /// The folder to write the `dataString`
    /// (in other words, the json response from the Spotify web API)
    /// to when instances of this error are created.
    /// This is intended for debugging purposes.
    /// By default, it is nil.
    public static var dataDumpfolder: URL? = nil
    
    /// The raw data returned by the server.
    /// You should almost always be able to decode
    /// this into a string.
    public let rawData: Data?
    
    /// The `rawData` decoded into a string or nil
    /// if it couldn't be decoded.
    public var dataString: String?
    
    /// The expected response type.
    public let expectedResponseType: Any.Type
    
    /// The http status code.
    public let statusCode: Int?
    
    /// Usually one of the JSON decoding error types.
    public let underlyingError: Error?
    
    public init (
        rawData: Data?,
        responseType: Any.Type,
        statusCode: Int?,
        underlyingError: Error?
    ) {
        self.rawData = rawData
        
        self.dataString = rawData.map {
            String(data: $0, encoding: .utf8)
        } as? String
        
        self.expectedResponseType = responseType
        self.statusCode = statusCode
        self.underlyingError = underlyingError
        
        let dataString = self.dataString
                ?? "The data could not be decoded into a string"
        
        if let folder = Self.dataDumpfolder {
            let dateString = DateFormatter.shortTime.string(from: Date())
            let file = folder.appendingPathComponent(
                "\(expectedResponseType)_\(dateString)"
            )
            try? dataString.write(
                to: file, atomically: true, encoding: .utf8
            )
        }
        
    }
    
    public var description: String {
        
        let dataString = self.dataString
                ?? "The data could not be decoded into a string"
        
        var underlyingErrorString = ""
        if let error = underlyingError {
            dump(error, to: &underlyingErrorString)
        }
        else {
            underlyingErrorString = "nil"
        }

        let statusCodeString = statusCode.map(String.init) ?? "nil"
        
        var codingPath = ""
        if let path = (underlyingError as? DecodingError)?
                .prettyCodingPath {
            codingPath = "\nformatted coding path: \(path)"
        }
        
        return """
            SpotifyDecodingError: The data from the Spotify web API \
            could not be decoded into '\(expectedResponseType)'
            http status code: \(statusCodeString)\(codingPath)
            Underlying error:
            \(underlyingErrorString)
            raw data:
            \(dataString)
            """
    }

}
