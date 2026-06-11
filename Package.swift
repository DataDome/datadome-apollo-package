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
        .package(url: "git@github.com:DataDome/mobile-package-ios-coredatadome.git", from: Version(0, 6, 0))
    ],
    targets: [
        .target(
            name: "DataDomeApollo",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "CoreDataDome", package: "mobile-package-ios-coredatadome")],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)
