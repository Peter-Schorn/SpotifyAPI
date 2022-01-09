# ``SpotifyWebAPI/ClientCredentialsFlowManager``

## Topics

### Initializers

- ``init(clientId:clientSecret:)``
- ``init(clientId:clientSecret:accessToken:expirationDate:)``
- ``init(backend:accessToken:expirationDate:)``

### Authorization

- ``ClientCredentialsFlowBackendManager/authorize()``
- ``ClientCredentialsFlowBackendManager/deauthorize()``
- ``ClientCredentialsFlowBackendManager/isAuthorized(for:)``

- ``clientId``
- ``clientSecret``
- ``accessToken``
- ``expirationDate``
- ``scopes``
- ``backend``

### Subscribing to Changes

- ``didChange``
- ``didDeauthorize``

### Logging

- ``logger``
