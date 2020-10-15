import Foundation
import CryptoKit

public extension String {
    
    /**
     Returns a new string made by removing characters contained in a
     given character set from both ends of the String.
     
     Alias for `String.trimmingCharacters(in:)`.
     
     The default argument strips all trailing and leading white space,
     including new lines.
     
     - Parameter characterSet: The character set to use when trimming
           the string. Default: `whitespacesAndNewlines`.
     */
    @inlinable
    func strip(
        _ characterSet: CharacterSet = .whitespacesAndNewlines
    ) -> String {
        
        return self.trimmingCharacters(in: characterSet)
    }
    
    /**
     Base-64 encodes `self`. See also `String.base64URLEncoded()`.
     
     Equivalent to
     ```
     self.data(using: .utf8)?
     .base64EncodedString(options: options)
     ```
     
     - Parameter options: Options to use when encoding the data.
     */
    func base64Encoded(
        _ options: Data.Base64EncodingOptions = []
    ) -> String? {
        
        return self.data(using: .utf8)?
            .base64EncodedString(options: options)
    }
    
    /// Base64-decodes `self`.
    func base64Decoded(
        encoding: Encoding = .utf8,
        options: Data.Base64DecodingOptions = []
    ) -> String? {
        
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: encoding)
        
    }
    
    /**
     Characters that are safe for use in a URL: Letters, digits,
     the underscore, the period, the hyphen, and the tilde character.
     There are a total of 66 characters.
     
     These are all the valid characters that can be used for creating
     the code verifier when authorizing with the
     [Authorization Code Flow with Proof Key for Code Exchange][1].

     See also `String.randomURLSafe(length:)` and
     `String.randomURLSafe(length:using:)` which generate a random string
     containing only these characters.
     
     ```
     "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.-~"
     ```
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
     */
    static let urlSafeCharacters = """
        abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\
        _.-~
        """
       
    /**
     Returns a random string with the specified length that only contains
     letters, digits, the underscore, the period, the hyphen, and the
     tilde character.
     
     This method can be used for creating the code verifier when authorizing
     with the [Authorization Code Flow with Proof Key for Code Exchange][1].
     
     See also `String.urlSafeCharacters` and `String.randomURLSafe(length:)`.
     
     - Parameters:
       - length: The legnth of the string.
       - randumNumberGenerator: The random number generator to use.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
     */
    static func randomURLSafe<Generator: RandomNumberGenerator>(
        length: Int,
        using randumNumberGenerator: inout Generator
    ) -> String {
        
        return (0..<length).reduce(into: "") { result, _ in
            result += String(
                String.urlSafeCharacters.randomElement(
                    using: &randumNumberGenerator
                )!
            )
        }
    }
    
    /**
     Returns a random string with the specified length that only contains
     letters, digits, the underscore, the period, the hyphen, and the
     tilde character.
     
     This method can be used for creating the code verifier when authorizing
     with the [Authorization Code Flow with Proof Key for Code Exchange][1].
     
     See also  `String.urlSafeCharacters` and
     `String.randomURLSafe(length:using:)`, which allows you to specify
     the random number generator to use.

     - Parameter length: The length of the string.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
     */
    static func randomURLSafe(length: Int) -> String {
        var generator = SystemRandomNumberGenerator()
        return randomURLSafe(length: length, using: &generator)
    }
    

    /**
     Hashes `self` using the SHA256 algorithm and returns the
     Base-64 URL-encoded hash.
     
     This method can be used to generate the code challenge if `self`
     is the code verifier for the
     [Authorization Code Flow with Proof Key for Code Exchange][1].
     
     Equivalent to
     ```
     let data = self.data(using: .utf8)!
     
     // The hash is an array of bytes (UInt8).
     let hash = SHA256.hash(data: data)
     
     // Convert the array of bytes into data.
     let bytes = Data(hash)

     // Base-64 URL-encode the bytes.
     return bytes.base64URLEncodedString()
     ```
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
     */
    func makeCodeChallenge() -> String {
        
        let data = self.data(using: .utf8)!
        
        // The hash is an array of bytes (UInt8).
        let hash = SHA256.hash(data: data)
        
        // Convert the array of bytes into data.
        let bytes = Data(hash)

        // Base-64 URL-encode the bytes.
        return bytes.base64URLEncodedString()
        
    }
    
}
