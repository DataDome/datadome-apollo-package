//
//  DataDomeResponseInterceptor.swift
//  DataDomeApollo
//
//  Created by Mohamed Hajlaoui on 31/03/2021.
//

import Foundation
import Apollo
import ApolloAPI
import CoreDataDome

/// The DataDome interceptor. Use this to get your networking pipeline protected.
public final class DataDomeResponseInterceptor: ApolloInterceptor {
    public let id: String = UUID().uuidString

    /// The CoreDataDome SDK instance used to validate responses.
    private let dataDome: DataDome

    /// Creates an interceptor backed by the provided CoreDataDome SDK instance.
    /// - Parameter dataDome: The `DataDome` instance that validates intercepted responses.
    public init(dataDome: DataDome) {
        self.dataDome = dataDome
    }

    /// This method is triggered when the DataDome interceptor is hit in the pipeline
    /// - Parameters:
    ///   - chain: The apollo chain
    ///   - request: The original request
    ///   - response: The response
    ///   - completion: The completion handler
    public func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

            // Validate the response intercepted from Apollo's networking layer through CoreDataDome.
            let httpResponse = response?.httpResponse
            let headers = httpResponse?.allHeaderFields.reduce(into: [String: String]()) { result, pair in
                if let key = pair.key as? String, let value = pair.value as? String {
                    result[key] = value
                }
            } ?? [:]
            let ddResponse = DataDomeResponse(statusCode: httpResponse?.statusCode ?? 0,
                                              headers: headers,
                                              body: response?.rawData)

            Task {
                switch await dataDome.validateResponse(ddResponse, requestURL: request.graphQLEndpoint) {
                case .needRetry:
                    // A challenge was resolved and a fresh cookie is set; retry the request.
                    chain.retry(request: request, completion: completion)
                case .allowed, .blocked, .error:
                    // Not a DataDome challenge, hard-blocked, or validation error: let the response proceed.
                    chain.proceedAsync(request: request,
                                       response: response,
                                       interceptor: self,
                                       completion: completion)
                @unknown default:
                    chain.proceedAsync(request: request,
                                       response: response,
                                       interceptor: self,
                                       completion: completion)
                }
            }
        }
}
