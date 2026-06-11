# Migrating to DataDomeApollo 4.0.0 (CoreDataDome)

DataDomeApollo **4.0.0** replaces the legacy **DataDomeSDK** dependency with the new modular
**CoreDataDome** SDK. This is a breaking release: response validation now runs through CoreDataDome's
`DataDome` instance, and the challenge / blocked page is presented by the SDK itself. This guide
covers upgrading an existing integration from 3.8.x or earlier.

## Requirements

- **iOS 15.0+** (raised from iOS 12).
- Swift Package Manager, Apollo iOS 1.x.

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

## 1. Update the package & deployment target

Bump DataDomeApollo to `4.0.0` and raise your app's minimum deployment target to **iOS 15.0**.

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

## 6. Remove other deleted symbols

- **`ApolloCompletion`** — removed (was an internal helper exposed publicly).
- **`EventTracker` / `.apollo` integration logging** — removed; there is no equivalent in CoreDataDome.

## Behavioral changes

- **Challenge presentation** is owned by the SDK (shown in its own window); presentation is not
  customizable in this release.
- **Cookies**: the DataDome cookie is stored in the shared `HTTPCookieStorage` and attached to
  subsequent requests automatically. Keep your Apollo `URLSessionClient` on the default configuration
  (the default) so the cookie is sent on retry.
- **Retries**: a resolved challenge automatically retries the operation, capped by Apollo's
  `MaxRetryInterceptor` (3 retries).

## Troubleshooting

- *`configurationFromBundle()` throws / crash on launch* → the `DataDome` dict or `ClientSideKey` is
  missing from Info.plist (step 2), or use the programmatic initializer.
- *`Cannot find type 'CaptchaDelegate' / 'DataDomeURLSessionClient' / 'ApolloCompletion'`* → these were
  removed; see steps 4–6.
- *`No such module 'CoreDataDome'`* → add the CoreDataDome package product to your target.

## Need help?

See the [official documentation](https://docs.datadome.co/docs/sdk-ios-apollo).
