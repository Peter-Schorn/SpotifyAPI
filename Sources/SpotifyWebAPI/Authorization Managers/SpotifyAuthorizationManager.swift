import Foundation
import Combine

/**
 An object that can manage the authorization process for the
 Spotify web API. It provides an access token, the scopes
 that have been authorized for the access token, and a method
 for refreshing the access token.
 
 */
public protocol SpotifyAuthorizationManager: Codable, ObservableObject {
    
    /// The access token used in all of the requests
    /// to the Spotify web API
    var accessToken: String? { get }
    
    /// The expiration date of the access token
    var expirationDate: Date? { get }
    
    /// The scopes that have been authorized for the access token.
    var scopes: Set<Scope>? { get }
    
    /**
     Determines whether the access token is expired
     within the given tolerance.
    
     - Parameter tolerance: The tolerance in seconds.
     - Returns: `true` if `expirationDate` + `tolerance` is
           equal to or before the current date. Else, `false`.
     */
    func isExpired(tolerance: Double) -> Bool
    
    func refreshTokens(
        onlyIfExpired: Bool,
        tolerance: Double
    ) -> AnyPublisher<Void, Error>

    /// Returns `true` if the application is authorized for the
    /// specified scopes, else  `false`.
    func isAuthorized(for scopes: Set<Scope>) -> Bool
    
}



