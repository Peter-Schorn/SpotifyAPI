// swift-tools-version:5.2

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
            name: "Logger",
            url: "https://github.com/Peter-Schorn/Logger.git",
            "1.0.0"..<"2.0.0"
        )
    ],
    targets: [
        .target(
            name: "SpotifyWebAPI",
            dependencies: ["RegularExpressions", "Logger"]
        ),
        .target(
            name: "SpotifyExampleContent",
            dependencies: ["SpotifyWebAPI"]
        ),
        .target(
            name: "SpotifyAPITestUtilities",
            dependencies: [
                "SpotifyWebAPI",
                "SpotifyExampleContent",
                "RegularExpressions",
                "Logger"
            ]
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
        ),
        .testTarget(
            name: "SpotifyWebAPILongRunningTests",
            dependencies: [
                "SpotifyWebAPI",
                "SpotifyExampleContent",
                "RegularExpressions",
                "SpotifyAPITestUtilities"
            ]
        )
    ]
)
