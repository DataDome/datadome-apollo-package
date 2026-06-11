//
//  NetworkManager.swift
//  Example
//
//  Created by Alexandre Brispot on 21/11/2024.
//

import Foundation

import Apollo
import DataDomeApollo
import CoreDataDome

final class NetworkManager {
    enum Error: Swift.Error {
        case unknowned
    }
    
    static var shared: NetworkManager = NetworkManager()

    /// The CoreDataDome SDK instance. Reads the client-side key (and optional domain) from the app's
    /// Info.plist `DataDome` dictionary.
    private let dataDome = DataDome(configuration: try! DataDomeConfiguration.configurationFromBundle())

    private let headers = [
        "Accept": "application/json",
        "User-Agent": "BLOCKUA", // For testing purpose only - This will force a Captcha challenge if no DataDome cookie is present
        "Cache-Control": "max-age=0, no-cache, must-revalidate, proxy-revalidate" // For testing purpose only - This will bypass all cache
    ]
    
    private(set) lazy var apollo: ApolloClient = {
        // Create your own store needed to init the DataDomeInterceptor provider
        let store = ApolloStore(cache: InMemoryNormalizedCache())

        // Create the DataDome Interceptor Provider (Apollo v2: a GraphQLInterceptor provider)
        let provider = DataDomeInterceptorProvider(dataDome: dataDome)

        // Create your GraphQL URL
        let wpJsonEndpoint = "https://datadome.co/wp-json"

        guard let url = URL(string: wpJsonEndpoint) else {
            fatalError("Unable to create url https://datadome.co/wp-json")
        }

        let requestChainTransport = RequestChainNetworkTransport(urlSession: URLSession(configuration: .default),
                                                                 interceptorProvider: provider,
                                                                 store: store,
                                                                 endpointURL: url,
                                                                 additionalHeaders: headers,
                                                                 useGETForQueries: true)

        // Create the client with the request chain transport
        return ApolloClient(networkTransport: requestChainTransport,
                            store: store)
    }()

    private init() {

    }

    func protectedData(from url: URL, withId id: Int) async throws -> Data {
        _ = try await apollo.fetch(query: ApolloSchema.LaunchListQuery())

        return "lksjdfg".data(using: .utf8)!
    }
}
