//
//  DataDomeApollo+ApolloV2.swift
//  DataDomeApollo
//
//  Apollo iOS v2 support, built on the async `GraphQLInterceptor` API.
//  Compiled only when the `ApolloV2` trait is enabled.
//

#if ApolloV2
import Foundation
import Apollo
import ApolloAPI
import CoreDataDome

/// Errors surfaced by the DataDome Apollo v2 interceptor.
public enum DataDomeError: Error {
    /// DataDome presented a block page; the request cannot proceed.
    case blocked
}

/// A CoreDataDome `GraphQLInterceptor` for Apollo iOS v2.
///
/// A DataDome challenge / block arrives as a non-2xx (typically `403`) response, which Apollo's default
/// `ResponseCodeInterceptor` surfaces as a `ResponseCodeInterceptor.ResponseCodeError` carrying the raw
/// `HTTPURLResponse` **and** the response body `Data`. This interceptor catches that error via
/// `mapErrors`; when the response carries a DataDome challenge header (`x-dd-b` / `x-sf-cc-x-dd-b`) it
/// validates through CoreDataDome — which presents the challenge / block page. On a resolved challenge it
/// throws `RequestChain.Retry` to re-run the request with the fresh cookie (bounded by Apollo's
/// `MaxRetryInterceptor`); a hard block throws ``DataDomeError/blocked``. Any other error is rethrown
/// unchanged.
public struct DataDomeInterceptor: GraphQLInterceptor {

    /// The CoreDataDome SDK instance used to validate responses.
    private let dataDome: DataDome

    /// Creates an interceptor backed by the provided CoreDataDome SDK instance.
    /// - Parameter dataDome: The `DataDome` instance that validates intercepted responses.
    public init(dataDome: DataDome) {
        self.dataDome = dataDome
    }

    public func intercept<Request: GraphQLRequest>(
        request: Request,
        next: NextInterceptorFunction<Request>
    ) async throws -> InterceptorResultStream<Request> {
        let dataDome = self.dataDome
        return await next(request).mapErrors { error in
            // Act only on a non-2xx response that carries a DataDome challenge header.
            guard let codeError = error as? ResponseCodeInterceptor.ResponseCodeError,
                  let requestURL = codeError.response.url,
                  Self.isDataDomeChallenge(codeError.response) else {
                throw error
            }

            let headers = codeError.response.allHeaderFields.reduce(into: [String: String]()) { result, pair in
                if let key = pair.key as? String, let value = pair.value as? String {
                    result[key] = value
                }
            }
            let ddResponse = DataDomeResponse(statusCode: codeError.response.statusCode,
                                              headers: headers,
                                              body: codeError.chunk)

            switch await dataDome.validateResponse(ddResponse, requestURL: requestURL) {
            case .needRetry:
                // A challenge was resolved and a fresh cookie is set; restart the request chain.
                throw RequestChain.Retry(request: request)
            case .blocked:
                throw DataDomeError.blocked
            case .allowed, .error:
                // `.allowed` is unreachable here (the challenge header was present); `.error` is a
                // validation failure. Surface the original networking error unchanged.
                throw error
            @unknown default:
                throw error
            }
        }
    }

    /// Header-only detection of a DataDome challenge / block response.
    private static func isDataDomeChallenge(_ response: HTTPURLResponse) -> Bool {
        response.value(forHTTPHeaderField: "x-dd-b") != nil
            || response.value(forHTTPHeaderField: "x-sf-cc-x-dd-b") != nil
    }
}

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
