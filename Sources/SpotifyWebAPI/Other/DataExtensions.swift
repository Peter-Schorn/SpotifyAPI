import Foundation

public extension Data {
    
    /**
     Converts `self` to a Base-64 URL-encoded string.
     The `=` padding character will be removed.
     
     Equivalent to
     ```
     self.base64EncodedString()
         .replacingOccurrences(of: "+", with: "-")
         .replacingOccurrences(of: "/", with: "_")
         .replacingOccurrences(of: "=", with: "")
     ```
     */
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

}
