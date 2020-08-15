import Foundation

/// The data from the web api could not be decoded
/// into any of the expected types.
///
/// This is almost always due to an error in this library.
/// Report a bug if you get this error.
struct SpotifyDecodingError: LocalizedError {
    
    /// The raw data returned by the server.
    /// You should almost always be able to decode
    /// this into a string.
    let rawData: Data?
    
    /// The expected response object.
    let responseObject: Any.Type
    
    /// The http status code.
    let statusCode: Int?
    
    /// Usually a json decoding error.
    let underlyingError: Error?
    
    init (
        rawData: Data?,
        responseObject: Any.Type,
        statusCode: Int?,
        underlyingError: Error?
    ) {
        self.rawData = rawData
        self.responseObject = responseObject
        self.statusCode = statusCode
        self.underlyingError = underlyingError
    }

    var localizedDescription: String {
        let dataString: String
        
        if let data = rawData {
            dataString = String(data: data, encoding: .utf8)
                    ?? "the data could not be decoded into a string"
        }
        else {
            dataString = "no data"
        }
        let statusCodeString = statusCode.map(String.init)
                ?? "no status code"
        
        let underlyingErrorString = underlyingError.map { "\($0)" }
                ?? "nil"
        
        return """
            The data from the web api could not be \
            decoded into "\(responseObject)".
            http status code: \(statusCodeString).
            Underlying error:
            \(underlyingErrorString)
            raw data:
            \(dataString)
            """
    }

}
