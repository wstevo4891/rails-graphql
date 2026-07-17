# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :sign_in_mutation, mutation: Mutations::SignInMutation
    field :blog_delete, mutation: Mutations::BlogDelete
    field :blog_update, mutation: Mutations::BlogUpdate
    field :blog_create, mutation: Mutations::BlogCreate
    field :category_create, mutation: Mutations::CategoryCreate
    field :category_update, mutation: Mutations::CategoryUpdate
    field :category_delete, mutation: Mutations::CategoryDelete
    field :comment_create, mutation: Mutations::CommentCreate
    field :comment_update, mutation: Mutations::CommentUpdate
    field :comment_delete, mutation: Mutations::CommentDelete
    field :rating_create, mutation: Mutations::RatingCreate
    field :rating_update, mutation: Mutations::RatingUpdate
    field :rating_delete, mutation: Mutations::RatingDelete
    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end
  end
end
