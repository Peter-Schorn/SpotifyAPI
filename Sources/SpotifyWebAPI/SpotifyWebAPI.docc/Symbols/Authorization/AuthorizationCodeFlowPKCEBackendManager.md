# ``SpotifyWebAPI/AuthorizationCodeFlowPKCEBackendManager``

## Topics

### Initializers

- ``init(backend:)``
- ``init(backend:accessToken:expirationDate:refreshToken:scopes:)``
- ``init(from:)``

### Authorization

- ``makeAuthorizationURL(redirectURI:codeChallenge:state:scopes:)``
- ``requestAccessAndRefreshTokens(redirectURIWithQuery:codeVerifier:state:)``
- ``refreshTokens(onlyIfExpired:tolerance:)``

- ``AuthorizationCodeFlowManagerBase/deauthorize()``
- ``AuthorizationCodeFlowManagerBase/isAuthorized(for:)``

- ``AuthorizationCodeFlowManagerBase/scopes``
- ``AuthorizationCodeFlowManagerBase/accessToken``
- ``AuthorizationCodeFlowManagerBase/refreshToken``
- ``AuthorizationCodeFlowManagerBase/expirationDate``
- ``AuthorizationCodeFlowManagerBase/backend``

### Subscribing to Changes

- ``AuthorizationCodeFlowManagerBase/didChange``
- ``AuthorizationCodeFlowManagerBase/didDeauthorize``

### Logging

- ``AuthorizationCodeFlowPKCEBackendManager/logger``
- ``AuthorizationCodeFlowManagerBase/baseLogger``
