import Foundation
import Combine
import Logger


/**
 Manages the authorization proccess for the [Client Credentials Flow][1].
 
 The Client Credentials flow is used in server-to-server authentication.
 Only endpoints that do not access user information can be accessed.
 This means that endpoints that require [authorization scopes][2]
 cannot be accessed.
 
 The only method you must call to authorize your application is
 `authorize()`. After that, you may begin making requests to the
 Soptify web API.
 
 The advantage of this authorization proccess is that no user
 interaction is required.
 
 Contains the following properties:
 
 * The client id
 * The client secret
 * The access token
 * The expiration date of the access token
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
 [2]: https://developer.spotify.com/documentation/general/guides/scopes/
 */
public final class ClientCredentialsFlowManager: SpotifyAuthorizationManager {
    
    /// The logger for this class. By default, its level is `critical`.
    public static let logger = Logger(
        label: "ClientCredentialsFlowManager", level: .critical
    )
    
    /// The client id for your application.
    public let clientId: String
    
    /// The client secret for your application.
    public let clientSecret: String
    
    /// Spotify authorization scopes. **Always** an empty set
    /// because the client credentials flow does not support
    /// authorization scopes.
    public let scopes: Set<Scope>? = []
    
    /// The access token used in all of the requests
    /// to the Spotify web API
    public var accessToken: String?
    
    /// The expiration date of the access token.
    ///
    /// You are encouraged to use `accessTokenIsExpired(tolerance:)`
    /// to check if the token is expired.
    public var expirationDate: Date?
    
    /// Ensure no data races occur when updating auth info.
    private let updateAuthInfoDispatchQueue = DispatchQueue(
        label: "updateAuthInfoDispatchQueue"
    )
    
    /**
     A Publisher that emits **after** this
     `ClientCredentialsFlowManager` has changed.
     
     You are discouraged from subscribing to this publisher directly.
     Intead, subscribe to the `authorizationManagerDidChange` publisher
     of `SpotifyAPI`. This allows you to be notified of changes even
     when you create a new instance of this class and assign it to the
     `authorizationManager` instance property of `SpotifyAPI`.
     
     # Thread Safety
     No guarantees are made about which thread this subject will emit on.
     Always receive on the main thread if you plan on updating the UI.
     */
    public let didChange = PassthroughSubject<Void, Never>()
    
