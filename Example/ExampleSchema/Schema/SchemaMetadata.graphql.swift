// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

nonisolated protocol ApolloSchema_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == ApolloSchema.SchemaMetadata {}

nonisolated protocol ApolloSchema_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == ApolloSchema.SchemaMetadata {}

nonisolated protocol ApolloSchema_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == ApolloSchema.SchemaMetadata {}

nonisolated protocol ApolloSchema_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == ApolloSchema.SchemaMetadata {}

extension ApolloSchema {
  typealias SelectionSet = ApolloSchema_SelectionSet

  typealias InlineFragment = ApolloSchema_InlineFragment

  typealias MutableSelectionSet = ApolloSchema_MutableSelectionSet

  typealias MutableInlineFragment = ApolloSchema_MutableInlineFragment

  nonisolated enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    private static let objectTypeMap: [String: ApolloAPI.Object] = [
      "Query": ApolloSchema.Objects.Query,
      "User": ApolloSchema.Objects.User
    ]

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      objectTypeMap[typename]
    }
  }

  nonisolated enum Objects {}
  nonisolated enum Interfaces {}
  nonisolated enum Unions {}

}