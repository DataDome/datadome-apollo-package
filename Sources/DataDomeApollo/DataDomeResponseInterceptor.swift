//
//  DataDomeResponseInterceptor.swift
//  DataDomeApollo
//
//  Created by Mohamed Hajlaoui on 31/03/2021.
//

import Apollo
import DataDomeSDK
#if !COCOAPODS
import ApolloAPI
#endif

/// The DataDome interceptor. Use this to get your networking pipeline protected.
public class DataDomeResponseInterceptor: ApolloInterceptor {
    public var id: String = UUID().uuidString
    
    /// Expose the initializer publicly
    public init() {}
    
    /// This method is triggered when the DataDome interceptor is hit in the pipeline
    /// - Parameters:
    ///   - chain: The apollo chain
    ///   - request: The original request
    ///   - response: The response
    ///   - completion: The completion handler
    public final func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
        
        
        // Validate the underline networking layer wrapped by Apollo
        let prototype = ApolloCompletion(
            chain: chain,
            request: request,
            response: response,
            completion: completion
        )
        
        let filter = ApolloResponseFilter(completion: prototype,
                                          ignore: { (chain, request, response, completion) in
                                            chain.proceedAsync(request: request,
                                                               response: response,
                                                               completion: completion)
                                          },
                                          retry: { (chain, request, _, completion) in
                                            chain.retry(request: request, completion: completion)
                                          })
        
        filter.validate()
    }
}
