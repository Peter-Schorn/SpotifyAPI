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
    
    /// Set to true to print debugging info to the console.
    public static var printDebugingOutput = false
    
    public var accessToken: String
    public var refreshToken: String?
    public var expirationDate: Date
    public var scopes: Set<Scope>
    
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
    
    mutating func updateAfterRefresh(to: Self) {
        
    }
    
    
    /// Determines whether the access token is expired
    /// within the given tolerance.
    ///
    /// - Parameter tolerance: The tolerance in seconds (default 60).
    /// - Returns: `true` if the expirationDate + `tolerance` is
    ///       equal to or before the current date. Else, `false`.
    public func isExpired(tolerance: Double = 60) -> Bool {
        
        let isExpired = expirationDate.addingTimeInterval(tolerance) <= Date()
        print(
            """

            AuthInfo.isExpired: \(isExpired)
            expiration date: \(expirationDate.localDescription)
            current date: \(Date().localDescription)

            """
        )
        return isExpired
    }

}

extension AuthInfo: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return """
        AuthInfo(
            access_token: "\(accessToken)"
            scopes: \(scopes.map(\.rawValue))
            expirationDate: \(expirationDate.localDescription)
            refresh_token: "\(refreshToken ?? "nil")"
        )
        """
    }

}



extension AuthInfo: CustomCodable {
    
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
        // then the expiration date will be stored as a floating
        // point value representing the number of seconds since
        // the references date (00:00:00 UTC on 1 January 2001),
        // which is the default for decoding dates.
        else {
            self.expirationDate = try container.decode(
                Date.self, forKey: .expirationDate
            )
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
        try container.encode(expirationDate, forKey: .expirationDate)
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
