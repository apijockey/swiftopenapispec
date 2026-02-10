// swift-tools-version: 6.0
/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import PackageDescription

let package = Package(
    name: "SwiftOpenAPISpec",
    platforms: [.macOS(.v11)],
    products: [
        // Library-Produkt
        .library(
            name: "SwiftOpenAPISpec",
            targets: ["SwiftOpenAPISpec"]
        ),
        // CLI-Produkt
        .executable(
            name: "SwiftOpenAPICLI",
            targets: ["SwiftOpenAPICLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams", from: "5.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
        // Keine externe swift-testing Dependency mehr – Toolchain liefert 'Testing'
    ],
    targets: [
        // Library-Target
        .target(
            name: "SwiftOpenAPISpec",
            dependencies: [
                .product(name: "Yams", package: "Yams")
            ]
        ),

        // Executable-Target für die CLI
        .executableTarget(
            name: "SwiftOpenAPICLI",
            dependencies: [
                "SwiftOpenAPISpec",
                .product(name: "Yams", package: "Yams")
            ]
        ),

        // Test-Target
        .testTarget(
            name: "swiftopenapispecTests",
            dependencies: [
                "SwiftOpenAPISpec",
                "SwiftOpenAPICLI",
                .product(name: "Yams", package: "Yams")
               
            ],
            resources: [
                .copy("Resources"),
            ]
        ),
    ]
)
