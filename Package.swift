// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SpotifyAPI",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SpotifyAPI",
            targets: ["SpotifyWebAPI", "SpotifyExampleContent"]
        ),
        .library(
            name: "_SpotifyAPITestUtilities",
            targets: ["SpotifyAPITestUtilities"]
        )
    ],
    dependencies: [
        .package(
            name: "RegularExpressions",
            url: "https://github.com/Peter-Schorn/RegularExpressions.git",
            "2.0.7"..<"3.0.0"
        ),
        .package(
            name: "swift-log",
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.0"
        ),
        .package(
            name: "OpenCombine",
            url: "https://github.com/OpenCombine/OpenCombine.git",
            from: "0.11.0"
        ),
        .package(
            name: "swift-crypto",
            url: "https://github.com/apple/swift-crypto.git",
            from: "1.1.3"
        )
    ],
    targets: [
        .target(
            name: "SpotifyWebAPI",
            dependencies: [
                "RegularExpressions",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "OpenCombine", package: "OpenCombine"),
                .product(name: "OpenCombineDispatch", package: "OpenCombine"),
                .product(name: "OpenCombineFoundation", package: "OpenCombine")
            ],
            exclude: ["README.md"]
        ),
        .target(
            name: "SpotifyExampleContent",
            dependencies: ["SpotifyWebAPI"],
            exclude: ["README.md"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "SpotifyAPITestUtilities",
            dependencies: [
                "SpotifyWebAPI",
                "SpotifyExampleContent",
                "RegularExpressions",
                .product(name: "OpenCombine", package: "OpenCombine"),
                .product(name: "OpenCombineDispatch", package: "OpenCombine"),
                .product(name: "OpenCombineFoundation", package: "OpenCombine")
            ],
            exclude: ["README.md"]
        ),
        
        // MARK: Test Targets
        
        .testTarget(
            name: "SpotifyWebAPIMainTests",
            dependencies: [
                "SpotifyWebAPI",
                "SpotifyExampleContent",
                "RegularExpressions",
                "SpotifyAPITestUtilities"
            ]
        )
    ]
)
