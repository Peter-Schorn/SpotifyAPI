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

