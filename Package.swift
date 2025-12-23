// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftOpenAPISpec",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftOpenAPISpec",
            targets: ["SwiftOpenAPISpec"]),
    ],
    dependencies: [
            .package(url: "https://github.com/jpsim/Yams", from: "5.1.0"),
            .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
          
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftOpenAPISpec",
            dependencies: [
                .product(name: "Yams", package: "Yams")]
                
        ),
        .testTarget(
            name: "openapispecreaderTests",
            dependencies: ["SwiftOpenAPISpec"],
            resources: [
                .process("Resources"),
                ]),
    ]
)
