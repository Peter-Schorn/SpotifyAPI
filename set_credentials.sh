cd 'Sources/SpotifyAPITestUtilities/SpotifyAPI Utilities'

sed -E -i.bak "s~(let __clientId__ = )\".*\"~\1\"$SPOTIFY_SWIFT_TESTING_CLIENT_ID\"~" 'AuthorizationConstants.swift' \
&& rm AuthorizationConstants.swift.bak

sed -E -i.bak "s~(let __clientSecret__ = )\".*\"~\1\"$SPOTIFY_SWIFT_TESTING_CLIENT_SECRET\"~" 'AuthorizationConstants.swift' \
&& rm AuthorizationConstants.swift.bak

sed -E -i.bak "s~(let __clientCredentialsFlowTokensURL__ = )\".*\"~\1\"$SPOTIFY_CLIENT_CREDENTIALS_FLOW_TOKENS_URL\"~" 'AuthorizationConstants.swift' \
&& rm AuthorizationConstants.swift.bak
