# DataDomeApollo

Visit the [official documentation](https://docs.datadome.co/docs/sdk-ios-apollo).

Upgrading from a DataDomeSDK-based version (≤ 3.8.x)? See the [migration guide](MIGRATION.md).

## Requirements

- **iOS 15.0+** — the package's minimum deployment target.
- **Xcode 26.4+** — the first version to support Swift Package Manager traits (required to select the Apollo major; see [Choosing your Apollo iOS major](#choosing-your-apollo-ios-major-v1-or-v2)).
- **Swift Package Manager** — the supported integration method.
- **Apollo iOS v1 (1.x) _or_ v2 (2.x)** — pick one and enable the matching trait (`ApolloV1` is enabled by default).
- A **DataDome client-side key** — set in your app's Info.plist under the `DataDome` dictionary (`ClientSideKey`).

## Choosing your Apollo iOS major (v1 or v2)

DataDomeApollo supports **both Apollo iOS v1 and v2**, selected at build time with a SwiftPM
[package trait](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0450-swiftpm-package-traits.md).
SwiftPM resolves a single Apollo version per build, so **enable the trait that matches the Apollo
major your app depends on** (a mismatch is a compile error, not a silent failure).

**Apollo v1 (default — no change needed):**

```swift
.package(url: "https://github.com/DataDome/datadome-apollo-package", from: "4.0.0")
```

Setup uses `DataDomeInterceptorProvider(store:dataDome:)` (an Apollo-v1 `InterceptorProvider`).

**Apollo v2 (opt in to the `ApolloV2` trait, and pin apollo-ios to 2.x in your app):**

```swift
.package(url: "https://github.com/DataDome/datadome-apollo-package", from: "4.0.0", traits: ["ApolloV2"])
```

Setup wraps your session in `DataDomeURLSession(dataDome:)` (an Apollo-v2 `ApolloURLSession`) and
passes it to Apollo v2's `RequestChainNetworkTransport` — DataDome validates every response at the
network layer, so a challenge is handled (and the request retried once the user resolves it) for any
status code, including `2xx`:

```swift
let transport = RequestChainNetworkTransport(
    urlSession: DataDomeURLSession(dataDome: dataDome),
    interceptorProvider: DefaultInterceptorProvider.shared,
    store: store,
    endpointURL: endpoint
)
let client = ApolloClient(networkTransport: transport, store: store)
```

The DataDome challenge / block page is presented automatically, and challenge retries are driven by
the user (not bounded by Apollo's `MaxRetryInterceptor`). (In Xcode, enable the `ApolloV2` trait from
the package dependency's trait settings instead of the manifest.)
