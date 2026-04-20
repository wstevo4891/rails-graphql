# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :blog_delete, mutation: Mutations::BlogDelete
    field :blog_update, mutation: Mutations::BlogUpdate
    field :blog_create, mutation: Mutations::BlogCreate
    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end
  end
end
