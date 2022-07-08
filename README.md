# DataDome Apollo Integration

[![Version](https://img.shields.io/cocoapods/v/DataDomeAlamofire.svg?style=flat)](http://cocoapods.org/pods/DataDomeAlamofire)
[![License](https://img.shields.io/cocoapods/l/DataDomeAlamofire.svg?style=flat)](http://cocoapods.org/pods/DataDomAlamofire)
[![Platform](https://img.shields.io/cocoapods/p/DataDomeAlamofire.svg?style=flat)](http://cocoapods.org/pods/DataDomeAlamofire)

## Installation
#### Swift package manager
The DataDomeApollo SDK is available on [Swift Package Manager](https://swift.org/package-manager/). To get the SDK integrated to your project:

1. In Xcode > File > Swift Packages > Add Package Dependency, select your target in which to integrate DataDomeApollo.
2. Paste the following git url in the search bar `https://github.com/DataDome/datadome-Apollo-package`
3. Select `DataDomeApollo` and press `Add`.





#### Cocoapods
If your api is a GraphQL api, the chances are that you are using Apollo SDK. If so, we have a dedicated framework called DataDomeApollo designed to ease the DataDome SDK integration.

To install the plugin, use the following Cocoapods instruction:
Alternatively, DataDomeAlamofire is available on [CocoaPods](http://cocoapods.org). To get the SDK integrated to your project, simply add the following line to your Podfile:

```ruby
pod "DataDomeApollo"
```

Run `pod install` to download and integrate the framework to your project.

## Getting started

1. Run your application. It is going to crash with the following log
```
Fatal error: [DataDome] Missing DataDomeKey (Your client side key) in your Info.plist
```
2. In your Info.plist, add a new entry with String type, use **DataDomeKey** as key and your actual client side key as value.
3. In your Info.plist, add a new entry with Boolean type, use **DataDomeProxyEnabled** as key and **NO** as value. This will disable method swizzling in the framework.
4. You can run now the app, it won't crash. You should see a log confirming the SDK is running
```
[DataDome] Version x.y.z
```

Congrats, the DataDome and DataDomeAlamofire frameworks are well integrated

## Logging
If you need to see the logs produced by the framework, you can set the log level to control the detail of logs you get

```swift
import DataDome
DataDome.setLogLevel(level: .verbose)
```

By default, the framework is completely silent.

The following table contains different logging levels that you may consider using


 Level                        | Description
---------------------------    |----------------------------------------------
__verbose__                  | Everything is logged
__info__                      | Info messages, warnings and errors are shown
__warning__                  | Only warning and errors messages are printed 
__error__                      | Only errors are printed
__none__                      | Silent mode (default)


## Force a captcha display
You can simulate a captcha display using the framework by providing a user agent with the value **BLOCKUA**

To do so:

1. Edit your app scheme
2. Under Run (Debug) > Arguments > Environment Variables, create a new variable
3. Set the name to **DATADOME\_USER\_AGENT** and the value to **BLOCKUA**

The DataDome framework will inject the specified user agent in the requests the app will be sending. Using the **BLOCKUA** user agent value will hint our remote protection module installed on your servers to treat this request as if it is coming from a bot. Which will block it with a captcha response.

Since the DataDome framework retains the cookies after resolving the captcha, this test can be done only the first time you used the BLOCKUA user agent. To reproduce the test case, you can use the following code snippet to manually clear the cookies stored in your app

```swift
for cookie in HTTPCookieStorage.shared.cookies ?? [] {
    HTTPCookieStorage.shared.deleteCookie(cookie)
}
```

## Apollo Integration
We use the Interceptor pattern built in the Apollo SDK to make sure we intercept all requests and protect them. The following is the init of the DataDome Interceptor

```import DataDomeApollo

let interceptor = DataDomeResponseInterceptor()
```

The interceptor could be used then in your pipeline. It will intercept all requests, catch requests blocked by DataDome, display the captcha and eventually retry the request automatically once the captcha is resolved.

####Important
The order in defining the interceptors is important in Apollo. Make sure the DataDome response Interceptor is the first interceptor after the NetworkFetchInterceptor.

Alternatively, you can use the DataDomeInterceptorProvider which is a pre-built sequence of interceptors ready to be used by your app. This provider is providing the same interceptors as the Legacy Interceptor provider. You can customise the interceptors to be added in the provider or use the default set.

```private(set) lazy var apollo: ApolloClient = {
// Create your own store needed to init the DataDomeInterceptor provider
let cache = InMemoryNormalizedCache()
let store = ApolloStore(cache: cache)

// Use DataDomeURLSessionClient to enable updating the user-agent
let client = DataDomeURLSessionClient()

// Create the DataDome Interceptor Provider
let provider = DataDomeInterceptorProvider(store: store, client: client)

// Create your GraphQL URL
guard let url = URL(string: "YOUR_ENDPOINT") else {
    fatalError("Unable to create url")
}

let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                         endpointURL: url)

// Create the client with the request chain transport
return ApolloClient(networkTransport: requestChainTransport,
                    store: store)
}()
```

In the above exemple we used the default configuration of DataDomeInterceptorProvider. You can specify custom interceptors using the following init method

```/// Creates an interceptor provider with a setup instance of DataDome
/// - Parameters:
///   - store: The apollo store
///   - client: The URLSession client
///   - preFetchInterceptors: The list of interceptors to go before the fetch operation
///   - fetchInterceptor: The fetch operation
///   - postFetchInterceptors: The list of interceptors to go after the fetch operation
public init(store: ApolloStore,
            client: URLSessionClient,
            preFetchInterceptors: [ApolloInterceptor] = [],
            fetchInterceptor: ApolloInterceptor? = nil,
            postFetchInterceptors: [ApolloInterceptor] = [])

```


`preFetchInterceptors` is a set of interceptors to be added before firing the request. By default we add:
CacheReadInterceptor

`fetchInterceptor` is the interceptor that will execute the request. By default, we use:
NetworkFetchInterceptor

The `DataDomeResponseInterceptor` is then added to the chain just after the fetch interceptor.

`postFetchInterceptors` is a set of interceptors to be added after the fetch interceptor. By default we add:
    - ResponseCodeInterceptor
    - JSONResponseParsingInterceptor
    - AutomaticPersistedQueryInterceptor
    - CacheWriteInterceptor

