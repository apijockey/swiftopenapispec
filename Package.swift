// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "openapispecreader",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "openapispecreader",
            targets: ["openapispecreader"]),
    ],
    dependencies: [
            .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
            .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
            .package(url: "https://github.com/jpsim/Yams", from: "5.1.0"),
          
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "openapispecreader",
            dependencies: [
               .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),  
                .product(name: "Yams", package: "Yams"),]
        ),
        .testTarget(
            name: "openapispecreaderTests",
            dependencies: ["openapispecreader"],
            resources: [
                .copy("openapi.yaml"),
                ]),
    ]
)
