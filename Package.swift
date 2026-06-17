// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "DataDomeApollo",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "DataDomeApollo",
            targets: ["DataDomeApollo"]
        ),
    ],
    traits: [
        "ApolloV1",
        "ApolloV2",
        // Default to Apollo iOS v1 so existing integrators need no change.
        .default(enabledTraits: ["ApolloV1"]),
    ],
    dependencies: [
        // One apollo-ios identity spanning both majors. SwiftPM resolves a single version per build;
        // enable the trait (ApolloV1 / ApolloV2) matching the Apollo major your app pins.
        .package(url: "https://github.com/apollographql/apollo-ios", "1.0.0"..<"3.0.0"),
        .package(url: "git@github.com:DataDome/mobile-package-ios-coredatadome.git", branch: "0.6.1")
    ],
    targets: [
        .target(
            name: "DataDomeApollo",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "ApolloAPI", package: "apollo-ios"),
                .product(name: "CoreDataDome", package: "mobile-package-ios-coredatadome"),
            ],
            path: "Sources"
        )
    ],
    swiftLanguageModes: [.v5]
)
