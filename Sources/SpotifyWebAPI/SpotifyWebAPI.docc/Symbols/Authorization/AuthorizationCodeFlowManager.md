# ``SpotifyWebAPI/AuthorizationCodeFlowManager``

## Topics

### Initializers

- ``init(clientId:clientSecret:)``
- ``init(clientId:clientSecret:accessToken:expirationDate:refreshToken:scopes:)``

### Authorization

- ``AuthorizationCodeFlowBackendManager/makeAuthorizationURL(redirectURI:showDialog:state:scopes:)``
- ``AuthorizationCodeFlowBackendManager/requestAccessAndRefreshTokens(redirectURIWithQuery:state:)``

- ``AuthorizationCodeFlowManagerBase/deauthorize()``
- ``AuthorizationCodeFlowManagerBase/isAuthorized(for:)``

- ``clientId``
- ``clientSecret``

- ``AuthorizationCodeFlowManagerBase/scopes``
- ``AuthorizationCodeFlowManagerBase/accessToken``
- ``AuthorizationCodeFlowManagerBase/refreshToken``
- ``AuthorizationCodeFlowManagerBase/expirationDate``
- ``AuthorizationCodeFlowManagerBase/backend``

### Subscribing to Changes

- ``AuthorizationCodeFlowManagerBase/didChange``
- ``AuthorizationCodeFlowManagerBase/didDeauthorize``

### Logging

- ``AuthorizationCodeFlowBackendManager/logger``
- ``AuthorizationCodeFlowManagerBase/baseLogger``

