//
//  TraitCheck.swift
//  DataDomeApollo
//
//  Fails the build early if neither Apollo trait is enabled, instead of producing a confusing
//  "no such type" error from an empty target.
//

#if !ApolloV1 && !ApolloV2
#error("DataDomeApollo: enable exactly one Apollo trait — 'ApolloV1' (default) or 'ApolloV2' — matching the Apollo iOS major your app depends on.")
#endif
