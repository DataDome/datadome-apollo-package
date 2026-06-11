//
//  DataDomeRequestContext.swift
//  Pods
//
//  Created by Alexandre Brispot on 26/12/2024.
//

import CoreDataDome
import Apollo
#if !COCOAPODS
import ApolloAPI
#endif

@available(*, deprecated, message: "Response-page presentation is handled internally by CoreDataDome; this context's delegate is ignored. This type is retained only for source compatibility and can be removed in a future release.")
public protocol DataDomeRequestContext: RequestContext {
    var responsePageDelegate: DataDomeResponsePageDelegate? { get }
}

@available(*, deprecated, message: "Response-page presentation is handled internally by CoreDataDome; this context's delegate is ignored. This type is retained only for source compatibility and can be removed in a future release.")
public class ProtectedRequestContext: DataDomeRequestContext {
    public init(responsePageDelegate: (any DataDomeResponsePageDelegate)? = nil) {
        self.responsePageDelegate = responsePageDelegate
    }

    public var responsePageDelegate: (any DataDomeResponsePageDelegate)?
}
