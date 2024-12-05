// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

extension ApolloSchema {
  class LaunchListQuery: GraphQLQuery {
    static let operationName: String = "LaunchList"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"query LaunchList { me { __typename id } }"#
      ))

    public init() {}

    struct Data: ApolloSchema.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any Apollo.ParentType { ApolloSchema.Objects.Query }
      static var __selections: [Apollo.Selection] { [
        .field("me", Me?.self),
      ] }

      var me: Me? { __data["me"] }

      /// Me
      ///
      /// Parent Type: `User`
      struct Me: ApolloSchema.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any Apollo.ParentType { ApolloSchema.Objects.User }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("id", ApolloSchema.ID.self),
        ] }

        var id: ApolloSchema.ID { __data["id"] }
      }
    }
  }

}