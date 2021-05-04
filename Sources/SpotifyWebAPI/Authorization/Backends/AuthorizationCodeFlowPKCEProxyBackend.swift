import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Logging

#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

/**
 Communicates with a backend server that you setup in order to retrieve the
 authoriation information and refresh the access token using the [Authorization
 Code Flow with Proof Key for Code Exchange][1].
 
 Compare with `AuthorizationCodeFlowPKCEClientBackend`.
 
 This type requires a custom backend server that can store your client secret
 and redirect URI.

 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
 */
public struct AuthorizationCodeFlowPKCEProxyBackend: AuthorizationCodeFlowPKCEBackend {

    /// The logger for this struct.
    public static var logger = Logger(
        label: "AuthorizationCodeFlowProxyBackend", level: .critical
    )
    
    /**
     The client id that you received when you [registered your application][1].
     
     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public let clientId: String

    /**
     The URL to your custom backend server that accepts a post request with the
     authorization code and coder verifier in the body in x-www-form-urlencoded
     format and which must return the authorization information.
     
     See `self.makePKCETokensRequest(code:codeVerifier:redirectURIWithQuery:)`
     for more information.
     */
    public let tokensURL: URL
    
    /**
     The URL to your custom backend server that accepts a post request with the
     refresh token in the body in x-www-form-urlencoded format and which must
     return the authorization information.

     See `self.makePKCERefreshTokenRequest(refreshToken:)` for more information.
     */
    public let tokenRefreshURL: URL

    /**
     Creates an instance that manages the authorization process for the
     [Authorization Code Flow with Proof Key for Code Exchange][1] by
     communicating with a custom backend server.
     
     This type requires a custom backend server that can store your client
     secret and redirect URI.

     - Parameters:
       - clientId: The client id that you received when you [registered your
             application][2].
       - tokensURL: The URL to your custom backend server that accepts a post
             request with the authorization code and coder verifier in the body
             in "x-www-form-urlencoded" format and which must return the
             authorization information. See
             `self.makePKCETokensRequest(code:codeVerifier:redirectURIWithQuery:)`
             for more information.
       - tokenRefreshURL: The URL to your custom backend server that accepts a
             post request with the refresh token in the body in
             "x-www-form-urlencoded" format and which must return the
             authorization information. See
             `self.makePKCERefreshTokenRequest(refreshToken:)` for more
             information.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    public init(clientId: String, tokensURL: URL, tokenRefreshURL: URL) {
        self.clientId = clientId
        self.tokensURL = tokensURL
        self.tokenRefreshURL = tokenRefreshURL
    }

    /**
     Exchanges an authorization code for the access and refresh tokens.
     
     This method makes a post request to `self.tokensURL`. The headers will
     contain the "Content-Type: application/x-www-form-urlencoded" header and
     the body will contain a key called "code" with the value set to the
     authorization code and a key called "code_verifier" with the value set to
     the code verifier in x-www-form-urlencoded format. For example:
     "code=AQDy8...xMhKNA&code_verifier=ahjhjds...ajhdh". See
     `RemotePKCETokensRequest`.
     
     The endpoint at `self.tokensURL` must return the authorization information
     as JSON data that can be decoded into `AuthInfo`. The `accessToken`,
     `refreshToken`, and `expirationDate` (which can be decoded from the
     "expires_in" JSON key) properties must be non-`nil`. For example:
     
     ```
     {
         "access_token": "NgCXRK...MzYjw",
         "token_type": "Bearer",
         "scope": "user-read-private user-read-email",
         "expires_in": 3600,
         "refresh_token": "NgAagA...Um_SHo"
     }
     ```
     
     Read about the underlying request that must be made to Spotify by your
     server in order to retrieve this data [here][1].
     
     - Parameters:
       - code: The authorization code, which will also be present in
             `redirectURIWithQuery`.
       - codeVerifier: The code verifier that you generated before creating the
             authorization URL.
       - redirectURIWithQuery: The URL that spotify redirected to after the user
             logged in to their Spotify account, with query parameters appended
             to it.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#:~:text=4.%20your%20app%20exchanges%20the%20code%20for%20an%20access%20token
     */
    public func makePKCETokensRequest(
        code: String,
        codeVerifier: String,
        redirectURIWithQuery: URL
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        
        let body = RemotePKCETokensRequest(
            code: code,
            codeVerifier: codeVerifier
        )
        .formURLEncoded()

        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
        Self.logger.trace(
            """
            POST request to "\(self.tokensURL)" \
            (URL for requesting access and refresh tokens); body:
            \(bodyString)
            """
        )

        var tokensRequest = URLRequest(url: self.tokensURL)
        tokensRequest.httpMethod = "POST"
        tokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
        tokensRequest.httpBody = body

        return URLSession.defaultNetworkAdaptor(
            request: tokensRequest
        )
        
    }

    /**
     Refreshes an access token using the refresh token.

     Access tokens expire after an hour, after which they must be refreshed
     using this method. This method will be called by
     `AuthorizationCodeFlowPKCEBackendManager.refreshTokens(onlyIfExpired:tolerance:)`.

     This method makes a post request to `self.tokenRefreshURL`. The headers
     will contain the "Content-Type: application/x-www-form-urlencoded" header
     and the body will contain a key called "refresh_token" with the value set
     to the the refresh token, a key called "method" with the value set to
     "PKCE", and a key called "grant_type" with the value set to "refresh_token"
     in x-www-form-urlencoded format. For example:
     "refresh_token=AQDy8...xMhKNA&method=PKCE&grant_type=refresh_token". See
     `RemotePKCERefreshAccessTokenRequest`.

     The endpoint at `self.tokenRefreshURL` must return the authorization
     information as JSON data that can be decoded into `AuthInfo`. The
     `accessToken`, `refreshToken`, and `expirationDate` (which can be decoded
     from the "expires_in" JSON key) properties must be non-`nil`. For example:

     ```
     {
         "access_token": "9Cysa896...Ps4BgEHw",
         "token_type": "Bearer",
         "expires_in": 3600,
         "refresh_token": "PoO04alC_...fKyMaP6zl6g",
         "scope": "user-follow-modify"
     }
     ```

     Read about the underlying request that must be made to Spotify in order to
     retrieve this data [here][1].
     
     - Parameter refreshToken: The refresh token, which can be exchanged for a
           new access token.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#:~:text=6.%20requesting%20a%20refreshed%20access%20token
     */
    public func makePKCERefreshTokenRequest(
        refreshToken: String
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        
        let body = RemotePKCERefreshAccessTokenRequest(
            refreshToken: refreshToken
        )
        .formURLEncoded()
                
        let bodyString = String(data: body, encoding: .utf8) ?? "nil"
        
        Self.logger.trace(
            """
            POST request to "\(self.tokenRefreshURL)" \
            (URL for refreshing access token); body:
            \(bodyString)
            """
        )

        var refreshTokensRequest = URLRequest(url: self.tokenRefreshURL)
        refreshTokensRequest.httpMethod = "POST"
        refreshTokensRequest.allHTTPHeaderFields = Headers.formURLEncoded
        refreshTokensRequest.httpBody = body

        return URLSession.defaultNetworkAdaptor(
            request: refreshTokensRequest
        )
        
    }
}

extension AuthorizationCodeFlowPKCEProxyBackend: CustomStringConvertible {
    
    public var description: String {
        return """
            AuthorizationCodeFlowPKCEProxyBackend(
                clientId: "\(self.clientId)"
                tokenURL: "\(self.tokensURL)"
                tokenRefreshURL: "\(self.tokenRefreshURL)"
            )
            """
    }

}
