# DataDomeApollo

Visit the [official documentation](https://docs.datadome.co/docs/sdk-ios-apollo).

Upgrading from a DataDomeSDK-based version (≤ 3.8.x)? See the [migration guide](MIGRATION.md).

## Choosing your Apollo iOS major (v1 or v2)

DataDomeApollo supports **both Apollo iOS v1 and v2**, selected at build time with a SwiftPM
[package trait](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0450-swiftpm-package-traits.md).
SwiftPM resolves a single Apollo version per build, so **enable the trait that matches the Apollo
major your app depends on** (a mismatch is a compile error, not a silent failure).

Requires a **Swift 6.1+ toolchain** (Xcode 16.3+), since traits are a Swift 6.1 feature.

**Apollo v1 (default — no change needed):**

```swift
.package(url: "https://github.com/DataDome/datadome-apollo-package", from: "4.1.0")
```

Setup uses `DataDomeInterceptorProvider(store:dataDome:)` (an Apollo-v1 `InterceptorProvider`).

**Apollo v2 (opt in to the `ApolloV2` trait, and pin apollo-ios to 2.x in your app):**

```swift
.package(url: "https://github.com/DataDome/datadome-apollo-package", from: "4.1.0", traits: ["ApolloV2"])
```

Setup uses `DataDomeInterceptorProvider(dataDome:)` (an Apollo-v2 `InterceptorProvider`), passed to
Apollo v2's `RequestChainNetworkTransport`. The DataDome challenge / block page is handled
automatically — no extra wiring. (In Xcode, enable the `ApolloV2` trait from the package dependency's
trait settings instead of the manifest.)
