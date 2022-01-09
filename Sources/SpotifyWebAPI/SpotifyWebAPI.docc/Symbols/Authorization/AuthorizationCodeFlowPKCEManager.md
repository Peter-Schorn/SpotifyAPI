# ``SpotifyWebAPI/AuthorizationCodeFlowPKCEManager``

## Topics

### Initializers

- ``init(clientId:)``
- ``init(clientId:accessToken:expirationDate:refreshToken:scopes:)``

### Authorization

- ``AuthorizationCodeFlowPKCEBackendManager/makeAuthorizationURL(redirectURI:codeChallenge:state:scopes:)``
- ``AuthorizationCodeFlowPKCEBackendManager/requestAccessAndRefreshTokens(redirectURIWithQuery:codeVerifier:state:)``

- ``AuthorizationCodeFlowManagerBase/deauthorize()``
- ``AuthorizationCodeFlowManagerBase/isAuthorized(for:)``

- ``clientId``

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
