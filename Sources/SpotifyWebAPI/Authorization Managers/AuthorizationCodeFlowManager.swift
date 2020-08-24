import Foundation
import Combine
import Logger

/**
 Manages the authorization process for the [Authorization Code Flow][1].
 
 Contains the following properties:
 
 * The client id
 * The client secret
 * The access token
 * the refresh token
 * the expiration date for the access token
 * the scopes that have been authorized for the access token
 
 The first step in the authorization code flow is to make the
 authorization URL using
 `makeAuthorizationURL(redirectURI:scopes:showDialog:state:)`.
 
 Open this url in a broswer/webview to allow the user to login
 to their Spotify account and authorize your application.
 After they either authorize or deny authorization for your application,
 Spotify will redirect to the redirect URI sepcified in the authorization
 URL with query parameters appended to it. Pass this URL into
 `requestAccessAndRefreshTokens(redirectURIWithQuery:state:)`. To request
 the refresh and access tokens. After that you can begin making requests
 to the Spotify API. the access token will be refreshed for you
 automatically when needed.
 
 Use `isAuthorized(for:)` to check if your application is authorized
 for the specified scopes.
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 */
public class AuthorizationCodeFlowManager: SpotifyAuthorizationManager, Codable {
    
    public let logger = Logger(
        label: "AuthorizationCodeFlowManager", level: .trace
    )
    
    /// The client id for your application.
    public let clientId: String
    
    /// The client secret for you application.
    public let clientSecret: String
    
    /// The access token used in all of the requests
    /// to the Spotify web API
    public private(set) var accessToken: String? = nil
    
    /// Used to refresh the access token.
    public private(set) var refreshToken: String? = nil
    
    /// The expiration date of the access token
    public private(set) var expirationDate: Date? = nil
    
    /// The scopes that have been authorized for the access token.
    public private(set) var scopes: Set<Scope>? = nil
    
    private var cancellables: Set<AnyCancellable> = []

    /// A `PassthroughSubject` that emits **AFTER** this
    /// `AuthorizationCodeFlowManager` has changed.
    public let didChange = PassthroughSubject<Void, Never>()
    
    /**
     Creates an authorization manager for the [Authorization Code Flow][1].
     
     - Parameters:
       - clientId: The client id for your application.
       - clientSecret: The client secret for your application.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     */
    public init(
        clientId: String,
        clientSecret: String
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.didChange.send()
    }
    
    func updateFromAuthInfo(_ authInfo: AuthInfo) {
        self.accessToken = authInfo.accessToken
        if let refreshToken = authInfo.refreshToken {
            self.refreshToken = refreshToken
        }
        self.expirationDate = authInfo.expirationDate
        self.scopes = authInfo.scopes
        
        self.logger.trace("after updateFromAuthInfo:\n\(self)")
        self.didChange.send()
    }
    
    
    // MARK: - Codable Conformance -
        
    public required init(from decoder: Decoder) throws {
        
        let codingWrapper = try AuthInfo(from: decoder)
        
        self.accessToken = codingWrapper.accessToken
        self.refreshToken = codingWrapper.refreshToken
        self.expirationDate = codingWrapper.expirationDate
        self.scopes = codingWrapper.scopes
        
        let container = try decoder.container(
            keyedBy: AuthInfo.CodingKeys.self
        )
        self.clientId = try container.decode(
            String.self, forKey: .clientId
        )
        self.clientSecret = try container.decode(
            String.self, forKey: .clientSecret
        )

    }
    
    public func encode(to encoder: Encoder) throws {
        
        let codingWrapper = AuthInfo(
            accessToken: self.accessToken,
            refreshToken: self.refreshToken,
            expirationDate: self.expirationDate,
            scopes: self.scopes
        )
        
        var container = encoder.container(
            keyedBy: AuthInfo.CodingKeys.self
        )
        
        try container.encode(
            self.clientId, forKey: .clientId
        )
        try container.encode(
            self.clientSecret, forKey: .clientSecret
        )
        try codingWrapper.encode(to: encoder)
        
    }
    
}

public extension AuthorizationCodeFlowManager {
    
    func mockValues() {
        self.accessToken = UUID().uuidString
        self.refreshToken = UUID().uuidString
        self.expirationDate = Date()
        self.scopes = Set(Scope.allCases.shuffled().prefix(4))
    }
    
    
    /// Sets `accessToken`, `refreshToken`, `expirationDate`, and
    /// `scopes` to `nil`. Does not change `clientId` or `clientSecret`,
    /// which are immutable.
    func logout() {
        self.accessToken = nil
        self.refreshToken = nil
        self.expirationDate = nil
        self.scopes = nil
        self.didChange.send()
    }
    
