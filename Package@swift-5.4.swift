// swift-tools-version:5.4

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
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "SpotifyWebAPI",
            dependencies: [
                .product(name: "RegularExpressions", package: "RegularExpressions"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "OpenCombine", package: "OpenCombine"),
                .product(name: "OpenCombineDispatch", package: "OpenCombine"),
                .product(name: "OpenCombineFoundation", package: "OpenCombine")
            ],
            exclude: [
                "README.md",
                "SpotifyWebAPI.docc"
            ]
        ),
        .target(
            name: "SpotifyExampleContent",
            dependencies: ["SpotifyWebAPI"],
            exclude: [
                "README.md",
                "SpotifyExampleContent.docc"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "SpotifyAPITestUtilities",
            dependencies: spotifyAPITestUtilitiesDependencies,
            exclude: [
                "README.md",
                "SpotifyAPITestUtilities.docc"
            ]
        ),
        
        // MARK: Test Targets
        
        .testTarget(
            name: "SpotifyAPIMainTests",
            dependencies: [
                "SpotifyWebAPI",
                "SpotifyExampleContent",
                "RegularExpressions",
                "SpotifyAPITestUtilities"
            ]
        )
        
    ]
)

var packageDependencies: [Package.Dependency] {
    
    var dependencies: [Package.Dependency] = [
        .package(
            name: "RegularExpressions",
            url: "https://github.com/Peter-Schorn/RegularExpressions.git",
            from: "2.2.0"
        ),
        .package(
            name: "swift-log",
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.0"
        ),
        .package(
            name: "OpenCombine",
            url: "https://github.com/OpenCombine/OpenCombine.git",
            from: "0.12.0"
        ),
        .package(
            name: "swift-crypto",
            url: "https://github.com/apple/swift-crypto.git",
            "1.1.3"..<"2.2.0"
        )
    ]
    
    #if TEST
    dependencies += [
        .package(
            name: "vapor",
            url: "https://github.com/vapor/vapor.git",
            from: "4.45.3"
        ),
        .package(
            name: "swift-nio",
            url: "https://github.com/apple/swift-nio.git",
            "2.27.0"..<"2.43.0"
        ),
        .package(
            name: "async-http-client",
            url: "https://github.com/swift-server/async-http-client.git",
            "1.2.5"..<"1.13.0"
        )
    ]
    #endif

    return dependencies
}

var spotifyAPITestUtilitiesDependencies: [Target.Dependency] {
    
    var dependencies: [Target.Dependency] = [
        "SpotifyWebAPI",
        "SpotifyExampleContent",
        .product(name: "RegularExpressions", package: "RegularExpressions"),
        .product(name: "OpenCombine", package: "OpenCombine"),
        .product(name: "OpenCombineDispatch", package: "OpenCombine"),
        .product(name: "OpenCombineFoundation", package: "OpenCombine")
    ]
    
    #if TEST
    dependencies += [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "NIOHTTP1", package: "swift-nio"),
        .product(name: "NIO", package: "swift-nio"),
        .product(name: "AsyncHTTPClient", package: "async-http-client")
    ]
    #endif
    
    return dependencies

}
