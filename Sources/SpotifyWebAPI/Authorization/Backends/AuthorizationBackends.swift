import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

/**
 A type that handles the process of requesting the authorization information and
 refreshing the access token using the Authorization Code Flow.

 Conforming types may communicate directly with the Spotify web API (see
 ``AuthorizationCodeFlowClientBackend``), or they may communicate with a custom
 backend server that you setup (see ``AuthorizationCodeFlowProxyBackend``) which
 itself communicates with the Spotify web API. This server can safely store your
 client secret, which prevents it from being exposed in your frontend app. This
 is the key reason for using a backend server.

 See also [SpotifyAPIServer][2], a backend server that can handle authorization
 process.
 
 Furthermore, after your backend server retrieves the authorization information
 from Spotify, it could encrypt it before sending it back to your app. Your app
 could then decrypt this information when it receives it, providing an
 additional layer of security.
 
 Read more about the [Authorization Code Flow][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 [2]: https://github.com/Peter-Schorn/SpotifyAPIServer
 */
public protocol AuthorizationCodeFlowBackend: Codable, Hashable {
	
    /**
     The client id that you received when you registered your application.
     
     This is used to construct the authorization URL in the
     ``AuthorizationCodeFlowBackendManager/makeAuthorizationURL(redirectURI:showDialog:state:scopes:)``
     method of ``AuthorizationCodeFlowBackendManager``.
     
     Read more about [registering your application][1].

     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    var clientId: String { get }
    
    /**
     Exchanges an authorization code for the access and refresh tokens.

     After validating `redirectURIWithQuery`,
     the
     ``AuthorizationCodeFlowBackendManager/requestAccessAndRefreshTokens(redirectURIWithQuery:state:)``
     method of ``AuthorizationCodeFlowBackendManager``
     calls this method in order to retrieve the authorization information.

     If the `redirectURIWithQuery` contains an error parameter or the value for
     the state parameter doesn't match the value passed in as an argument to the
     above method, then an error will be thrown *before* this method is called.

     This method must return the authorization information as JSON data that can
     be decoded into ``AuthInfo``. The ``AuthInfo/accessToken``,
     ``AuthInfo/refreshToken``, and ``AuthInfo/expirationDate`` (which can be
     decoded from the "expires_in" JSON key) properties must be non-`nil`. For
     example:

     ```
     {
        "access_token": "NgCXRK...MzYjw",
        "token_type": "Bearer",
        "scope": "user-read-private user-read-email",
        "expires_in": 3600,
        "refresh_token": "NgAagA...Um_SHo"
     }
     ```

     If Spotify returns one of the documented error objects, such as
     ``SpotifyAuthenticationError``, do not decode the data into one of these
     types yourself; this will be done by the caller. If you are communicating
     with a custom backend server and it returns its own error response, decode
     it into a custom error type and throw it as an error to downstream
     subscribers.

     Read about the underlying request that must be made to Spotify in order to
     retrieve this data [here][1].
     
     See also ``TokensRequest`` and ``ProxyTokensRequest``.
     
     - Parameters:
       - code: The authorization code, which will also be present in
             `redirectURIWithQuery`.
       - redirectURIWithQuery: The URL that spotify redirected to after the user
             logged in to their Spotify account, with query parameters appended
             to it.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-access-token
     */
	func requestAccessAndRefreshTokens(
        code: String,
        redirectURIWithQuery: URL
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
	
    /**
     Refreshes an access token using the refresh token.

     Access tokens expire after an hour, after which they must be refreshed
     using this method. This method will be called by the
     ``AuthorizationCodeFlowBackendManager/refreshTokens(onlyIfExpired:tolerance:)``
     method of ``AuthorizationCodeFlowBackendManager``.

     This method must return the authorization information as JSON data that can
     be decoded into ``AuthInfo``. The ``AuthInfo/accessToken`` and
     ``AuthInfo/expirationDate`` (which can be decoded from the "expires_in"
     JSON key) properties must be non-`nil`. For example:

     ```
     {
        "access_token": "NgCXRK...MzYjw",
        "token_type": "Bearer",
        "scope": "user-read-private user-read-email",
        "expires_in": 3600
     }
     ```

     If Spotify returns one of the documented error objects, such as
     ``SpotifyAuthenticationError``, do not decode the data into one of these
     types yourself; this will be done by the caller. If you are communicating
     with a custom backend server and it returns its own error response, decode
     it into a custom error type and throw it as an error to downstream
     subscribers.

     Read about the underlying request that must be made to Spotify in order to
     retrieve this data [here][1].
     
     See also ``RefreshTokensRequest``.

     - Parameter refreshToken: The refresh token, which can be exchanged for
           a new access token.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-a-refreshed-access-token
     */
    func refreshTokens(
        refreshToken: String
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
    
}

/**
 A type that handles the process of requesting the authorization information and
 refreshing the access token using the Authorization Code Flow with Proof Key
 for Code Exchange.

 Conforming types may communicate directly with the Spotify web API (see
 ``AuthorizationCodeFlowPKCEClientBackend``), or they may communicate with a
 custom backend server that you setup (see
 ``AuthorizationCodeFlowPKCEProxyBackend``) which itself communicates with the
 Spotify web API. This server can safely store your client secret, which
 prevents it from being exposed in your frontend app. This is the key reason for
 using a backend server.
 
 See also [SpotifyAPIServer][2], a backend server that can handle authorization
 process.

 Furthermore, after your backend server retrieves the authorization information
 from Spotify, it could encrypt it before sending it back to your app. Your app
 could then decrypt this information when it receives it, providing an
 additional layer of security.
 
 Read more about the
 [Authorization Code Flow with Proof Key for Code Exchange][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/
 [2]: https://github.com/Peter-Schorn/SpotifyAPIServer
 */
public protocol AuthorizationCodeFlowPKCEBackend: Codable, Hashable {
    
    /**
     The client id that you received when you registered your application.
     
     This is used to construct the authorization URL in the
     ``AuthorizationCodeFlowPKCEBackendManager/makeAuthorizationURL(redirectURI:codeChallenge:state:scopes:)``
     method of ``AuthorizationCodeFlowPKCEBackendManager``.
     
     Read more about [registering your application][1].

     [1]: https://developer.spotify.com/documentation/general/guides/app-settings/#register-your-app
     */
    var clientId: String { get }

    /**
     Exchanges an authorization code for the access and refresh tokens.

     After validating the `redirectURIWithQuery`, the
     ``AuthorizationCodeFlowPKCEBackendManager/requestAccessAndRefreshTokens(redirectURIWithQuery:codeVerifier:state:)``
     method of ``AuthorizationCodeFlowPKCEBackendManager`` calls this method in
     order to retrieve the authorization information.

     If the `redirectURIWithQuery` contains an error parameter or the value for
     the state parameter doesn't match the value passed in as an argument to the
     above method, then an error will be thrown *before* this method is called.

     This method must return the authorization information as JSON data that can
     be decoded into ``AuthInfo``. The ``AuthInfo/accessToken``,
     ``AuthInfo/refreshToken``, and ``AuthInfo/expirationDate`` (which can be
     decoded from the "expires_in" JSON key) properties must be non-`nil`. For
     example:

     ```
     {
        "access_token": "NgCXRK...MzYjw",
        "token_type": "Bearer",
        "scope": "user-read-private user-read-email",
        "expires_in": 3600,
        "refresh_token": "NgAagA...Um_SHo"
     }
     ```

     If Spotify returns one of the documented error objects, such as
     ``SpotifyAuthenticationError``, do not decode the data into one of these
     types yourself; this will be done by the caller. If you are communicating
     with a custom backend server and it returns its own error response, decode
     it into a custom error type and throw it as an error to downstream
     subscribers.

     Read about the underlying request that must be made to Spotify in order to
     retrieve this data [here][1].
     
     See also ``PKCETokensRequest`` and ``ProxyPKCETokensRequest``.

     - Parameters:
       - code: The authorization code, which will also be present in
             `redirectURIWithQuery`.
       - codeVerifier: The code verifier that you generated before creating the
             authorization URL.
       - redirectURIWithQuery: The URL that spotify redirected to after the user
             logged in to their Spotify account, with query parameters appended
             to it.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-access-token
     */
    func requestAccessAndRefreshTokens(
        code: String,
        codeVerifier: String,
        redirectURIWithQuery: URL
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
    
    /**
     Refreshes an access token using the refresh token.

     Access tokens expire after an hour, after which they must be refreshed
     using this method. This method will be called by the
     ``AuthorizationCodeFlowPKCEBackendManager/refreshTokens(onlyIfExpired:tolerance:)``
     method of ``AuthorizationCodeFlowPKCEBackendManager``.

     This method must return the authorization information as JSON data that can
     be decoded into ``AuthInfo``. The ``AuthInfo/accessToken``,
     ``AuthInfo/refreshToken``, and ``AuthInfo/expirationDate`` (which can be
     decoded from the "expires_in" JSON key) properties must be non-`nil`. For
     example:

     ```
     {
         "access_token": "9Cysa896...Ps4BgEHw",
         "token_type": "Bearer",
         "expires_in": 3600,
         "refresh_token": "PoO04alC_...fKyMaP6zl6g",
         "scope": "user-follow-modify"
     }
     ```

     If Spotify returns one of the documented error objects, such as
     ``SpotifyAuthenticationError``, do not decode the data into one of these
     types yourself; this will be done by the caller. If you are communicating
     with a custom backend server and it returns its own error response, decode
     it into a custom error type and throw it as an error to downstream
     subscribers.

     Read about the underlying request that must be made to Spotify in order to
     retrieve this data [here][1].
     
     See also ``PKCERefreshTokensRequest`` and
     ``ProxyPKCERefreshTokensRequest``.

     - Parameter refreshToken: The refresh token, which can be exchanged for a
           new access token.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/code-flow/#request-a-refreshed-access-token
     */
	func refreshTokens(
        refreshToken: String
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
    
}

/**
 A type that handles the process of requesting the authorization information
 using the Client Credentials Flow.

 Conforming types may communicate directly with the Spotify web API (see
 ``ClientCredentialsFlowClientBackend``), or it they may communicate with a
 custom backend server that you configure (see
 ``ClientCredentialsFlowProxyBackend``). This backend server can safely store
 your client id and client secret and retrieve the authorization information
 from Spotify on your behalf, thereby preventing these sensitive credentials
 from being exposed in your frontend app.
 
 See also [SpotifyAPIServer][2], a backend server that can handle authorization
 process.

 Furthermore, after your backend server retrieves the authorization information
 from Spotify, it could encrypt it before sending it back to your app. Your app
 could then decrypt this information when it receives it, providing an
 additional layer of security.
 
 Read more about the [Client Credentials Flow][1].
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
 [2]: https://github.com/Peter-Schorn/SpotifyAPIServer
 */
public protocol ClientCredentialsFlowBackend: Codable, Hashable {
    
    /**
     Makes a request for the authorization information.
     
     This method is called by either the
     ``ClientCredentialsFlowBackendManager/authorize()`` or
     ``ClientCredentialsFlowBackendManager/refreshTokens(onlyIfExpired:tolerance:)``
     methods of ``ClientCredentialsFlowBackendManager``. The client credentials
     flow does not provide a refresh token, so in both cases, the same network
     request should be made.
     
     This method must return the authorization information as JSON data that can
     be decoded into ``AuthInfo``. The ``AuthInfo/accessToken`` and
     ``AuthInfo/expirationDate`` (which can be decoded from the "expires_in"
     JSON key) properties must be non-`nil`. For example:
     
     ```
     {
         "access_token": "NgCXRKc...MzYjw",
         "token_type": "bearer",
         "expires_in": 3600,
     }
     ```
     
     If Spotify returns one of the documented error objects, such as
     ``SpotifyAuthenticationError``, do not decode the data into one of these
     types yourself; this will be done by the caller. If you are communicating
     with a custom backend server and it returns its own error response, decode
     it into a custom error type and throw it as an error to downstream
     subscribers.
     
     Read about the underlying request that must be made to Spotify in order to
     retrieve this data [here][1].
     
     See also ``ClientCredentialsTokensRequest``.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/#request-authorization
     */
    func makeClientCredentialsTokensRequest(
    ) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>

}
