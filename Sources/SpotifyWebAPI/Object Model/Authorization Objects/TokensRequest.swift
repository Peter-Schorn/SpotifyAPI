import Foundation

/**
 After the user has authorized your app and a code has been provided, this type
 is used to request a refresh and access token for the Authorization Code
 Flow.
 
 When creating a type that conforms to ``AuthorizationCodeFlowBackend`` and
 which communicates *directly* with Spotify, use this type in the body of the
 network request made in the
 ``AuthorizationCodeFlowBackend/requestAccessAndRefreshTokens(code:redirectURIWithQuery:)``
 method.
 
 When using a custom backend server, use ``ProxyTokensRequest`` instead, which
 does not contain the ``clientId``, or ``clientSecret``, as these properties
 should be stored on the server.

 - Important: Although this type conforms to `Codable`, it should actually be
       encoded in x-www-form-urlencoded format when sent in the body of a
       network request using ``formURLEncoded()``.
 
 Read more about the [Authorization Code Flow][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 */
public struct TokensRequest: Hashable {
    
    /// The grant type. Always set to "authorization_code".
    public let grantType = "authorization_code"
    
    /// The authorization code. Retrieved from the query string of the redirect
    /// URI.
    public let code: String
    
    /**
     The redirect URI. This is sent in the request for validation only. There
     will be no further redirection to this location.
     
     This must be the same URI provided when creating the authorization URL that
     was used to request the authorization code (as opposed to any of your
     whitelisted redirect URIs).
     */
    public let redirectURI: URL
    
    /**
     The client id that you received when you registered your application.
     
     Read more about [registering your application][1].

     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public let clientId: String
    
    /**
     The client secret that you received when you registered your
     application.
     
     Read more about [registering your application][1].
     
     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public let clientSecret: String

    /**
     Creates an instance that is used to retrieve the authorization information
     using the Authorization Code Flow.

     When creating a type that conforms to ``AuthorizationCodeFlowBackend`` and
     which communicates *directly* with Spotify, use this type in the body of
     the network request made in the
     ``AuthorizationCodeFlowBackend/requestAccessAndRefreshTokens(code:redirectURIWithQuery:)``
     method.

     When using a custom backend server, use ``ProxyTokensRequest`` instead,
     which does not contain the ``clientId``, or ``clientSecret``, as these
     properties should be stored on the server.
     
     - Important: Although this type conforms to `Codable`, it should actually
           be encoded in x-www-form-urlencoded format when sent in the body of a
           network request using ``formURLEncoded()``.
     
     Read more about the [Authorization Code Flow][1].

     - Parameters:
       - code: The authorization code. Retrieved from the query string of the
             redirect URI.
       - redirectURI: The redirect URI. This is sent in the request for
             validation only. There will be no further redirection to this
             location. This must be the same URI provided when creating the
             authorization URL that was used to request the authorization code
             (as opposed to any of your whitelisted redirect URIs).
       - clientId: The client id that you received when you [registered your
             application][2].
       - clientSecret: The client secret that you received when you [registered
             your application][2].
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     [2]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public init(
        code: String,
        redirectURI: URL,
        clientId: String,
        clientSecret: String
    ) {
        self.code = code
        self.redirectURI = redirectURI
        self.clientId = clientId
        self.clientSecret = clientSecret
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
            CodingKeys.redirectURI.rawValue: self.redirectURI.absoluteString,
            CodingKeys.clientId.rawValue: self.clientId,
            CodingKeys.clientSecret.rawValue: self.clientSecret
        ].formURLEncoded()
        else {
            fatalError("could not form-url-encode `TokensRequest`")
        }
        return data
        
    }
    
    
}

extension TokensRequest: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case code
        case redirectURI = "redirect_uri"
        case clientId = "client_id"
        case clientSecret = "client_secret"
    }

}
