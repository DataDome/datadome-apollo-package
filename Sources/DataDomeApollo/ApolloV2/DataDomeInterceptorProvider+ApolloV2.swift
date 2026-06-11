//
//  DataDomeInterceptorProvider+ApolloV2.swift
//  DataDomeApollo
//
//  Apollo iOS v2 support. Compiled only when the `ApolloV2` trait is enabled.
//

#if ApolloV2
import Apollo
import ApolloAPI
import CoreDataDome

/// An Apollo iOS v2 `InterceptorProvider` that appends ``DataDomeInterceptor`` to Apollo's default
/// GraphQL interceptors.
///
/// DataDome is added last (innermost), so its `mapErrors` sees a `ResponseCodeError` before the other
/// GraphQL interceptors, while `MaxRetryInterceptor` (first/outermost) still bounds the retry loop. All
/// other interceptors — including the HTTP `ResponseCodeInterceptor` whose error carries the challenge
/// response — use Apollo's defaults.
public struct DataDomeInterceptorProvider: InterceptorProvider {

    /// The CoreDataDome SDK instance used to validate responses.
    private let dataDome: DataDome

    /// Creates an interceptor provider backed by a CoreDataDome SDK instance.
    /// - Parameter dataDome: The CoreDataDome SDK instance used to validate responses.
    public init(dataDome: DataDome) {
        self.dataDome = dataDome
    }

    public func graphQLInterceptors<Operation: GraphQLOperation>(
        for operation: Operation
    ) -> [any GraphQLInterceptor] {
        DefaultInterceptorProvider.shared.graphQLInterceptors(for: operation)
            + [DataDomeInterceptor(dataDome: dataDome)]
    }
}
#endif
