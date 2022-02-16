import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import Logging

/**
 A type that can manage the authorization process for the Spotify web API.
 It also contains all the authorization information.

 It provides an access token, the scopes that have been authorized for the
 access token, and a method for refreshing the access token.

 Types that support authorization scopes should conform to
 ``SpotifyScopeAuthorizationManager``, which inherits from this protocol.

 Note that this protocol inherits from `Codable`. It is this type that you
 should encode to data using a `JSONEncoder` in order to save it to persistent
 storage. See <doc:Saving-the-Authorization-Information-to-Persistent-Storage>
 for more information.
 
 Read more at the [Spotify web API reference][1].

 [1]: https://developer.spotify.com/documentation/general/guides/authorization/
 */
public protocol SpotifyAuthorizationManager: Codable {
    
    /// The access token used in all of the requests to the Spotify web API.
    var accessToken: String? { get }
    
    /// The expiration date of the access token.
    ///
    /// You are encouraged to use ``accessTokenIsExpired(tolerance:)`` to check if
    /// the token is expired.
    var expirationDate: Date? { get }
    
    /// The scopes that have been authorized for the access token.
    var scopes: Set<Scope> { get }
    
    /**
     A publisher that emits after the authorization information has changed.
    
     See also ``didDeauthorize``, which emits after ``deauthorize()`` is called.
     */
    var didChange: PassthroughSubject<Void, Never> { get }
    
    /**
     A publisher that emits after ``deauthorize()`` is called.
     
     ``deauthorize()`` Sets the credentials for the authorization manager to
     `nil`.
     
     Subscribe to this publisher in order to remove the authorization
     information from persistent storage when it emits.
     
     See also ``didChange``.
     */
    var didDeauthorize: PassthroughSubject<Void, Never> { get }
    
    /**
     Determines whether the access token is expired within the given tolerance.
    
     - Parameter tolerance: The tolerance in seconds. The recommended default is
           120.
     - Returns: `true` if ``expirationDate`` - `tolerance` is equal to or before
           the current date or if ``accessToken`` is `nil`. Else, `false`.
     */
    func accessTokenIsExpired(tolerance: Double) -> Bool

    /**
     Refreshes the access token.

     **You shouldn't need to call this method**. It gets called automatically by
     ``SpotifyAPI`` each time you make a request to the Spotify web API.

     - Parameters:
       - onlyIfExpired: Only refresh the token if it is expired.
       - tolerance: The tolerance in seconds to use when determining if the
             token is expired. The recommended default is 120. The token is
             considered expired if ``expirationDate`` - `tolerance` is equal to or
             before the current date. This parameter has no effect if
             `onlyIfExpired` is `false`.
     */
    func refreshTokens(
        onlyIfExpired: Bool,
        tolerance: Double
    ) -> AnyPublisher<Void, Error>

    /**
     Returns `true` if ``accessToken`` is not `nil` and the application is
     authorized for the specified scopes, else `false`.
     
     - Parameter scopes: A set of [Spotify Authorization Scopes][1].
     
     [1]: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
     */
    func isAuthorized(for scopes: Set<Scope>) -> Bool
    
    /// Sets the credentials for the authorization manager to `nil`.
    ///
    /// Calling this method should cause ``didDeauthorize`` to emit a signal.
    func deauthorize() -> Void
    
    /**
     Used internally by the authorization managers in this library. If you
     create your own authorization manager, do not implement this method. A
     default implementation is provided which does nothing.
     */
    func _assertNotOnUpdateAuthInfoDispatchQueue()

}

extension SpotifyAuthorizationManager {
    
    func _assertNotOnUpdateAuthInfoDispatchQueue() { }

}
