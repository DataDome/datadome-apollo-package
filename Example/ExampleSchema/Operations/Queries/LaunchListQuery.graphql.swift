// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension ApolloSchema {
  nonisolated struct LaunchListQuery: GraphQLQuery {
    static let operationName: String = "LaunchList"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query LaunchList { me { __typename id } }"#
      ))

    public init() {}

    nonisolated struct Data: ApolloSchema.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ApolloSchema.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("me", Me?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        LaunchListQuery.Data.self
      ] }

      var me: Me? { __data["me"] }

      /// Me
      ///
      /// Parent Type: `User`
      nonisolated struct Me: ApolloSchema.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ApolloSchema.Objects.User }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ApolloSchema.ID.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          LaunchListQuery.Data.Me.self
        ] }

        var id: ApolloSchema.ID { __data["id"] }
      }
    }
  }

}