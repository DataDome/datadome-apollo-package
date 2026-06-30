# Migrating to DataDomeApollo 4.0.0 (CoreDataDome)

DataDomeApollo **4.0.0** replaces the legacy **DataDomeSDK** dependency with the new modular
**CoreDataDome** SDK. This is a breaking release: response validation now runs through CoreDataDome's
`DataDome` instance, and the challenge / blocked page is presented by the SDK itself. This guide
covers upgrading an existing integration from 3.8.x or earlier.

## Requirements

- **iOS 15.0+** (raised from iOS 12).
- See the [README requirements](README.md#requirements) for the toolchain (Xcode version) and Swift
  Package Manager setup.
- DataDomeSDK integrations run on **Apollo iOS v1**, which is the default (`ApolloV1`) trait, so the
  steps below apply as-is. On Apollo v2 the integration point is different — DataDome plugs in at the
  transport (`DataDomeURLSession`) rather than via an interceptor provider; see
  [Apollo v2](#apollo-v2) below and
  [Choosing your Apollo iOS major](README.md#choosing-your-apollo-ios-major-v1-or-v2).

## At a glance

| Area | Before (≤ 3.8.x · DataDomeSDK) | After (4.0.0 · CoreDataDome) |
|---|---|---|
| Import | `import DataDomeSDK` | `import CoreDataDome` |
| Client key (Info.plist) | `DataDomeKey` (String) | `DataDome` → `ClientSideKey` (String) |
| SDK instance | implicit (auto-init from plist) | explicit `DataDome(configuration:)` you create & inject |
| URLSession client | `DataDomeURLSessionClient()` | `URLSessionClient()` (or omit — defaulted) |
| Interceptor provider | `DataDomeInterceptorProvider(store:client:)` | `DataDomeInterceptorProvider(store:dataDome:)` |
| Challenge / captcha UI | implement `CaptchaDelegate` + pass `ProtectedRequestContext` | handled automatically — nothing to wire up |
| Min iOS | 12.0 | 15.0 |

> This table covers the **Apollo v1** integration (the default `ApolloV1` trait). On **Apollo v2**,
> DataDome is wired in at the transport instead of via an interceptor provider — see [Apollo v2](#apollo-v2).

## 1. Update the package & deployment target

Bump DataDomeApollo to **4.0.0** and raise your app's minimum deployment target to **iOS 15.0**.

## 2. Move your client-side key in Info.plist

Replace the flat `DataDomeKey` string with a `DataDome` dictionary:

```xml
<!-- Before -->
<key>DataDomeKey</key>
<string>YOUR_CLIENT_SIDE_KEY</string>

<!-- After -->
<key>DataDome</key>
<dict>
    <key>ClientSideKey</key>
    <string>YOUR_CLIENT_SIDE_KEY</string>
    <!-- Optional: <key>Domain</key><string>https://your-domain.com</string> -->
</dict>
```

## 3. Create a `DataDome` instance and inject it

CoreDataDome is configured explicitly. Build a `DataDome` once and pass it to the interceptor provider.

```swift
// Before
import Apollo
import DataDomeApollo
import DataDomeSDK

let store = ApolloStore(cache: InMemoryNormalizedCache())
let client = DataDomeURLSessionClient()
let provider = DataDomeInterceptorProvider(store: store, client: client)
let transport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: endpointURL)
let apollo = ApolloClient(networkTransport: transport, store: store)
```

```swift
// After
import Apollo
import DataDomeApollo
import CoreDataDome

let store = ApolloStore(cache: InMemoryNormalizedCache())

// Reads ClientSideKey from the Info.plist `DataDome` dict…
let dataDome = DataDome(configuration: try DataDomeConfiguration.configurationFromBundle())
// …or configure programmatically:
// let dataDome = DataDome(configuration: DataDomeConfiguration(clientKey: "YOUR_CLIENT_SIDE_KEY"))

let provider = DataDomeInterceptorProvider(store: store, dataDome: dataDome)
let transport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: endpointURL)
let apollo = ApolloClient(networkTransport: transport, store: store)
```

> `DataDomeConfiguration.configurationFromBundle()` throws if the `DataDome` / `ClientSideKey`
> Info.plist entry is missing — handle the error or use the programmatic initializer.
> `import CoreDataDome` resolves transitively through DataDomeApollo; if your build can't find it,
> add the `CoreDataDome` product to your target.

## 4. Remove `DataDomeURLSessionClient`

It has been removed. Use Apollo's stock `URLSessionClient`, or omit it (the provider defaults it):

```swift
let provider = DataDomeInterceptorProvider(store: store, dataDome: dataDome)
// or, to customize the session:
let provider = DataDomeInterceptorProvider(client: URLSessionClient(), store: store, dataDome: dataDome)
```

> Previously `DataDomeURLSessionClient` injected a `User-Agent` from the `DATADOME_USER_AGENT`
> environment variable for testing only — it had no role in protection and is gone.

## 5. Remove captcha-delegate code

The challenge / blocked page is now presented by CoreDataDome itself. Delete your `CaptchaDelegate`
conformance and any `ProtectedRequestContext` you passed to `fetch(...)`.

```swift
// Before
extension MyViewModel: CaptchaDelegate {
    func present(captchaController controller: UIViewController) { /* present */ }
    func dismiss(captchaController controller: UIViewController) { /* dismiss */ }
}
apollo.fetch(query: MyQuery(),
             context: ProtectedRequestContext(responsePageDelegate: self)) { result in ... }

// After
apollo.fetch(query: MyQuery()) { result in ... }
```

> `DataDomeRequestContext` and `ProtectedRequestContext` still exist but are **deprecated no-ops**
> kept only for source compatibility; remove them at your convenience.

## 6. Remove or rename other symbols

- **`DataDomeResponseInterceptor`** → renamed to **`DataDomeInterceptor`** (only relevant if you used the
  interceptor type directly rather than via `DataDomeInterceptorProvider`).
- **`ApolloCompletion`** — removed (was an internal helper exposed publicly).
- **`EventTracker` / `.apollo` integration logging** — removed; there is no equivalent in CoreDataDome.

## Apollo v2

If your app uses **Apollo iOS v2** (enable the `ApolloV2` trait), DataDome integrates at the transport
rather than via an interceptor provider. Wrap your session in `DataDomeURLSession` and pass it to
`RequestChainNetworkTransport`:

```swift
import Apollo
import DataDomeApollo
import CoreDataDome

let store = ApolloStore(cache: InMemoryNormalizedCache())
let dataDome = DataDome(configuration: DataDomeConfiguration(clientKey: "YOUR_CLIENT_SIDE_KEY"))

let transport = RequestChainNetworkTransport(
    urlSession: DataDomeURLSession(dataDome: dataDome),
    interceptorProvider: DefaultInterceptorProvider.shared,   // your own / Apollo's default
    store: store,
    endpointURL: endpoint
)
let apollo = ApolloClient(networkTransport: transport, store: store)
```

DataDome validates **every** response at the network layer — so a challenge is handled for any status
code, including `2xx` — and presents the challenge / block page itself. There is no DataDome interceptor
to register, and the rest of your interceptor chain (including your own interceptors) is untouched.

## Behavioral changes

- **Challenge presentation** is owned by the SDK (shown in its own window); presentation is not
  customizable in this release.
- **Cookies**: the DataDome cookie is stored in the shared `HTTPCookieStorage` and attached to
  subsequent requests automatically. Keep your Apollo `URLSessionClient` on the default configuration
  (the default) so the cookie is sent on retry.
- **Retries**:
  - **Apollo v1** — a resolved challenge retries the operation through Apollo's chain, capped by
    `MaxRetryInterceptor` (3 retries).
  - **Apollo v2** — validation and retry happen at the transport (`DataDomeURLSession`): a resolved
    challenge re-issues the request directly, so retries are **user-driven and not bounded** by
    `MaxRetryInterceptor`.

## Troubleshooting

- *`configurationFromBundle()` throws / crash on launch* → the `DataDome` dict or `ClientSideKey` is
  missing from Info.plist (step 2), or use the programmatic initializer.
- *`Cannot find type 'CaptchaDelegate' / 'DataDomeURLSessionClient' / 'ApolloCompletion'`* → these were
  removed; see steps 4–6.
- *`No such module 'CoreDataDome'`* → add the CoreDataDome package product to your target.

## Need help?

See the [official documentation](https://docs.datadome.co/docs/sdk-ios-apollo).
