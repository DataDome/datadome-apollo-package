//
//  DataDomeError.swift
//  DataDomeApollo
//
//  Apollo iOS v2 support. Compiled only when the `ApolloV2` trait is enabled.
//

#if ApolloV2

/// Errors surfaced by the DataDome Apollo v2 integration.
public enum DataDomeError: Error {
    /// DataDome presented a block page; the request cannot proceed.
    case blocked
}
#endif
