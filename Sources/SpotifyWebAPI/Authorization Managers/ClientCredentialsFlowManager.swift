import Foundation
import Combine
import Logger


/**
 Manages the authorization proccess for the [Client Credentials Flow][1].
 
 The Client Credentials flow is used in server-to-server authentication.
 Only endpoints that do not access user information can be accessed.
 This means that endpoints that require [authorization scopes][2]
 cannot be accessed.
 
 The only method you must call the authorizse your application is
 `authorize()`. After that, you may begin making requests to the
 Soptify web API.
 
 The advantage of this authorization proccess is that no user
 interaction is required.
 
 Contains the following properties:
 
 * The client id
 * The client secret
 * The access token
 * The expiration date for the access token
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#client-credentials-flow
 [2]: https://developer.spotify.com/documentation/general/guides/scopes/
 */
public final class ClientCredentialsFlowManager: SpotifyAuthorizationManager {
    
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
    public var expirationDate: Date?
    
    /// A `PassthroughSubject` that emits **AFTER** this
    /// `ClientCredentialsFlowManager` has changed.
    public let didChange = PassthroughSubject<Void, Never>()
    
    public let logger = Logger(
        label: "ClientCredentialsFlowManager", level: .trace
    )
    
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
        self.didChange.send()
    }
    
    
    func updateFromAuthInfo(_ authInfo: AuthInfo) {
        self.accessToken = authInfo.accessToken
        self.expirationDate = authInfo.expirationDate
        
        self.logger.trace("after updateFromAuthInfo:\n\(self)")
        self.didChange.send()
    }
    
    // MARK: - Codable Conformance -
        
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
        
        let codingWrapper = AuthInfo(
            accessToken: self.accessToken,
            refreshToken: nil,
            expirationDate: self.expirationDate,
            scopes: nil
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


public extension ClientCredentialsFlowManager {
    
    func logout() {
        self.accessToken = nil
        self.expirationDate = nil
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
     Returns `true` if `accessToken` is not `nil` and
     the set of scopes is empty.
     
     The client credentials flow does not support authorization scopes.
     It only supports endpoints that do not access user data.
     
     - Parameter scopes: A set of [Spotify Authorizaion Scopes][1].
           This must be an empty set, or this method will return `false`.
     
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
        
        self.logger.trace("authorizing")
        
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
        .spotifyDecode(AuthInfo.self)
        .receive(on: RunLoop.main)
        .map { authInfo in
         
            self.logger.trace("received authInfo:\n\(authInfo)")
            
            if authInfo.accessToken == nil ||
                    authInfo.expirationDate == nil {
                
                self.logger.critical(
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
     
     - Parameters:
       - onlyIfExpired: Only retrieve a new access token if the current
             one is expired.
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
        
        if onlyIfExpired && !self.isExpired() {
            self.logger.trace("access token not expired; returning early")
            return Result<Void, Error>
                .Publisher(())
                .eraseToAnyPublisher()
        }
        
        self.logger.trace("access token is expired, authorizing again")
        
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

// MARK: - Testing -

extension ClientCredentialsFlowManager {
    
    /// This method sets random values for various properties
    /// for testing purposes. Do not call it outside of test cases.
    func mockValues() {
        self.expirationDate = Date()
        self.accessToken = UUID().uuidString
    }
    
}
