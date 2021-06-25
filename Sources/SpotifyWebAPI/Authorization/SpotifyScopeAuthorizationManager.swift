import Foundation

/**
 A type that can manage the authorization process for the Spotify web API and
 that **supports authorization scopes**.

 ``AuthorizationCodeFlowBackendManager`` and
 ``AuthorizationCodeFlowPKCEBackendManager`` conform to this protocol.
 ``ClientCredentialsFlowBackendManager`` is not a conforming type because it
 does not support authorization scopes.
 */
public protocol SpotifyScopeAuthorizationManager: SpotifyAuthorizationManager { }
