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
