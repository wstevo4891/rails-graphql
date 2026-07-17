# frozen_string_literal: true

module Mutations
  class RatingDelete < BaseMutation
    description "Deletes a rating by ID"

    field :message, String, null: false

    argument :id, ID, required: true

    def resolve(id:)
      raise_login_error unless context[:current_user]

      record = ::Rating.find(id)
      raise_authorization_error unless record.user_id == context[:current_user].id || context[:current_user].admin?
      raise_deletion_error(record) unless record.destroy!

      { message: "Rating deleted successfully" }
    end

    private

    def raise_login_error
      raise GraphQL::ExecutionError, "Login to access"
    end

    def raise_authorization_error
      raise GraphQL::ExecutionError, "You can only delete your own ratings"
    end

    def raise_deletion_error(record)
      raise GraphQL::ExecutionError.new(
        "Error deleting rating",
        extensions: record.errors.to_hash
      )
    end
  end
end
