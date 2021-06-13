# ``SpotifyWebAPI/AuthorizationCodeFlowPKCEBackendManager``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}


## Topics

### Initializers

- ``init(backend:)``
- ``init(backend:accessToken:expirationDate:refreshToken:scopes:)``
- ``init(from:)``

### Authorization

### ``makeAuthorizationURL(redirectURI:codeChallenge:state:scopes:)``
### ``requestAccessAndRefreshTokens(redirectURIWithQuery:codeVerifier:state:)``
### ``refreshTokens(onlyIfExpired:tolerance:)``
### ``AuthorizationCodeFlowManagerBase/accessTokenIsExpired(tolerance:)``
