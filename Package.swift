// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataDomeApollo",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DataDomeApollo",
            targets: ["DataDomeApollo"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Apollo", url: "https://github.com/apollographql/apollo-ios", from: "0.19.1"),
        .package(name: "DataDomeSDK", url: "https://github.com/DataDome/datadome-ios-package", from: "3.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DataDomeApollo",
            dependencies: ["Apollo", "DataDomeSDK"],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