    /**
     Creates an authorization manager for the [Client Credentials Flow][1].
     
     Remember, with this authorization flow, only endpoints that do not
     access user information can be accessed. This means that endpoints
     that require [authorization scopes][2] cannot be accessed.
     
     To get your client id and secret, see the
     [guide for registering your app][3].
     
     - Parameters:
       - clientId: The client id for your application.
       - clientSecret: The client secret for your application.

     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
     [2]: https://developer.spotify.com/documentation/general/guides/scopes/
     [3]: https://developer.spotify.com/documentation/general/guides/app-settings/
     */
    public init(
        clientId: String,
        clientSecret: String
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    
    func updateFromAuthInfo(_ authInfo: AuthInfo) {
        updateAuthInfoDispatchQueue.sync {
            self.accessToken = authInfo.accessToken
            self.expirationDate = authInfo.expirationDate
            self.didChange.send()
            Self.logger.trace(
                "updated from auth Info; self.didChange.send()"
            )
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let codingWrapper = try AuthInfo(from: decoder)
        
        self.accessToken = codingWrapper.accessToken
        self.expirationDate = codingWrapper.expirationDate
        
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
        
        let codingWrapper = updateAuthInfoDispatchQueue.sync {
            AuthInfo(
                accessToken: self.accessToken,
                refreshToken: nil,
                expirationDate: self.expirationDate,
                scopes: nil
            )
        }
        
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


public extension ClientCredentialsFlowManager {
    
    /**
     Sets `accessToken` and `expirationDate` to `nil`.
     Does not change `clientId` or `clientSecret`, which are immutable.

     After calling this method, you must authorize your application
     again before accessing any of the Spotify web API endpoints.
     
     If this instance is stored in persistent storage, consider
     removing it after calling this method.
     */
    func deauthorize() {
        updateAuthInfoDispatchQueue.sync {
            self.accessToken = nil
            self.expirationDate = nil
            self.didChange.send()
        }
    }
    
    /**
     Determines whether the access token is expired
     within the given tolerance.
     
     The access token is refreshed automatically if needed
     before each request to the spotify web API is made.
     Therefore, you should never need to call this method directly.
     
     - Parameter tolerance: The tolerance in seconds.
           Default 120.
     - Returns: `true` if `expirationDate` - `tolerance` is
           equal to or before the current date or if `accessToken`
           is `nil`. Else, `false`.
     */
    func accessTokenIsExpired(tolerance: Double = 120) -> Bool {
        if (accessToken == nil) != (self.expirationDate == nil) {
            let expirationDateString = self.expirationDate?
                    .description(with: .current) ?? "nil"
            Self.logger.critical(
                "accessToken or expirationDate was nil, but not both: " +
                "accessToken == nil: \(accessToken == nil);" +
                "expiration date: \(expirationDateString)"
            )
        }
        guard accessToken != nil else { return true }
        guard let expirationDate = expirationDate else { return true }
        return expirationDate.addingTimeInterval(-tolerance) <= Date()
    }
    
    /**
     Returns `true` if `accessToken` is not `nil` and
     the set of scopes is empty.
     
     - Parameter scopes: A set of [Spotify Authorizaion Scopes][1].
           This must be an empty set, or this method will return `false`.
           This is because The client credentials flow does not support
           authorization scopes; it only supports endpoints that do not
           access user data.
     
     [1]: https://developer.spotify.com/documentation/general/guides/scopes/
     */
    func isAuthorized(for scopes: Set<Scope> = []) -> Bool {
        if accessToken == nil { return false }
        return scopes.isEmpty
    }
    
    /**
     Authorizes the application for the [Client Credentials Flow][1].
     
     This is the only method you need to call to authorize your application.
     After this, you can begin making requests to the Spotify web API.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
     */
    func authorize() -> AnyPublisher<Void, Error> {
        
        Self.logger.trace("authorizing")
        
        let body = [
            "grant_type": "client_credentials"
        ].formURLEncoded()!
        
        
        let headers = Headers.basicBase64Encoded(
            clientId: clientId, clientSecret: clientSecret
        )
        
        return URLSession.shared.dataTaskPublisher(
            url: Endpoints.getTokens,
            httpMethod: "POST",
            headers: headers,
            body: body
        )
        .decodeSpotifyErrors()
        .decodeSpotifyObject(AuthInfo.self)
        .map { authInfo in
         
            Self.logger.trace("received authInfo:\n\(authInfo)")
            
            if authInfo.accessToken == nil ||
                    authInfo.expirationDate == nil {
                
                Self.logger.critical(
                    """
                    missing properties after requesting access token:
                    \(authInfo)
                    """
                )
            }
            
            self.updateFromAuthInfo(authInfo)
            
        }
        .eraseToAnyPublisher()
        
    }
    
    /**
     Retrieves a new access token.
    
     **You shouldn't need to call this method**. It gets
     called automatically each time you make a request to the
     Spotify API.
     
     The [Client Credentials Flow][1] does not return a refresh token,
     so calling this method and passing in `false` for `onlyIfExpired`
     is equivalent to calling `authorize`.
     
     - Parameters:
       - onlyIfExpired: Only retrieve a new access token if the current
             one is expired.
       - tolerance: The tolerance in seconds to use when determining
             if the token is expired. Defaults to 120. The token is
             considered expired if `expirationDate` - `tolerance` is
             equal to or before the current date. This parameter has
             no effect if `onlyIfExpired` is `false`.
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
     */
    func refreshTokens(
        onlyIfExpired: Bool,
        tolerance: Double = 120
    ) -> AnyPublisher<Void, Error> {
        
        if onlyIfExpired && !self.accessTokenIsExpired(tolerance: tolerance) {
            Self.logger.trace("access token not expired; returning early")
            return Result<Void, Error>
                .Publisher(())
                .eraseToAnyPublisher()
        }
        
        Self.logger.trace("access token is expired, authorizing again")
        
        // the process for refreshing the token
        // is the same as that for authorizing the application.
        // the client credentials flow does not return a refresh token,
        // unlike the authorization code flow.
        return self.authorize()
        
    }
    
    
}

// MARK: - Hashable and Equatable -

extension ClientCredentialsFlowManager: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(clientId)
        hasher.combine(clientSecret)
        hasher.combine(accessToken)
        hasher.combine(expirationDate)
    }
    
    public static func == (
        lhs: ClientCredentialsFlowManager,
        rhs: ClientCredentialsFlowManager
    ) -> Bool {
        
        if lhs.clientId != rhs.clientId ||
                lhs.clientSecret != rhs.clientSecret ||
                lhs.accessToken != rhs.accessToken {
            return false
        }
        return abs(
            (lhs.expirationDate?.timeIntervalSince1970 ?? 0) -
            (rhs.expirationDate?.timeIntervalSince1970 ?? 0)
        ) <= 5
    }
    
    
}

// MARK: - Custom String Convertible

extension ClientCredentialsFlowManager: CustomStringConvertible {
    
    public var description: String {
        return updateAuthInfoDispatchQueue.sync {
            
            let expirationDateString = expirationDate?
                .description(with: .autoupdatingCurrent)
                ?? "nil"
        
            return """
            ClientCredentialsFlowManager(
            access_token: "\(accessToken ?? "nil")"
            expirationDate: \(expirationDateString)
            client id: "\(clientId)"
            client secret: "\(clientSecret)"
            )
            """
        
        }
    }

}

// MARK: - Testing -

extension ClientCredentialsFlowManager {
    
    /// This method sets random values for various properties
    /// for testing purposes. Do not call it outside of test cases.
    func mockValues() {
        updateAuthInfoDispatchQueue.sync {
            self.expirationDate = Date()
            self.accessToken = UUID().uuidString
        }
    }
    
    /// Only use for testing purposes.
    func setExpirationDate(to date: Date) {
        updateAuthInfoDispatchQueue.sync {
            Self.logger.notice(
                "mock date: \(date.description(with: .current))"
            )
            self.expirationDate = date
        }
    }
    
}
