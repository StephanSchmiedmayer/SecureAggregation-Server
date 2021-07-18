// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SecureAggregationServer",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "../SecureAggregationCore", Package.Dependency.Requirement.branch("main")),
    ],
    targets: [
        .target(
            // Server-side implementation of Secure Aggregation using SecureAggregationCore
            name: "SecureAggregation",
            dependencies: [
                .product(name: "SecureAggregationCore", package: "SecureAggregationCore"),
            ]
        ),
        .target(
            name: "NormalAggregation"
        ),
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .target(name: "SecureAggregation"),
                .target(name: "NormalAggregation")
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
