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

- ``scopes``
- ``accessToken``
- ``refreshToken``
- ``expirationDate``
- ``backend``

### Subscribing to Changes

- ``didChange``
- ``didDeauthorize``

### Logging

- ``logger``
- ``baseLogger``
