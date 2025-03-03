//
//  NetworkManager.swift
//  Example
//
//  Created by Alexandre Brispot on 21/11/2024.
//

import Foundation

import Apollo
import DataDomeApollo
import DataDomeSDK

final class NetworkManager {
    enum Error: Swift.Error {
        case unknowned
    }
    
    static var shared: NetworkManager = NetworkManager()
    
    private let headers = [
        "Accept": "application/json",
        "User-Agent": "BLOCKUA", // For testing purpose only - This will force a Captcha challenge if no DataDome cookie is present
        "Cache-Control": "max-age=0, no-cache, must-revalidate, proxy-revalidate" // For testing purpose only - This will bypass all cache
    ]
    
    private(set) lazy var apollo: ApolloClient = {
        // Create your own store needed to init the DataDomeInterceptor provider
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        
        // Configure your session client
        let client = DataDomeURLSessionClient()
        
        // Create the DataDome Interceptor Provider
        let provider = DataDomeInterceptorProvider(store: store, client: client)
        
        // Create your GraphQL URL
        let wpJsonEndpoint = "https://datadome.co/wp-json"
        
        guard let url = URL(string: wpJsonEndpoint) else {
            fatalError("Unable to create url https://datadome.co/wp-json")
        }
        
        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                                 endpointURL: url,
                                                                 additionalHeaders: headers,
                                                                 useGETForQueries: true)
        
        // Create the client with the request chain transport
        return ApolloClient(networkTransport: requestChainTransport,
                            store: store)   
    }()
        
    private init() {
        
    }
    
    func protectedData(from url: URL, withId id: Int, captchaDelegate: CaptchaDelegate? = nil) async throws -> Data {
        apollo.fetch(query: ApolloSchema.LaunchListQuery(), context: ProtectedRequestContext(responsePageDelegate: captchaDelegate)) { result in
            
        }
                
        return "lksjdfg".data(using: .utf8)!
    }
}
