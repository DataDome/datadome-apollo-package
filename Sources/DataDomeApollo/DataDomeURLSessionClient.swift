//
//  DataDomeURLSessionClient.swift
//  DataDomeApollo
//
//  Created by Mohamed Hajlaoui on 31/03/2021.
//

import Apollo

/// An URLSessionClient with specific DataDome setup
public class DataDomeURLSessionClient: URLSessionClient {
    public init() {
        let config = URLSessionConfiguration.default
        if let header = ProcessInfo().environment["DATADOME_USER_AGENT"] {
            if var headers = config.httpAdditionalHeaders {
                headers["User-Agent"] = header
                headers["Accept"] = "application/json"
                config.httpAdditionalHeaders = headers
            } else {
                config.httpAdditionalHeaders = ["User-Agent": header, "Accept": "application/json"]
            }
        }
        
        super.init(sessionConfiguration: config, callbackQueue: nil)
    }
}
