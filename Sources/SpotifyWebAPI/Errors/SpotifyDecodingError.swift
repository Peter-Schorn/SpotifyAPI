import Foundation

/**
 The data from the Spotify web API could not be decoded into any of the
 expected types.

 Assign a folder URL to the static var ``dataDumpFolder`` to write the json
 response from the Spotify web API to disk when instances of this error are
 created. See ``writeToFolder(_:)``. This is intended for debugging purposes.
 It it initialized to the path specified by the "SPOTIFY_DATA_DUMP_FOLDER" environment
 variable, if it exists. You can change this if necessary.

 This error is almost always due to a bug in this library. File a bug report
 if you get this error.
 
 Do not `dump` this error; instead, use its string representation for
 debugging (e.g., print it to the standard output, use string interpolation
 or use `String(describing:)`). Use ``localizedDescription`` for displaying
 the error to the end user.
 */
public struct SpotifyDecodingError: LocalizedError, CustomStringConvertible {
    
    /**
     The folder to write the json response (``rawData``) from the Spotify web
     API to when instances of this error are created. This is intended for
     debugging purposes.

     It it initialized to the path specified by the "SPOTIFY_DATA_DUMP_FOLDER"
     environment variable, if it exists. You can change this if necessary.

     You are encouraged to upload the data to this [online JSON viewer][1].
     
     [1]: https://jsoneditoronline.org
     */
    public static var dataDumpFolder: URL? = {
        
        let environment = ProcessInfo.processInfo.environment
        let folder = environment["data_dump_folder"] ??
                environment["SPOTIFY_DATA_DUMP_FOLDER"]

        if let folder = folder {
            return URL(fileURLWithPath: folder, isDirectory: true)
        }
        return nil
    }()
    
    /// The URL that was used to make the request for the data.
    public let url: URL?
    
    /**
     The raw data returned by the server. You should almost always be able to
     decode this into a string.

     This property, along with ``debugErrorDescription``, is written to a file
     when you call ``writeToFolder(_:)``.
     */
    public let rawData: Data?
    
    /// The type that this library was expecting to be able to decode the data
    /// into.
    public let expectedResponseType: Any.Type
    
    /// The http status code.
    public let statusCode: Int?
    
    /// The underlying error encountered when trying to decode ``rawData`` into
    /// ``expectedResponseType``. Usually [DecodingError][1].
    ///
    /// [1]: https://developer.apple.com/documentation/swift/decodingerror
    public let underlyingError: Error?
    
    /**
     If the underlying error is a DecodingError, then this will be the coding
     path at which a decoding error was encountered formatted as if you were
     accessing nested properties from a Swift type; for example:
     “items[27].track.album.release_date”.
    
     Read more at the [Spotify web API reference][1].

     [1]: https://developer.apple.com/documentation/swift/decodingerror
     */
    public var prettyCodingPath: String? {
        return (underlyingError as? DecodingError)?
                .prettyCodingPath
    }
    
    /**
     Creates a new decoding error.
     
     As soon as this instance is created, ``rawData`` and
     ``debugErrorDescription`` will be written to a folder at the path specified
     by ``dataDumpFolder``, if it is non-`nil`, using ``writeToFolder(_:)``.
     
     - Parameters:
       - url: The URL that was used to make the request for the data.
       - rawData: The raw data from the server.
       - responseType: The type that the caller was expecting to be able to
             decode the data into.
       - statusCode: The HTTP status code.
       - underlyingError: The underlying error encountered when trying to decode
             the data. Usually `DecodingError`.
     */
    public init (
        url: URL?,
        rawData: Data?,
        responseType: Any.Type,
        statusCode: Int?,
        underlyingError: Error?
    ) {
        self.url = url
        self.rawData = rawData
        self.expectedResponseType = responseType
        self.statusCode = statusCode
        self.underlyingError = underlyingError
        
        if let folder = Self.dataDumpFolder {
            do {
                let subFolder = try self.writeToFolder(folder)
                let folderString = subFolder.path
                spotifyDecodeLogger.trace(
                    "SpotifyDecodingError: saved data to '\(folderString)'"
                )
                
            } catch {
                spotifyDecodeLogger.error(
                    """
                    SpotifyDecodingError: couldn't write data \
                    to folder: '\(folder)':\n\(error)"
                    """
                )
            }
        }
        
    }
    
    /**
     Writes ``rawData`` and ``debugErrorDescription`` to a sub-folder within the
     specified folder.

     The name of the sub-folder will be ``expectedResponseType`` with the current
     date appended to it.

     If ``dataDumpFolder`` is non-`nil`, then this method is called by
     ``init(url:rawData:responseType:statusCode:underlyingError:)``, passing in
     ``dataDumpFolder``.
     
     You are encouraged to upload the data to this [online JSON viewer][1].
     
     - Parameter folder: A folder to write the data to.
     - Throws: If an error is encountered when creating the sub-folder or
           writing the data.
     - Returns: The sub-folder that the data was written to.
     
     [1]: https://jsoneditoronline.org
     */
    @discardableResult
    public func writeToFolder(_ folder: URL) throws -> URL {
        
        let dataString = self.rawData.flatMap {
            String(data: $0, encoding: .utf8)
        } ?? "The data was nil or could not be decoded into a string"
        
        let dateString = DateFormatter.millisecondsTime.string(from: Date())
        let title = "\(self.expectedResponseType) \(dateString)"
        
        let subFolder = folder.appendingPathComponent(
            title, isDirectory: true
        )
        
        try FileManager.default.createDirectory(
            at: subFolder,
            withIntermediateDirectories: true
        )
        
        let rawDataFile = subFolder.appendingPathComponent(
            "\(title).json", isDirectory: false
        )
        try dataString.write(
            to: rawDataFile, atomically: true, encoding: .utf8
        )

        let debugErrorDescriptionFile = subFolder.appendingPathComponent(
            "debugErrorDescription.txt", isDirectory: false
        )
        try self.debugErrorDescription.write(
            to: debugErrorDescriptionFile, atomically: true, encoding: .utf8
        )

        return subFolder

    }
    
    /**
     Debug information that is useful in diagnosing the cause of this error.
    
     This property, along with ``rawData``, is written to a file when you call
     ``writeToFolder(_:)``.
     */
    public var debugErrorDescription: String {
       
        var underlyingErrorString = ""
        if let error = self.underlyingError {
            dump(error, to: &underlyingErrorString)
        }
        else {
            underlyingErrorString = "nil"
        }
        
        let statusCodeString = statusCode.map(String.init) ?? "nil"

        var codingPath = self.prettyCodingPath ?? "nil"
        
        if let decodingError = self.underlyingError as? DecodingError {
            switch decodingError {
                case .keyNotFound(let key, _):
                    codingPath += " (keyNotFound: '\(key.stringValue)')"
                default:
                    break
            }
        }
        
        return """
            SpotifyDecodingError: The data from the Spotify web API \
            could not be decoded into '\(self.expectedResponseType)'
            URL: \(self.url?.absoluteString ?? "nil")
            http status code: \(statusCodeString)
            pretty coding path: \(codingPath)
            Underlying error:
            \(underlyingErrorString)
            """
    }
    
    public var description: String {
        
        let dataString = self.rawData.flatMap {
            String(data: $0, encoding: .utf8)
        } ?? "The data was nil or could not be decoded into a string"
        
        return "\(self.debugErrorDescription)raw data:\n\(dataString)"
        
    }
    
    public var errorDescription: String? {
        return """
            The data from Spotify could not be decoded into the expected format.
            """
    }

}
