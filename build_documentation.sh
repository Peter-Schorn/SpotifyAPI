swift package --allow-writing-to-package-directory \
    generate-documentation \
    --target SpotifyWebAPI \
    --output-path 'docs' \
    --transform-for-static-hosting \
    --hosting-base-path SpotifyAPI
