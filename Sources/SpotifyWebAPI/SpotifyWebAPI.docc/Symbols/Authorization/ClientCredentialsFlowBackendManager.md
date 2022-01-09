# ``SpotifyWebAPI/ClientCredentialsFlowBackendManager``

## Topics

### Initializers

- ``init(backend:)``
- ``init(backend:accessToken:expirationDate:)``
- ``init(from:)``

### Authorization

- ``authorize()``
- ``deauthorize()``
- ``isAuthorized(for:)``
- ``refreshTokens(onlyIfExpired:tolerance:)``
- ``accessTokenIsExpired(tolerance:)``

- ``backend``
- ``accessToken``
- ``expirationDate``
- ``scopes``

### Subscribing to Changes

- ``didChange``
- ``didDeauthorize``

### Logging

- ``logger``

### Testing

- ``setExpirationDate(to:)``
