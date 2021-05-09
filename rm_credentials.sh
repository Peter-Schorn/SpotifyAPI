cd 'Sources/SpotifyAPITestUtilities/SpotifyAPI Utilities'

sed -E -i.bak 's/(let __clientId__ = )".*"/\1""/' 'AuthorizationConstants.swift' \
&& rm AuthorizationConstants.swift.bak

sed -E -i.bak 's/(let __clientSecret__ = )".*"/\1""/' 'AuthorizationConstants.swift' \
&& rm AuthorizationConstants.swift.bak

sed -E -i.bak 's/(let __clientCredentialsFlowTokensURL__ = )".*"/\1""/' 'AuthorizationConstants.swift' \
&& rm AuthorizationConstants.swift.bak