    /**
     Determines whether the access token is expired
     within the given tolerance.
     
     - Parameter tolerance: The tolerance in seconds.
           Default 60.
     - Returns: `true` if `expirationDate` + `tolerance` is
           equal to or before the current date. Else, `false`.
     */
    func isExpired(tolerance: Double = 60) -> Bool {
        guard let expirationDate = expirationDate else { return false }
        return expirationDate.addingTimeInterval(tolerance) <= Date()
    }
    
    /**
     Returns `true` if `accessToken` is not `nil` and the application
     is authorized for the specified scopes, else `false`.
     
     - Parameter scopes: A set of [Spotify Authorizaion Scopes][1].
           Use an empty set (default) to check if an `accessToken`
           has been retrieved for the application,
           which is still required for all endpoints,
           even if no scopes are required.
     
     [1]: https://developer.spotify.com/documentation/general/guides/scopes/
     */
    func isAuthorized(for scopes: Set<Scope> = []) -> Bool {
        if accessToken == nil { return false }
        return scopes.isSubset(of: self.scopes ?? [])
    }
    
    /**
     The first step in the [Authorization Code Flow][1].
     
     Creates the URL that is used to request authorization for
     your app. Open the URL in a browser/webview so that the user can
     login to their Spotify account and authorize your app.
     
     - Warning: **DO NOT add a forward-slash to the end of the redirect URI**.

     - Parameters:
       - redirectURI: The location that Spotify will redirect to
             after the user authorizes or denies authorization for your app.
             This should link to a location in your app.
       - showDialog: Whether or not to force the user to approve the app again
             if they’ve already done so. If `false`,
             a user who has already approved the application
             may be automatically redirected to the `redirectURI`.
             If `true`, the user will not be automatically
             redirected and will have to approve the app again.
       - state: Optional, but strongly recommended. The state can be useful for
             correlating requests and responses. Because your redirect_uri can
             be guessed, using a state value can increase your assurance that
             an incoming connection is the result of an authentication request.
             If you generate a random string or encode the hash of some client
             state (e.g., a cookie) in this state variable, you can validate the
             response to additionally ensure that the request and response
             originated in the same browser. This provides protection against
             attacks such as cross-site request forgery.
       - scopes: A set of [Spotify Authorization scopes][2].
     - Returns: The URL that must be opened to authorize your app.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     [2]: x-source-tag://Scopes
     
     - Tag: makeAuthorizationURL
     */
    func makeAuthorizationURL(
        redirectURI: URL,
        showDialog: Bool,
        state: String? = nil,
        scopes: Set<Scope>
    ) -> URL {
        
        guard let url = URL(
            scheme: "https",
            host: Endpoints.accountsBase,
            path: Endpoints.authorize,
            queryItems: removeIfNil([
                "client_id": self.clientId,
                "response_type": "code",
                "redirect_uri": redirectURI.absoluteString,
                "scope": Scope.makeString(scopes),
                "show_dialog": "\(showDialog)",
                "state": state
            ])
        )
        else {
            fatalError("could not create authorization url.")
        }
        return url
        
    }
    
    /**
     The second step in the [Authorization Code Flow][1].
     
     After you open the url from
     `makeAuthorizationURL(redirectURI:scopes:showDialog:state:)`
     and the user either authorizes or denies authorization for your app,
     Spotify will redirect to the redirect uri you specified with query
     parameters appended to it. Pass this URL into this method to request
     access and refresh tokens.
     
     - Parameters:
       - redirectURI: The redirect URI with query parameters appended to it.
       - state: The value of the state parameter that you provided when
             making the authorization URL. If this is non-nil and doesn't
             match the value for the state parameter found in the query
             string of `redirectURIWithQuery`, an error will be thrown.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
     
     - Tag: requestAccessAndRefreshTokens-redirectURIWithQuery
     */
    func requestAccessAndRefreshTokens(
        redirectURIWithQuery redirectURI: URL,
        state: String? = nil
    ) -> AnyPublisher<Void, Error> {
        
        let queryDict = redirectURI.queryItemsDict

        // if the code is found in the query,
        // then the user successfully authorized the application.
        // this is required for requesting the access and refresh tokens.
        guard let code = queryDict["code"] else {
            
            if let error = queryDict["error"] {
                self.logger.warning("redirect uri query has error")
                // this is the way that the authorization should fail
                return SpotifyAuthorizationError(
                    error: error, state: queryDict["state"]
                )
                .anyFailingPublisher(Void.self)
            }
            
            self.logger.error("unkown error")
            return SpotifyLocalError.other(
                "an unknown error occured when handling the redirect URI:\n" +
                    redirectURI.absoluteString
            )
            .anyFailingPublisher(Void.self)
            
        }
        
        // if the client supplied a state and a state parameter was
        // provided in the query string of the redirect URI,
        // then ensure that they match.
        if let redirectURIstate = queryDict["state"], let state = state {
            guard redirectURIstate == state else {
                return SpotifyLocalError.invalidState(
                    supplied: state, received: redirectURIstate
                )
                .anyFailingPublisher(Void.self)
            }
        }
        
        let baseRedirectURI = redirectURI
            .removingQueryItems()
            .removingTrailingSlashInPath()
        
        let requestBody = TokensRequest(
            code: code,
            redirectURI: baseRedirectURI,
            clientId: clientId,
            clientSecret: clientSecret
        ).formURLEncoded()
        
        self.logger.trace("sending request for refresh and access tokens")
        
        return URLSession.shared.dataTaskPublisher(
            url: Endpoints.getRefreshAndAccessTokensURL,
            httpMethod: "POST",
            headers: Headers.formURLEncoded,
            body: requestBody
        )
        .spotifyDecode(AuthInfo.self)
        .receive(on: RunLoop.main)
        .map { authInfo in
            
            self.logger.trace("received authInfo:\n\(authInfo)")
            
            if authInfo.accessToken == nil ||
                    authInfo.refreshToken == nil ||
                    authInfo.expirationDate == nil ||
                    authInfo.scopes == nil {
                
                self.logger.critical(
                    """
                    missing properties after requesting \
                    access and refresh tokens:
                    \(authInfo)
                    """
                )
            }
            
            self.updateFromAuthInfo(authInfo)
            
        }
        .eraseToAnyPublisher()
        
        
    }
    

