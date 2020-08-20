import Foundation
import Logger


/**
 The authorization info required for the [Authorization Code Flow][1].
 
 Contains the following properties:
 
 * The access token
 * the refresh token
 * the expiration date for the access token
 * the scopes that have been authorized for the access token
 
 Use `self.isExpired(tolerance:)`
 to determine if the access token is expired.
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow
 */
public struct AuthInfo: Hashable {
    
    /// Used in all API requests to authenticate
    /// your application.
    public let accessToken: String
    
    /// Used to retrieve a new refresh token when
    /// the access token expires.
    public let refreshToken: String?
    
    /// The date the access token expires.
    /// You should normally use `self.isExpired(tolerance:)`
    /// to check if the token is expired.
    public let expirationDate: Date
    
    /// The [authorization scopes][1] that have been granted
    /// for the access token.
    ///
    /// [1]: https://developer.spotify.com/documentation/general/guides/scopes/
    public let scopes: Set<Scope>
    
    public init(
        accessToken: String,
        refreshToken: String?,
        expirationDate: Date,
        scopes: Set<Scope>
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expirationDate = expirationDate
        self.scopes = scopes
    }
    
    /// Determines whether the access token is expired
    /// within the given tolerance.
    ///
    /// - Parameter tolerance: The tolerance in seconds (default 60).
    /// - Returns: `true` if `expirationDate` + `tolerance` is
    ///       equal to or before the current date. Else, `false`.
    public func isExpired(tolerance: Double = 60) -> Bool {
        return expirationDate.addingTimeInterval(tolerance) <= Date()
    }

}

extension AuthInfo: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        let expirationDateString = expirationDate
                .description(with: .autoupdatingCurrent)
        
        return """
        AuthInfo(
            access_token: "\(accessToken)"
            scopes: \(scopes.map(\.rawValue))
            expirationDate: \(expirationDateString)
            refresh_token: "\(refreshToken ?? "nil")"
        )
        """
    }

}



extension AuthInfo: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.accessToken = try container.decode(
            String.self, forKey: .accessToken
        )
        
        // this struct is used to get the refresh and access
        // tokens after the app is authorized, and to get
        // a fresh access token using the refresh token.
        // In the latter case, the refresh token is usually nil.
        self.refreshToken = try container.decodeIfPresent(
            String.self, forKey: .refreshToken)
        
        // if the json data was retrieved directly from the spotify API,
        // then the expiration date will be an integer representing
        // the number of seconds after the current date
        // that the access token expires.
        if let expiresInSeconds = try? container.decode(
            Int.self, forKey: .expiresInSeconds
        ) {

            self.expirationDate = Date(
                timeInterval: Double(expiresInSeconds), since: Date()
            )
        }
        // if the json data was retrieved from elsewhere,
        // such as persistent storage,
        // then the expiration date will be stored in
        // ISO 8601 format as Coordinated Universal Time (UTC)
        // with a zero offset: "YYYY-MM-DD'T'HH:mm:SSZ".
        // this is how Spotify formats timestamps, so the expiration
        // date is formatted this way for consistency.
        // see https://developer.spotify.com/documentation/web-api/#timestamps
        else {
            let dateString = try container.decode(
                String.self, forKey: .expirationDate
            )
            
            if let expirationDate = DateFormatter
                    .spotifyTimeStamp.date(from: dateString) {
                self.expirationDate = expirationDate
            }
            else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [CodingKeys.expirationDate],
                        debugDescription: """
                        A date could not be parsed from the string \
                        '\(dateString)'. Expected format: \
                        'YYYY-MM-DD'T'HH:mm:SSZ'.
                        """
                    )
                )
            }
        }
        
        let scopeString = try container.decode(
            String.self, forKey: .scopes
        )
        self.scopes = Scope.makeArray(string: scopeString)
    
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        
        let expirationDateString = DateFormatter.spotifyTimeStamp
                .string(from: expirationDate)
        
        try container.encode(expirationDateString, forKey: .expirationDate)
        
        let scopeString = Scope.makeString(scopes)
        try container.encode(scopeString, forKey: .scopes)
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expirationDate = "expiration_date"
        case expiresInSeconds = "expires_in"
        case scopes = "scope"
    }


}
