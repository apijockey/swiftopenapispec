// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftOpenAPISpec",
    platforms: [.macOS(.v11)],
    products: [
        .library(name: "SwiftOpenAPISpec", targets: ["SwiftOpenAPISpec"]),
        .executable(name: "SwiftOpenAPICLI", targets: ["SwiftOpenAPICLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams", from: "5.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        // Fallback: Swift Testing als Paket für Toolchains ohne integriertes Modul
        .package(url: "https://github.com/apple/swift-testing", from: "0.10.0")
    ],
    targets: [
        .target(
            name: "SwiftOpenAPISpec",
            dependencies: [
                .product(name: "Yams", package: "Yams")
            ],
            // optional: Warnung vermeiden, wenn README in Sources liegt
            exclude: ["validator/README.md"]
        ),
        .executableTarget(
            name: "SwiftOpenAPICLI",
            dependencies: [
                "SwiftOpenAPISpec",
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .testTarget(
            name: "openapispecreaderTests",
            dependencies: [
                "SwiftOpenAPISpec",
                "SwiftOpenAPICLI",
                .product(name: "Testing", package: "swift-testing"),
                .product(name: "Yams", package: "Yams")
            ],
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)
