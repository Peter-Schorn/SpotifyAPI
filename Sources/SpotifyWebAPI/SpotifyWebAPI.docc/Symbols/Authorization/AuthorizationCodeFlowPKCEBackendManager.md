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
