//
//  DataDomeURLSessionClient.swift
//  DataDomeApollo
//
//  Created by Mohamed Hajlaoui on 31/03/2021.
//

import Foundation

import Apollo
#if !COCOAPODS
import ApolloAPI
#endif

/// An URLSessionClient with specific DataDome setup
public final class DataDomeURLSessionClient: URLSessionClient {
    public init() {
        let config = URLSessionConfiguration.default
        if let header = ProcessInfo().environment["DATADOME_USER_AGENT"] {
            if var headers = config.httpAdditionalHeaders {
                headers["User-Agent"] = header
                config.httpAdditionalHeaders = headers
            } else {
                config.httpAdditionalHeaders = ["User-Agent": header]
            }
        }
        
        super.init(sessionConfiguration: config, callbackQueue: nil)
    }
}
