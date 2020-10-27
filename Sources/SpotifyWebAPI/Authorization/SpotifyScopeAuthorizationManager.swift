import Foundation

/**
 A type that can manage the authorization process for the
 Spotify web API and that **supports authorization scopes**.
 
 `AuthorizationCodeFlowManager` and `AuthorizationCodeFlowPKCEManager`
 conform to this protocol. `ClientCredentialsFlowManager`
 is not a conforming type because it does not support authorization scopes.
 
 [1]: https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow-with-proof-key-for-code-exchange-pkce
 */
public protocol SpotifyScopeAuthorizationManager: SpotifyAuthorizationManager { }
