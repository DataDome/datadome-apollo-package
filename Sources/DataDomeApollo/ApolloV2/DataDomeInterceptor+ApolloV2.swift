//
//  DataDomeInterceptor+ApolloV2.swift
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

/// A CoreDataDome `GraphQLInterceptor` for Apollo iOS v2.
///
/// A DataDome challenge / block arrives as a non-2xx (typically `403`) response, which Apollo's default
/// `ResponseCodeInterceptor` surfaces as a `ResponseCodeInterceptor.ResponseCodeError` carrying the raw
/// `HTTPURLResponse` **and** the response body `Data`. This interceptor catches that error via
/// `mapErrors` and hands every non-2xx response to CoreDataDome, which decides whether it is a DataDome
/// challenge / block and, if so, presents the challenge / block page. On a resolved challenge it
/// throws `RequestChain.Retry` to re-run the request with the fresh cookie (bounded by Apollo's
/// `MaxRetryInterceptor`); a hard block throws ``DataDomeError/blocked``. Any other error — including a
/// non-2xx response that is not a DataDome challenge — is rethrown unchanged.
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
            // Hand every non-2xx response to CoreDataDome, which decides whether it is a DataDome
            // challenge; the body is read lazily via the provider only if validation needs it.
            guard let codeError = error as? ResponseCodeInterceptor.ResponseCodeError,
                  let requestURL = codeError.response.url else {
                throw error
            }

            let headers = codeError.response.allHeaderFields.reduce(into: [String: String]()) { result, pair in
                if let key = pair.key as? String, let value = pair.value as? String {
                    result[key] = value
                }
            }
            let ddResponse = DataDomeResponse(statusCode: codeError.response.statusCode,
                                              headers: headers,
                                              bodyProvider: { codeError.chunk })

            switch await dataDome.validateResponse(ddResponse, requestURL: requestURL) {
            case .needRetry:
                // A challenge was resolved and a fresh cookie is set; restart the request chain.
                throw RequestChain.Retry(request: request)
            case .blocked:
                throw DataDomeError.blocked
            case .allowed, .error:
                // `.allowed` means the response was not a DataDome challenge; `.error` is a validation
                // failure. In both cases surface the original networking error unchanged.
                throw error
            @unknown default:
                throw error
            }
        }
    }
}
#endif
