//
//  ApolloCompletion.swift
//  DataDomeApollo
//
//  Created by Mohamed Hajlaoui on 31/03/2021.
//  Copyright © 2021 DataDome. All rights reserved.
//

import Apollo
import ApolloAPI

/// A representation of the completion handler of a request
public class ApolloCompletion<Operation: GraphQLOperation> {
    internal let chain: RequestChain
    internal let request: HTTPRequest<Operation>
    internal let response: HTTPResponse<Operation>?
    internal let completion: (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    
    
    /// An initialization constructor with the data needed to execute an apollo chain
    /// - Parameters:
    ///   - chain: The transport chain
    ///   - request: The sent request
    ///   - response: The received response
    ///   - completion: The completion to be fire once completed
    public init(chain: RequestChain,
                request: HTTPRequest<Operation>,
                response: HTTPResponse<Operation>?,
                completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
        
        self.chain = chain
        self.request = request
        self.response = response
        self.completion = completion
    }
}
