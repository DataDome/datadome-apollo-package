// swift-tools-version:5.7
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
        .package(url: "https://github.com/apollographql/apollo-ios", from: Version(1, 0, 0)),
        .package(url: "https://github.com/DataDome/datadome-ios-package", from: Version(3, 5, 2))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DataDomeApollo",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "DataDomeSDK", package: "datadome-ios-package")],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
