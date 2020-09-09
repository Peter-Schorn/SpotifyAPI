// swift-tools-version:5.2
// The swift-tools-version declares
// the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpotifyAPI",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SpotifyAPI",
            targets: ["SpotifyWebAPI", "SpotifyURIs"]
        ),
        .library(
            name: "_SpotifyAPITestUtilities",
            targets: ["_SpotifyAPITestUtilities"]
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
            name: "SpotifyURIs",
            dependencies: ["SpotifyWebAPI"]
        ),
        .target(
            name: "_SpotifyAPITestUtilities",
            dependencies: [
                "SpotifyWebAPI",
                "SpotifyURIs",
                "RegularExpressions",
                "Logger"
            ]
        ),
        
        // MARK: Test Targets
        
        .testTarget(
            name: "SpotifyWebAPIMainTests",
            dependencies: [
                "SpotifyWebAPI",
                "SpotifyURIs",
                "RegularExpressions",
                "_SpotifyAPITestUtilities"
            ]
        ),
        .testTarget(
            name: "SpotifyWebAPILongRunningTests",
            dependencies: [
                "SpotifyWebAPI",
                "SpotifyURIs",
                "RegularExpressions",
                "_SpotifyAPITestUtilities"
            ]
        )
    ]
)
