// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEFramework",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "MEFramework", targets: ["MECache", "MENetworking", /*"MERemoteImage",*/ "MECore"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "MECache", dependencies: ["MECore"]),
        .target(name: "MENetworking", dependencies: ["MECore"]),
//        .target(name: "MERemoteImage", dependencies: ["MECore"]),
        .target(name: "MECore", dependencies: []),

        .testTarget(name: "MECacheTests", dependencies: ["MECache"]),
        .testTarget(name: "MENetworkingTests", dependencies: ["MENetworking"]),
//        .testTarget(name: "MERemoteImageTests", dependencies: ["MERemoteImage"]),
        .testTarget(name: "MECoreTests", dependencies: ["MECore"])
    ]
)
