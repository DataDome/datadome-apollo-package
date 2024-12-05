// @generated
// This file was automatically generated and should not be edited.

import Apollo

protocol ApolloSchema_SelectionSet: Apollo.SelectionSet & Apollo.RootSelectionSet
where Schema == ApolloSchema.SchemaMetadata {}

protocol ApolloSchema_InlineFragment: Apollo.SelectionSet & Apollo.InlineFragment
where Schema == ApolloSchema.SchemaMetadata {}

protocol ApolloSchema_MutableSelectionSet: Apollo.MutableRootSelectionSet
where Schema == ApolloSchema.SchemaMetadata {}

protocol ApolloSchema_MutableInlineFragment: Apollo.MutableSelectionSet & Apollo.InlineFragment
where Schema == ApolloSchema.SchemaMetadata {}

extension ApolloSchema {
  typealias SelectionSet = ApolloSchema_SelectionSet

  typealias InlineFragment = ApolloSchema_InlineFragment

  typealias MutableSelectionSet = ApolloSchema_MutableSelectionSet

  typealias MutableInlineFragment = ApolloSchema_MutableInlineFragment

  enum SchemaMetadata: Apollo.SchemaMetadata {
    static let configuration: any Apollo.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> Apollo.Object? {
      switch typename {
      case "Query": return ApolloSchema.Objects.Query
      case "User": return ApolloSchema.Objects.User
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}