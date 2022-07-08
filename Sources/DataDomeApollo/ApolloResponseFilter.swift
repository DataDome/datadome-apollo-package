//
//  ApolloResponseFilter.swift
//  DataDomeApollo
//
//  Created by Mohamed Hajlaoui on 31/03/2021.
//

import DataDomeSDK
import Apollo

/// This class handles the validation of each intercepted request.
internal final class ApolloResponseFilter<Operation: GraphQLOperation> {
    typealias ApolloClosure = ((RequestChain,
                                HTTPRequest<Operation>,
                                HTTPResponse<Operation>?,
                                @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Void)
    
    /// A representation of the completion handler
    private let completion: ApolloCompletion<Operation>
    
    /// A delegate conforming to the FilterDelegate protocol
    private var retry: ApolloClosure
    private var ignore: ApolloClosure

    
    /// Create a filter for a specified request
    /// - Parameters:
    ///   - prototype: The completion prototype created with the data task
    ///   - delegate: The filter delegate responsible for actioning the filtering result
    required init(completion: ApolloCompletion<Operation>,
                  ignore: @escaping ApolloClosure,
                  retry: @escaping ApolloClosure) {
        
        self.completion = completion
        self.retry = retry
        self.ignore = ignore
    }
    
    func validate() {
        let validator = ResponseValidator(request: completion.request,
                                          response: completion.response?.httpResponse,
                                          data: completion.response?.rawData)
        
        validator.delegate = self
        validator.validate()
    }
}

extension ApolloResponseFilter: ResponseValidatorDelegate {
    func shouldIgnore(request: Requestable) {
        ignore(completion.chain, completion.request, completion.response, completion.completion)
    }
    
    func didFailWith(error: Error) {
        ignore(completion.chain, completion.request, completion.response, completion.completion)
    }
    
    func shouldRetry(request: Requestable) {
        retry(completion.chain, completion.request, completion.response, completion.completion)
        EventTracker.shared.log(request: request, integrationMode: .apollo)
    }
}

extension HTTPRequest: Requestable {
    public var url: URL? {
        graphQLEndpoint
    }
    
    public func header(forField field: String) -> String? {
        additionalHeaders[field]
    }
}
