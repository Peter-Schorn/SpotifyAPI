# ``SpotifyWebAPI/ClientCredentialsFlowManager``

## Topics

### Initializers

- ``init(clientId:clientSecret:)``
- ``init(clientId:clientSecret:accessToken:expirationDate:)``

### Authorization

- ``ClientCredentialsFlowBackendManager/authorize()``
- ``ClientCredentialsFlowBackendManager/deauthorize()``
- ``ClientCredentialsFlowBackendManager/isAuthorized(for:)``

- ``clientId``
- ``clientSecret``
- ``ClientCredentialsFlowBackendManager/accessToken``
- ``ClientCredentialsFlowBackendManager/expirationDate``
- ``ClientCredentialsFlowBackendManager/scopes``

### Subscribing to Changes

- ``ClientCredentialsFlowBackendManager/didChange``
- ``ClientCredentialsFlowBackendManager/didDeauthorize``

### Logging

- ``ClientCredentialsFlowBackendManager/logger``
