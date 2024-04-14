swift package --allow-writing-to-package-directory \
    generate-documentation \
    --target SpotifyWebAPI \
    --include-extended-types \
    --output-path 'docs' \
    --transform-for-static-hosting \
    --hosting-base-path SpotifyAPI
