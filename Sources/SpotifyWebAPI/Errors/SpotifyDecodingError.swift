import Foundation

/**
 The data from the Spotify web API could not be decoded
 into any of the expected types.

 Assign a folder URL to the static var `dataDumpfolder`
 to write the json response from the Spotify web API to disk
 to when instances of this error are created.
 This is intended for debugging purposes. By default, it is nil.

 This is almost always due to an error in this library.
 Report a bug if you get this error.
 
 Do not `dump` this error; instead, use its string representation
 for debugging (e.g., print it to the console). Only use
 `localizedDescription` for displaying the error to the end user.
 */
public struct SpotifyDecodingError: LocalizedError, CustomStringConvertible {
    
    /**
     The folder to write the json response from
     the Spotify web API to when instances of this error
     are created. This is intended for debugging purposes.
     By default, it is nil.
     
     The name of the file will be `expectedResponseType` with the current
     time appended to it.
     You are encouraged to upload the file to this [online JSON viewer][1].
     
     [1]: https://jsoneditoronline.org/#left=local.yefire&right=local.redama
     */
    public static var dataDumpfolder: URL? = nil
    
    /// The raw data returned by the server.
    /// You should almost always be able to decode
    /// this into a string.
    public let rawData: Data?
    
    /// The expected response type.
    public let expectedResponseType: Any.Type
    
    /// The http status code.
    public let statusCode: Int?
    
    /// Usually [DecodingError][1].
    ///
    /// [1]: https://developer.apple.com/documentation/swift/decodingerror
    public let underlyingError: Error?
    
    /**
     If the underlying error is a [DecodingError][1],
     then this will be the coding path formatted as if you
     were accessing nested properties from a Swift type;
     for example, “items[27].track.album.release_date”.
    
     [1]: https://developer.apple.com/documentation/swift/decodingerror
     */
    public var prettyCodingPath: String? {
        return (underlyingError as? DecodingError)?
                .prettyCodingPath
    }
    
    public init (
        rawData: Data?,
        responseType: Any.Type,
        statusCode: Int?,
        underlyingError: Error?
    ) {
        self.rawData = rawData
        
        self.expectedResponseType = responseType
        self.statusCode = statusCode
        self.underlyingError = underlyingError

        let dataString = rawData.map {
            String(data: $0, encoding: .utf8)
        } as? String
                ?? "The data could not be decoded into a string"
        
        if let folder = Self.dataDumpfolder {
            
            let dateString = DateFormatter.shortTime.string(from: Date())
            let file = folder.appendingPathComponent(
                "\(expectedResponseType)_\(dateString)"
            )
            
            do {
                try dataString.write(
                    to: file, atomically: true, encoding: .utf8
                )
            
            } catch {
                print(
                    "SpotifyDecodingError: couldn't write data " +
                    "to file: '\(file)'\n\(error)"
                )
            }
            
        }
        
    }
    
    public var description: String {
        
        let dataString = rawData.map {
            String(data: $0, encoding: .utf8)
        } as? String ?? "The data could not be decoded into a string"
        
        var underlyingErrorString = "nil"
        if let error = underlyingError {
            dump(error, to: &underlyingErrorString)
        }
        
        let statusCodeString = statusCode.map(String.init) ?? "nil"
        
        var codingPath = ""
        if let path = self.prettyCodingPath {
            codingPath = "\npretty coding path: \(path)"
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
    
    public var errorDescription: String? {
        return "The data from Spotify could not be understood"
    }

}
