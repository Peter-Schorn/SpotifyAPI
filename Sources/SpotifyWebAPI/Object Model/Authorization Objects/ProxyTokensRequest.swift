import Foundation

/**
 After the user has authorized your app and a code has been provided, this type
 is used to request a refresh and access token for the Authorization Code
 Flow.
 
 When creating a type that conforms to ``AuthorizationCodeFlowBackend`` and
 which communicates with a custom backend server, use this type in the body of
 the network request made in the
 ``AuthorizationCodeFlowBackend/requestAccessAndRefreshTokens(code:redirectURIWithQuery:)``
 method.
 
 In contrast with ``TokensRequest``, which should be used if you are communicating
 directly with Spotify, this type does not contain the `clientId`, or
 `clientSecret` because these values should be securely stored on your backend
 server.

 - Important: Although this type conforms to `Codable`, it should actually be
       encoded in x-www-form-urlencoded format when sent in the body of a
       network request using ``formURLEncoded()``.

 Read more about the [Authorization Code Flow][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 */
public struct ProxyTokensRequest: Hashable {
	
    /// The grant type. Always set to "authorization_code".
    public let grantType = "authorization_code"

    /// The authorization code. Retrieved from the query string of the redirect
    /// URI.
    public let code: String
    
    /**
     The redirect URI. This is sent in the request for validation only. There
     will be no further redirection to this location.

     Can be `nil` if this value is already stored on your backend server. The
     ``AuthorizationCodeFlowProxyBackend/requestAccessAndRefreshTokens(code:redirectURIWithQuery:)``
     method of ``AuthorizationCodeFlowProxyBackend`` *will* set this value. The
     [Spotify iOS SDK][1] will *not* set this value (see "tokenSwap" URL, which
     Spotify will make a request to with data that can be decoded into this
     type).

     If not `nil`, then this must be the same URI provided when creating the
     authorization URL that was used to request the authorization code (as
     opposed to any of your whitelisted redirect URIs).
     
     [1]: https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
     */
    public let redirectURI: URL?

    /**
     Creates an instance which is used to request the authorization information
     using the Authorization Code Flow.

     When creating a type that conforms to ``AuthorizationCodeFlowBackend`` and
     which communicates with a custom backend server, use this type in the body
     of the network request made in the
     ``AuthorizationCodeFlowBackend/requestAccessAndRefreshTokens(code:redirectURIWithQuery:)``
     method.

     In contrast with ``TokensRequest``, which should be used if you are
     communicating directly with Spotify, this type does not contain the
     `clientId`, or `clientSecret` because these values should be securely
     stored on your backend server.
     
     - Important: Although this type conforms to `Codable`, it should actually
           be encoded in x-www-form-urlencoded format when sent in the body of a
           network request using ``formURLEncoded()``.
     
     Read more about the [Authorization Code Flow][1].

     - Parameters:
       - code: The authorization code. Retrieved from the query string of the
             redirect URI.
       - redirectURI: The redirect URI. This is sent in the request for
             validation only. There will be no further redirection to this
             location. Can be `nil` if this value is already stored on your
             backend server. The
             ``AuthorizationCodeFlowProxyBackend/requestAccessAndRefreshTokens(code:redirectURIWithQuery:)``
             method of ``AuthorizationCodeFlowProxyBackend`` *will* set this
             value. The [Spotify iOS SDK][2] will *not* set this value (see
             "tokenSwap" URL, which Spotify will make a request to with data
             that can be decoded into this type). If not `nil`, then this must
             be the same URI provided when creating the authorization URL that
             was used to request the authorization code (as opposed to any of
             your whitelisted redirect URIs).
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     [2]: https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/
     */
    public init(code: String, redirectURI: URL?) {
        self.code = code
        self.redirectURI = redirectURI
    }
    
    /**
     Encodes this instance to data using the x-www-form-urlencoded format.
     
     This method should be used to encode this type to data (as opposed to using
     a `JSONEncoder`) before being sent in a network request.
     */
    public func formURLEncoded() -> Data {
        
        var dictionary = [
            CodingKeys.grantType.rawValue: self.grantType,
            CodingKeys.code.rawValue: self.code
        ]
        if let redirectURI = self.redirectURI {
            dictionary[CodingKeys.redirectURI.rawValue] =
                    redirectURI.absoluteString
        }

        guard let data = dictionary.formURLEncoded() else {
            fatalError("could not form-url-encode `ProxyTokensRequest`")
        }
        return data
    }

}

extension ProxyTokensRequest: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case code
        case redirectURI = "redirect_uri"
    }

}
