import Foundation
import Combine
import Logger

/**
 An object that can manage the authorization process for the
 Spotify web API.
 
 It provides an access token, the scopes
 that have been authorized for the access token, and a method
 for refreshing the access token.
 */
public protocol SpotifyAuthorizationManager: Codable {
    
    /// The access token used in all of the requests
    /// to the Spotify web API.
    var accessToken: String? { get }
    
    /// The expiration date of the access token.
    var expirationDate: Date? { get }
    
    /// The scopes that have been authorized for the access token.
    var scopes: Set<Scope>? { get }
    
    /// A `PassthroughSubject` that emits **AFTER** the
    /// the authorization manager has changed.
    var didChange: PassthroughSubject<Void, Never> { get }
    
    /// Logs debugging messages. Don't use in shipping code.
    var logger: Logger { get }
    
    /**
     Determines whether the access token is expired
     within the given tolerance.
    
     - Parameter tolerance: The tolerance in seconds.
           The reccomended default is 60.
     - Returns: `true` if `expirationDate` + `tolerance` is
           equal to or before the current date. Else, `false`.
     */
    func isExpired(tolerance: Double) -> Bool

    /**
     Refreshes the access token.
     - Parameters:
       - onlyIfExpired: Only refresh the token if it is expired.
       - tolerance: The tolerance in seconds to use when determining
             if the token is expired. The reccomended default is 60.
     */
    func refreshTokens(
        onlyIfExpired: Bool,
        tolerance: Double
    ) -> AnyPublisher<Void, Error>

    /**
     Returns `true` if `accessToken` is not `nil` and the application
     is authorized for the specified scopes, else `false`.
     
     - Parameter scopes: A set of [Spotify Authorizaion Scopes][1].
     
     [1]: https://developer.spotify.com/documentation/general/guides/scopes/
     */
    func isAuthorized(for scopes: Set<Scope>) -> Bool
    
    
    /// Sets the credentials for the authorization manager to `nil`.
    func logout() -> Void
    
}
