import Foundation

/**
 The authorization info that Spotify returns during the authorization
 process.

 This is used in various different contexts, including:
 
 * When decoding the respose after requesting the access and refresh tokens
 * When decoding the response after refreshing the tokens
 * As a wrapper for decoding and encoding the authorization information.
 
 Because of its diverse uses, all of its properties are optional,
 which means that it will never fail to decode itself from data,
 so be careful about swallowing errors.
 
 Includes the following properties:
 
 * `accessToken`: used in all of the requests to the Spotify web API
   for authorization.
 * `refreshToken`: Used to refresh the access token.
 * `expirationDate`: The expiration date of the access token.
 * `scopes`: The scopes that have been authorized for the access token.
 
 */
struct AuthInfo: Hashable {
    
    /// The access token used in all of the requests
    /// to the Spotify web API.
    let accessToken: String?
    
    /// Used to refresh the access token.
    let refreshToken: String?
    
    /// The expiration date of the access token.
    let expirationDate: Date?
    
    /// The scopes that have been authorized for the access token.
    let scopes: Set<Scope>?

    init(
        accessToken: String?,
        refreshToken: String?,
        expirationDate: Date?,
        scopes: Set<Scope>?
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expirationDate = expirationDate
        self.scopes = scopes
    }
    
}

extension AuthInfo: Codable {
    
    init(from decoder: Decoder) throws {
        
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
        )
        
        // If the json data was retrieved directly from the Spotify API,
        // then the expiration date will be an integer representing
        // the number of seconds after the current date
        // that the access token expires.
        if let expirationDate = try container
                .decodeDateFromExpiresInSecondsIfPresent(
            forKey: .expiresInSeconds
        ) {
            self.expirationDate = expirationDate
        }

        /*
         If the json data was retrieved from elsewhere,
         such as persistent storage, then the expiration date
         will be stored in ISO 8601 format as
         Coordinated Universal Time (UTC) with a zero offset:
         "YYYY-MM-DD'T'HH:mm:SSZ". this is how Spotify formats timestamps,
         so the expiration date is formatted this way for consistency.
         see https://developer.spotify.com/documentation/web-api/#timestamps
         */
        else {
            self.expirationDate = try container.decodeSpotifyTimestampIfPresent(
                forKey: .expirationDate
            )
        }
        
    }

    func encode(to encoder: Encoder) throws {
        
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
            scopes, forKey: .scopes
        )
        try container.encodeSpotifyTimestampIfPresent(
            expirationDate, forKey: .expirationDate
        )
        
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expirationDate = "expiration_date"
        case expiresInSeconds = "expires_in"
        case scopes = "scope"
		case endpoint = "endpoint"
        case clientId = "client_id"
        case clientSecret = "client_secret"
    }
    
}

// MARK: - Custom String Convertible -

extension AuthInfo: CustomStringConvertible {
    
    var description: String {
        
        let expirationDateString = expirationDate?
                .description(with: .autoupdatingCurrent)
                ?? "nil"
        
        var scopeString = "nil"
        if let scopes = scopes {
            scopeString = "\(scopes.map(\.rawValue))"
        }
        
        return """
            AuthInfo(
                access token: "\(accessToken ?? "nil")"
                scopes: \(scopeString)
                expiration date: \(expirationDateString)
                refresh token: "\(refreshToken ?? "nil")"
            )
            """
    }

}

// MARK: - Testing -

extension AuthInfo {
    
    /// Creates an instance with random values.
    /// Only use for tests.
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
    
    func isApproximatelyEqual(to other: AuthInfo) -> Bool {
        return self.accessToken == other.accessToken &&
            self.refreshToken == other.refreshToken &&
            self.scopes == other.scopes &&
            self.expirationDate.isApproximatelyEqual(to: other.expirationDate)
    }

}
