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

/// An `InterceptorProvider` that uses Apollo's default interceptor chain and inserts the DataDome
/// response interceptor right after the network fetch.
///
/// Subclassing `DefaultInterceptorProvider` (rather than hand-building the chain) keeps the provider
/// in lock-step with Apollo's default interceptors — including `MaxRetryInterceptor`,
/// `MultipartResponseParsingInterceptor`, and the deferred-fragment-aware JSON parser — so it never
/// drifts as Apollo evolves.
public final class DataDomeInterceptorProvider: DefaultInterceptorProvider {

    /// The CoreDataDome SDK instance used to validate responses.
    private let dataDome: DataDome

    /// Creates an interceptor provider backed by a CoreDataDome SDK instance.
    /// - Parameters:
    ///   - client: The `URLSessionClient` to use. Defaults to a fresh client.
    ///   - store: The `ApolloStore` shared with your `ApolloClient`.
    ///   - dataDome: The CoreDataDome SDK instance used to validate responses.
    public init(client: URLSessionClient = URLSessionClient(),
                store: ApolloStore,
                dataDome: DataDome) {
        self.dataDome = dataDome
        super.init(client: client, store: store)
    }

    /// Provides Apollo's default interceptors with `DataDomeResponseInterceptor` inserted immediately
    /// after `NetworkFetchInterceptor` (and before `ResponseCodeInterceptor`), so it inspects the raw
    /// HTTP response — e.g. a DataDome challenge — before Apollo turns a non-2xx status into an error.
    public override func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
    ) -> [any ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        let ddInterceptor = DataDomeResponseInterceptor(dataDome: dataDome)
        if let fetchIndex = interceptors.firstIndex(where: { $0 is NetworkFetchInterceptor }) {
            interceptors.insert(ddInterceptor, at: interceptors.index(after: fetchIndex))
        } else {
            interceptors.append(ddInterceptor)
        }
        return interceptors
    }
}
