import Foundation

/**
 After the user has authorized your app and a code has been provided, this type
 is used to request a refresh and access token for the [Authorization Code Flow
 with Proof Key for Code Exchange][1].

 When creating a type that conforms to `AuthorizationCodeFlowPKCEBackend` and
 which communicates with a custom backend server, use this type in the body of
 the network request made in the
 `requestAccessAndRefreshTokens(code:codeVerifier:redirectURIWithQuery:)`
 method.

 In contrast with `PKCETokensRequest`, which should be used if you are
 communicating directly with Spotify, this type does not contain the `clientId`
 because this value should be securely stored on your backend server.

 - Important: Although this type conforms to `Codable`, it should actually be
       encoded in x-www-form-urlencoded format when sent in the body of a
       network request using `self.formURLEncoded`.

 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
 */
public struct ProxyPKCETokensRequest: Hashable {
    
    /// The grant type. Always set to "authorization_code".
    public let grantType = "authorization_code"

    /// The authorization code. Retrieved from the query string of the redirect
    /// URI.
    public let code: String
    
    /// The code verifier that you generated when creating the authorization
    /// URL.
    public let codeVerifier: String
    
    /// The redirect URI. This is sent in the request for validation only. There
    /// will be no further redirection to this location.
    public let redirectURI: URL
    
    /**
     Creates an instance that is used to retrieve the authoriztion information
     using the [Authorization Code Flow with Proof Key for Code Exchange][1].

     When creating a type that conforms to `AuthorizationCodeFlowPKCEBackend`
     and which communicates with a custom backend server, use this type in the
     body of the network request made in the
     `requestAccessAndRefreshTokens(code:codeVerifier:redirectURIWithQuery:)`
     method.

     In contrast with `PKCETokensRequest`, which should be used if you are
     communicating directly with Spotify, this type does not contain the
     `clientId` because this value should be securely stored on your backend
     server.
     
     - Important: Although this type conforms to `Codable`, it should actually
           be encoded in x-www-form-urlencoded format when sent in the body of a
           network request using `self.formURLEncoded`.
     
     - Parameters:
       - code: The authorization code. Retrieved from the query string of the
             redirect URI.
       - codeVerifier: The code verifier that you generated when creating the
             authorization URL.
       - redirectURI: The redirect URI. This is sent in the request for
             validation only. There will be no further redirection to this
             location.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
     */
    public init(
        code: String,
        codeVerifier: String,
        redirectURI: URL
    ) {
        self.code = code
        self.codeVerifier = codeVerifier
        self.redirectURI = redirectURI
    }
    
    /**
     Encodes this instance to data using the x-www-form-urlencoded format.
     
     This method should be used to encode this type to data (as opposed to using
     a `JSONEncoder`) before being sent in a network request.
     */
    public func formURLEncoded() -> Data {
        guard let data = [
            CodingKeys.grantType.rawValue: self.grantType,
            CodingKeys.code.rawValue: self.code,
            CodingKeys.codeVerifier.rawValue: self.codeVerifier,
            CodingKeys.redirectURI.rawValue: self.redirectURI.absoluteString
        ].formURLEncoded() else {
            fatalError(
                "could not form-url-encode `ProxyPKCETokensRequest`"
            )
        }
        return data
    }

}

extension ProxyPKCETokensRequest: Codable {
    
    /// :nodoc:
    public enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case code
        case codeVerifier = "code_verifier"
        case redirectURI = "redirect_uri"
    }

}
