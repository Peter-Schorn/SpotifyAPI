import Foundation

public extension Data {
    
    /**
     Converts `self` to a Base-64 URL-encoded string.
     
     See also `Data(base64URLEncoded:options)`.
     
     Equivalent to
     ```
     self.base64EncodedString()
         .replacingOccurrences(of: "+", with: "-")
         .replacingOccurrences(of: "/", with: "_")
         .replacingOccurrences(of: "=", with: "")
     ```
     
     - Parameter options: The encoding options.
     */
    func base64URLEncodedString(
        options: Data.Base64EncodingOptions = []
    ) -> String {
        return self.base64EncodedString(options: options)
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /**
     Creates an instance from a Base-64 URL-encoded string.
     
     See also `Data.base64URLEncodedString(options:)`.
     
     - Parameters:
       - string: The Base-64 URL-encoded string.
       - options: The decoding options.
     */
    init?(
        base64URLEncoded string: String,
        options: Data.Base64DecodingOptions = []
    ) {
        var base64String = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let padding = String(repeating: "=", count: base64String.count % 4)
        base64String.append(padding)
        
        self.init(base64Encoded: base64String, options: options)
        
    }

}
