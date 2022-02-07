import Foundation

/**
 The authorization information that Spotify returns during the authorization
 process.

 This is used in various different contexts, including:
 
 * When decoding the response after requesting the access and refresh tokens
 * When decoding the response after refreshing the tokens
 * As a wrapper for decoding and encoding the authorization managers.
 
 Because of its diverse uses, all of its properties are optional, which means
 that it will never fail to decode itself from data, so be careful about
 swallowing errors.
 
 Includes the following properties:
 
 * ``accessToken``: used in all of the requests to the Spotify web API for
   authorization.
 * ``refreshToken``: Used to refresh the access token.
 * ``expirationDate``: The expiration date of the access token.
 * ``scopes``: The scopes that have been authorized for the access token.
 */
public struct AuthInfo: Hashable {
    
    /// The access token used in all of the requests to the Spotify web API.
    public let accessToken: String?
    
    /// Used to refresh the access token.
    public let refreshToken: String?
    
    /// The expiration date of the access token.
    public let expirationDate: Date?
    
    /// The scopes that have been authorized for the access token.
    public let scopes: Set<Scope>

    /**
     Creates an instance that holds the authorization information.

     - Parameters:
       - accessToken: The access token.
       - refreshToken: The refresh token.
       - expirationDate: The expiration date.
       - scopes: The authorization Scopes.
     */
    public init(
        accessToken: String?,
        refreshToken: String?,
        expirationDate: Date?,
        scopes: Set<Scope>
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expirationDate = expirationDate
        self.scopes = scopes
    }
    
}

extension AuthInfo: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        
        self.accessToken = try container.decodeIfPresent(
            String.self, forKey: .accessToken
        )
        
        self.refreshToken = try container.decodeIfPresent(
            String.self, forKey: .refreshToken
        )
        self.scopes = try container.decodeSpotifyScopesIfPresent(
            forKey: .scopes
        ) ?? []
        
        // If the JSON data was retrieved directly from the Spotify web API,
        // then the expiration date will be an integer representing the number
        // of seconds after the current date that the access token expires.
        if let expirationDate = try container
                .decodeDateFromExpiresInSecondsIfPresent(
            forKey: .expiresInSeconds
        ) {
            self.expirationDate = expirationDate
        }

        /*
         If the JSON data was retrieved from elsewhere, such as persistent
         storage, then the expiration date will be stored in ISO 8601 format as
         Coordinated Universal Time (UTC) with a zero offset:
         "YYYY-MM-DD'T'HH:mm:SSZ". This is how Spotify formats timestamps, so
         the expiration date is formatted this way for consistency. See
         https://developer.spotify.com/documentation/web-api/#timestamps
         */
        else {
            self.expirationDate = try container.decodeSpotifyTimestampIfPresent(
                forKey: .expirationDate
            )
        }
        
    }

    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        
        try container.encodeIfPresent(
            self.accessToken, forKey: .accessToken
        )
        try container.encodeIfPresent(
            self.refreshToken, forKey: .refreshToken
        )
        try container.encodeSpotifyScopesIfPresent(
            self.scopes, forKey: .scopes
        )
        try container.encodeSpotifyTimestampIfPresent(
            self.expirationDate, forKey: .expirationDate
        )
        
    }
    
    /// :nodoc:
    public enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expirationDate = "expiration_date"
        case expiresInSeconds = "expires_in"
        case scopes = "scope"
		case backend = "backend"
        case clientId = "client_id"
        case clientSecret = "client_secret"
    }
    
}

// MARK: - Custom String Convertible -

extension AuthInfo: CustomStringConvertible {
    
    public var description: String {
        
        let expirationDateString = expirationDate?
                .description(with: .current) ?? "nil"
        
        return """
            AuthInfo(
                access token: \(self.accessToken.quotedOrNil())
                scopes: \(self.scopes.map(\.rawValue))
                expiration date: \(expirationDateString)
                refresh token: \(self.refreshToken.quotedOrNil())
            )
            """
    }

}

// MARK: - Testing -

extension AuthInfo {
    
    /// Creates an instance with random values. Only use for tests.
    static func withRandomValues() -> Self {
        return Self(
            accessToken: UUID().uuidString,
            refreshToken: UUID().uuidString,
            expirationDate: Date(),
            scopes: Set(Scope.allCases.shuffled().prefix(5))
        )
    }
    

}

extension AuthInfo: ApproximatelyEquatable {
    
    public func isApproximatelyEqual(to other: AuthInfo) -> Bool {
        return self.accessToken == other.accessToken &&
            self.refreshToken == other.refreshToken &&
            self.scopes == other.scopes &&
            self.expirationDate.isApproximatelyEqual(to: other.expirationDate)
    }

}
