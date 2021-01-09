cd 'Sources/SpotifyAPITestUtilities/SpotifyAPI Utilities'

sed -r -i.bak 's/(let __clientId__ = )".*"/\1""/' 'AuthorizationConstants.swift' \
&& rm AuthorizationConstants.swift.bak

sed -r -i.bak 's/(let __clientSecret__ = )".*"/\1""/' 'AuthorizationConstants.swift' \
&& rm AuthorizationConstants.swift.bak
