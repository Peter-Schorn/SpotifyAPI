// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "SpotifyAPI",
    platforms: [
        .iOS(.v13), 
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SpotifyAPI",
            targets: ["SpotifyWebAPI"]
        ),
        .library(
            name: "SpotifyExampleContent",
            targets: ["SpotifyExampleContent"]
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
            dependencies: spotifyAPITestUtilitiesDependencies,
            exclude: ["README.md"],
            resources: [
                .process("Resources")
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
            url: "https://github.com/Peter-Schorn/RegularExpressions.git",
            from: "2.2.0"
        ),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.4.0"
        ),
        .package(
            url: "https://github.com/OpenCombine/OpenCombine.git",
            from: "0.12.0"
        ),
        .package(
            url: "https://github.com/apple/swift-crypto.git",
            from: "3.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-docc-plugin",
            from: "1.2.0"
        )
    ]
    
    #if TEST
    dependencies += [
        .package(
            url: "https://github.com/vapor/vapor.git",
            from: "4.45.3"
        ),
        .package(
            url: "https://github.com/apple/swift-nio.git",
            from: "2.27.0"
        ),
        .package(
            url: "https://github.com/swift-server/async-http-client.git",
            from: "1.2.5"
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
