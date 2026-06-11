//
//  NetworkInterceptorProvider.swift
//  DataDomeApollo
//
//  Created by Mohamed Hajlaoui on 31/03/2021.
//

import Foundation
import Apollo
import CoreDataDome
#if !COCOAPODS
import ApolloAPI
#endif

public class DataDomeInterceptorProvider: InterceptorProvider {

    /// The apollo sotre
    private let store: ApolloStore

    /// The Apollo URLSession client used by the network fetch interceptor.
    private let client: URLSessionClient

    /// The list of interceptors in the provider
    private let interceptors: [ApolloInterceptor]

    /// Creates an interceptor provider with a setup instance of DataDome
    /// - Parameters:
    ///   - store: The apollo store
    ///   - client: The URLSession client
    ///   - dataDome: The CoreDataDome SDK instance used to validate responses
    ///   - preFetchInterceptors: The list of interceptors to go before the fetch operation
    ///   - fetchInterceptor: The fetch operation
    ///   - postFetchInterceptors: The list of interceptors to go after the fetch operation
    public init(store: ApolloStore,
                client: URLSessionClient,
                dataDome: DataDome,
                preFetchInterceptors: [ApolloInterceptor] = [],
                fetchInterceptor: ApolloInterceptor? = nil,
                postFetchInterceptors: [ApolloInterceptor] = []) {

        self.store = store
        self.client = client
        
        var interceptors = [ApolloInterceptor]()
        
        // Pre-fetch interceptors
        if !preFetchInterceptors.isEmpty {
            interceptors.append(contentsOf: preFetchInterceptors)
        } else {
            interceptors.append(contentsOf: [
                CacheReadInterceptor(store: self.store)
            ] as [ApolloInterceptor])
        }
        
        // Fetch interceptor
        if let fetchInterceptor = fetchInterceptor {
            interceptors.append(fetchInterceptor)
        } else {
            interceptors.append(NetworkFetchInterceptor(client: self.client))
        }
        
        // Insert the DataDome response interceptor at the top of the chain
        interceptors.append(DataDomeResponseInterceptor(dataDome: dataDome))
        
        
        // Post fetch interceptors
        if !postFetchInterceptors.isEmpty {
            interceptors.append(contentsOf: postFetchInterceptors)
        } else {
            interceptors.append(contentsOf: [
                ResponseCodeInterceptor(),
                JSONResponseParsingInterceptor(),
                AutomaticPersistedQueryInterceptor(),
                CacheWriteInterceptor(store: self.store)
            ] as [ApolloInterceptor])
        }
        
        self.interceptors = interceptors
    }
    
    /// Provides the list of interceptors in order of execution in the pipeline.
    /// - Parameter operation: The operation
    /// - Returns: The list of interceptors for the provided operation
    public func interceptors<Operation>(for operation: Operation)
    -> [ApolloInterceptor] where Operation: GraphQLOperation {
        interceptors
    }
}
