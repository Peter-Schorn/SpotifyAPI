# ``SpotifyWebAPI/AuthorizationCodeFlowBackendManager``

## Topics

### Initializers

- ``init(backend:)``
- ``init(backend:accessToken:expirationDate:refreshToken:scopes:)``
- ``init(from:)``

### Authorization

- ``makeAuthorizationURL(redirectURI:showDialog:state:scopes:)``
- ``requestAccessAndRefreshTokens(redirectURIWithQuery:state:)``
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

- ``logger``
- ``AuthorizationCodeFlowManagerBase/baseLogger``
