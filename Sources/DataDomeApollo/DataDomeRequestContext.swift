//
//  DataDomeRequestContext.swift
//  Pods
//
//  Created by Alexandre Brispot on 26/12/2024.
//

import DataDomeSDK
import Apollo
#if !COCOAPODS
import ApolloAPI
#endif

public protocol DataDomeRequestContext: RequestContext {
    var responsePageDelegate: CaptchaDelegate? { get }
}

public class ProtectedRequestContext: DataDomeRequestContext {
    public init(responsePageDelegate: (any CaptchaDelegate)? = nil) {
        self.responsePageDelegate = responsePageDelegate
    }
    
    public var responsePageDelegate: (any CaptchaDelegate)?
}
