docker run \
    --rm \
    --volume "$(pwd):/src" \
    --workdir "/src" \
    -e SPOTIFY_BACKEND_TOKEN_URL=$SPOTIFY_BACKEND_TOKEN_URL \
    -e SPOTIFY_BACKEND_TOKEN_REFRESH_URL=$SPOTIFY_BACKEND_TOKEN_REFRESH_URL \
    -e SPOTIFY_SWIFT_TESTING_CLIENT_ID=$SPOTIFY_SWIFT_TESTING_CLIENT_ID \
    -e SPOTIFY_SWIFT_TESTING_CLIENT_SECRET=$SPOTIFY_SWIFT_TESTING_CLIENT_SECRET \
    swift:latest \
    /bin/bash -c \
    "swift test --filter 'AuthorizationScopesTests|CodingAuthInfoTests|CodingAuthorizationCodeFlowManagerTests|CodingAuthorizationCodeFlowPKCEManagerTests|CodingClientCredentialsFlowManagerTests|CodingCurrentlyPlayingContextTests|CodingPlaybackRequestTests|CodingSpotifyUserTests|CodingTimeReferenceTests|CodingTrackAttributesTests|CursorPagingObjectPlayHistoryCodingTests|ExampleContentTests|SpotifyAPIClientCredentialsFlowAlbumsTests|SpotifyAPIClientCredentialsFlowArtistTests|SpotifyAPIClientCredentialsFlowBrowseTests|SpotifyAPIClientCredentialsFlowClientAuthorizationTests|SpotifyAPIClientCredentialsFlowEpisodeTests|SpotifyAPIClientCredentialsFlowErrorTests|SpotifyAPIClientCredentialsFlowFollowTests|SpotifyAPIClientCredentialsFlowProxyFollowTests|SpotifyAPIClientCredentialsFlowInsufficientScopeTests|SpotifyAPIClientCredentialsFlowMarketTests|SpotifyAPIClientCredentialsFlowPlaylistsTests|SpotifyAPIClientCredentialsFlowProxyArtistTests|SpotifyAPIClientCredentialsFlowProxyAuthorizationTests|SpotifyAPIClientCredentialsFlowProxyInsufficientScopeTests|SpotifyAPIClientCredentialsFlowProxyRefreshTokensConcurrentTests|SpotifyAPIClientCredentialsFlowRefreshTokensConcurrentTests|SpotifyAPIClientCredentialsFlowSearchTests|SpotifyAPIClientCredentialsFlowShowTests|SpotifyAPIClientCredentialsFlowTrackTests|SpotifyAPIClientCredentialsFlowUserProfileTests|SpotifyIdentifierTests|SpotifyPlayerErrorCodingTests'"

echo "finished compiling"

# interactive:
#
# docker run \
#     --rm \
#     --volume "$(pwd):/src" \
#     --workdir "/src" \
#     -it \
#     -e SPOTIFY_DATA_DUMP_FOLDER="/logs" \
#     -e SPOTIFY_BACKEND_TOKEN_URL=$SPOTIFY_BACKEND_TOKEN_URL \
#     -e SPOTIFY_BACKEND_TOKEN_REFRESH_URL=$SPOTIFY_BACKEND_TOKEN_REFRESH_URL \
#     -e SPOTIFY_SWIFT_TESTING_CLIENT_ID=$SPOTIFY_SWIFT_TESTING_CLIENT_ID \
#     -e SPOTIFY_SWIFT_TESTING_CLIENT_SECRET=$SPOTIFY_SWIFT_TESTING_CLIENT_SECRET \
#     swift:latest
