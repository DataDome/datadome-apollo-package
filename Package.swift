// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "DataDomeApollo",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "DataDomeApollo",
            targets: ["DataDomeApollo"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios", from: Version(1, 0, 0)),
        .package(url: "https://github.com/DataDome/datadome-ios-package", from: Version(3, 8, 0))
    ],
    targets: [
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
