import Foundation

/**
 Used during the Authorization Code Flow with Proof Key for Code Exchange
 to retrieve a new access token and refresh token using the refresh token.

 Unlike the Authorization Code Flow, a refresh token that has been obtained
 using the Authorization Code Flow with Proof Key for Code Exchange can be
 exchanged for an access token only once, after which it becomes invalid. This
 implies that Spotify should always return a new refresh token in addition to an
 access token.

 When creating a type that conforms to ``AuthorizationCodeFlowPKCEBackend`` and
 which communicates *directly* with Spotify, use this type in the body of the
 network request made in the
 ``AuthorizationCodeFlowPKCEBackend/refreshTokens(refreshToken:)`` method.

 When using a custom backend server, use ``ProxyPKCERefreshTokensRequest``
 instead, which does not contain the ``clientId``, as this property should be
 stored on the server.

 - Important: Although this type conforms to `Codable`, it should actually be
       encoded in x-www-form-urlencoded format when sent in the body of a
       network request using ``formURLEncoded()``.

 Read more at the [Spotify web API reference][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 */
public struct PKCERefreshTokensRequest: Hashable {
    
    /// The grant type. Always set to "refresh_token".
    public let grantType = "refresh_token"
    
    /// The refresh token.
    public let refreshToken: String
    
    /**
     The client id that you received when you registered your application.
     
     Read more about [registering your application][1].

     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public let clientId: String
    
    /**
     Creates an instance which refreshes the access token using the
     Authorization Code Flow with Proof Key for Code Exchange.

     When creating a type that conforms to ``AuthorizationCodeFlowPKCEBackend``
     and which communicates *directly* with Spotify, use this type in the body
     of the network request made in the
     ``AuthorizationCodeFlowPKCEBackend/refreshTokens(refreshToken:)`` method.

     When using a custom backend server, use ``ProxyPKCERefreshTokensRequest``
     instead, which does not contain the ``clientId``, as this property should be
     stored on the server.

     - Important: Although this type conforms to `Codable`, it should actually
           be encoded in x-www-form-urlencoded format when sent in the body of a
           network request using ``formURLEncoded()``.

     Read more about the [Authorization Code Flow with Proof Key for Code
     Exchange][1].

     - Parameters:
       - refreshToken: The refresh token.
       - clientId: The client id that you received when you [registered your
             application][2].
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
     [2]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public init(refreshToken: String, clientId: String) {
        self.refreshToken = refreshToken
        self.clientId = clientId
    }
    
    /**
     Encodes this instance to data using the x-www-form-urlencoded format.
     
     This method should be used to encode this type to data (as opposed to using
     a `JSONEncoder`) before being sent in a network request.
     */
    public func formURLEncoded() -> Data {
        
        guard let data = [
            CodingKeys.grantType.rawValue: self.grantType,
            CodingKeys.refreshToken.rawValue: self.refreshToken,
            CodingKeys.clientId.rawValue: self.clientId
        ].formURLEncoded()
        else {
            fatalError(
                "could not form-url-encode `PKCERefreshTokensRequest`"
            )
        }
        return data
    }
    
}

extension PKCERefreshTokensRequest: Codable {

    private enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case refreshToken = "refresh_token"
        case clientId = "client_id"
    }
    
}
