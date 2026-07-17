# frozen_string_literal: true

module Mutations
  class RatingUpdate < BaseMutation
    description "Updates a rating by id"

    field :rating, Types::RatingType, null: false

    argument :id, ID, required: true
    argument :rating, Float, required: true

    def resolve(id:, rating:)
      raise_login_error unless context[:current_user]

      record = ::Rating.find(id)
      raise_authorization_error unless record.user_id == context[:current_user].id || context[:current_user].admin?
      raise_execution_error(record) unless record.update(rating:)

      { rating: record }
    end

    private

    def raise_login_error
      raise GraphQL::ExecutionError, "Login to access"
    end

    def raise_authorization_error
      raise GraphQL::ExecutionError, "You can only update your own ratings"
    end

    def raise_execution_error(record)
      raise GraphQL::ExecutionError.new(
        "Error updating rating",
        extensions: record.errors.to_hash
      )
    end
  end
end
