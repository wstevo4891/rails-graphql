# frozen_string_literal: true

module Mutations
  class CategoryDelete < BaseMutation
    description "Deletes a category by ID"

    field :message, String, null: false

    argument :id, ID, required: true

    def resolve(id:)
      raise_login_error unless context[:current_user]
      raise_authorization_error unless context[:current_user].admin?

      category = ::Category.find(id)
      raise_deletion_error(category) unless category.destroy!

      { message: "Category deleted successfully" }
    end

    private

    def raise_login_error
      raise GraphQL::ExecutionError, "Login to access"
    end

    def raise_authorization_error
      raise GraphQL::ExecutionError, "Only admins can delete categories"
    end

    def raise_deletion_error(category)
      raise GraphQL::ExecutionError.new(
        "Error deleting category",
        extensions: category.errors.to_hash
      )
    end
  end
end
