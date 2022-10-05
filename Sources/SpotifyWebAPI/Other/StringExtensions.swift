import Foundation
import Crypto

public extension String {
    
    /**
     Returns a new string made by removing characters contained in a given
     character set from both ends of the String.

     Alias for `String.trimmingCharacters(in:)`.
     
     - Parameter characterSet: The character set to use when trimming the
           string. Default: `whitespacesAndNewlines`.
     */
    @inlinable
    func strip(
        _ characterSet: CharacterSet = .whitespacesAndNewlines
    ) -> String {
        
        return self.trimmingCharacters(in: characterSet)
    }
    
    /**
     Base-64 encodes `self`.
     
     Equivalent to
     ```
     self.data(using: .utf8)?.base64EncodedString(options: options)
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
     Characters that are safe for use in a URL: Letters, digits, the
     underscore character, and the hyphen character.
     
     There are a total of 64 characters.
     
     All of these characters are valid for creating the code verifier for the
     [Authorization Code Flow with Proof Key for Code Exchange][1].

     See also `String.randomURLSafe(length:)` and
     `String.randomURLSafe(length:using:)` which generate a random string
     containing only these characters.
     
     ```
     "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
     ```
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     */
    static let urlSafeCharacters = """
        abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-
        """
       
    /**
     Returns a random string with the specified length that only contains
     letters, digits, the underscore character, and the hyphen character.

     This method can be used for creating the code verifier for the
     [Authorization Code Flow with Proof Key for Code Exchange][1], and for
     creating the state parameter.
     
     See also:
     
     * `String.urlSafeCharacters`
     * `String.randomURLSafe(length:)`
     * `String.makeCodeChallenge(codeVerifier:)` - makes the code challenge from
       the code verifier
     
     - Parameters:
       - length: The length of the string. The code verifier must between 43 and
             128 characters in length, inclusive.
       - randomNumberGenerator: The random number generator to use.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     */
    static func randomURLSafe<Generator: RandomNumberGenerator>(
        length: Int,
        using randomNumberGenerator: inout Generator
    ) -> String {
        
        let characters = (0..<length).map { _ -> Character in
            var copy = randomNumberGenerator  // fixes EXC_BAD_ACCESS bug
            return String.urlSafeCharacters.randomElement(
                using: &copy
            )!
        }
        return String(characters)
    }
    
    /**
     Returns a random string with the specified length that only contains
     letters, digits, the underscore character, and the hyphen character.

     This method can be used for creating the code verifier for the
     [Authorization Code Flow with Proof Key for Code Exchange][1], and for
     creating the state parameter.
     
     See also:
     
     * `String.urlSafeCharacters`
     * `String.randomURLSafe(length:using:)` - allows you to specify the random
       number generator to use.
     * `String.makeCodeChallenge(codeVerifier:)` - makes the code challenge from
       the code verifier
     
     - Parameter length: The length of the string. The code verifier must be
           between 43 and 128 characters in length, inclusive.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     */
    static func randomURLSafe(length: Int) -> String {
        var generator = SystemRandomNumberGenerator()
        return randomURLSafe(length: length, using: &generator)
    }
    

    /**
     Hashes the `codeVerifier` using the SHA256 algorithm and returns the
     Base-64 URL-encoded hash.
     
     This method can be used to generate the code challenge for the
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
     
     - Parameter codeVerifier: The code verifier.
     - Returns: The code challenge.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     */
    static func makeCodeChallenge(codeVerifier: String) -> String {
        
        let data = codeVerifier.data(using: .utf8)!
        
        // The hash is an array of bytes (UInt8).
        let hash = SHA256.hash(data: data)
        
        // Convert the array of bytes into data.
        let bytes = Data(hash)

        // Base-64 URL-encode the bytes.
        return bytes.base64URLEncodedString()
        
    }
    
}
