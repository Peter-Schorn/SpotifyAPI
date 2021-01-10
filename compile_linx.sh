python3 enable_testing.py true > /dev/null

docker run --rm \
    --volume "$(pwd):/src" \
    --workdir "/src" \
    swift:latest \
    /bin/bash -c \
    "swift package clean && swift build --build-path ./.build/linux"

python3 enable_testing.py false > /dev/null
echo "finished compiling"
