// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "oasis",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
         .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
         .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
         .package(url: "https://github.com/swift-server/swift-openapi-vapor", from: "1.0.0"),
         .package(url: "https://github.com/vapor/vapor", from: "4.89.0"),
     ],
    targets: [
        .executableTarget(
            name: "oasis",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "Vapor", package: "vapor"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        )
    ]
)