    /**
     Uses the refresh token to get a new access token.
    
     **You shouldn't need to call this method**. It gets
     called automatically each time you make a request to the
     Spotify API.
     
     - Parameters:
       - onlyIfExpired: Only refresh the token if it is expired.
       - tolerance: The tolerance in seconds to use when determining
             if the token is expired. Defaults to 60.
             The token is considered expired if
             `expirationDate` + `tolerance` is equal to or
             before the current date.
     */
    func refreshTokens(
        onlyIfExpired: Bool,
        tolerance: Double = 60
    ) -> AnyPublisher<Void, Error> {
        
        do {
        
            if onlyIfExpired && !self.isExpired(tolerance: tolerance) {
                self.logger.trace("access token not expired; returning early")
                return Result<Void, Error>
                    .Publisher(())
                    .eraseToAnyPublisher()
            }
        
            guard let refreshToken = refreshToken else {
                self.logger.critical(
                    "can't refresh access token: no refresh token"
                )
                throw SpotifyLocalError.other(
                    "can't refresh access token: no refresh token"
                )
            }
        
            guard let header = Headers.basicBase64Encoded(
                clientId: self.clientId, clientSecret: self.clientSecret
            )
            else {
                // this error should never occur
                let message = "couldn't base 64 encode " +
                "client id and client secret"
                self.logger.critical("\(message)")
                throw SpotifyLocalError.other(message)
            }
        
            let requestBody = RefreshAccessTokenRequest(
                refreshToken: refreshToken
            ).formURLEncoded()
        
            return URLSession.shared.dataTaskPublisher(
                url: Endpoints.getRefreshAndAccessTokensURL,
                httpMethod: "POST",
                headers: header,
                body: requestBody
            )
            .spotifyDecode(AuthInfo.self)
            .receive(on: RunLoop.main)
            .map { authInfo in
        
                self.logger.trace("received authInfo:\n\(authInfo)")
                
                if authInfo.accessToken == nil ||
                        authInfo.expirationDate == nil ||
                        authInfo.scopes == nil {
                    self.logger.critical(
                        """
                        missing properties after refreshing access token:
                        \(authInfo)
                        """
                    )
                }
                
                self.updateFromAuthInfo(authInfo)
                
            }
            .eraseToAnyPublisher()
        
        
        } catch {
            return error.anyFailingPublisher(Void.self)
        }
        
    }
    
}


// MARK: - Custom String Convertible

extension AuthorizationCodeFlowManager: CustomStringConvertible {
    
    public var description: String {
        
        let expirationDateString = expirationDate?
                .description(with: .autoupdatingCurrent)
                ?? "nil"
        
        let scopeString = scopes.map({ "\($0.map(\.rawValue))" })
                ?? "nil"
        
        return """
            AuthorizationCodeFlowManager(
                access_token: "\(accessToken ?? "nil")"
                scopes: \(scopeString)
                expirationDate: \(expirationDateString)
                refresh_token: "\(refreshToken ?? "nil")"
                client id: "\(clientId)"
                client secret: "\(clientSecret)"
            )
            """
    }

}
