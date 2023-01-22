// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MENetworking",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "MENetworking", targets: ["MENetworking"]),
        .library(name: "MENetworkingTestingUtils", targets: ["MENetworkingTestingUtils"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "MENetworking", dependencies: []),
        .target(name: "MENetworkingTestingUtils", dependencies: ["MENetworking"]),
        .testTarget(name: "MENetworkingTests", dependencies: ["MENetworking"]),
    ]
)
