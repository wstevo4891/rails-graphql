# frozen_string_literal: true

module Mutations
  class RatingCreate < BaseMutation
    description "Creates or updates the current user's rating for a blog"

    field :rating, Types::RatingType, null: false

    argument :blog_id, ID, required: true
    argument :rating, Float, required: true

    def resolve(blog_id:, rating:)
      raise_login_error unless context[:current_user]

      record = ::Rating.find_or_initialize_by(blog_id: blog_id, user_id: context[:current_user].id)
      record.rating = rating
      raise_execution_error(record) unless record.save
      { rating: record }
    end

    private

    def raise_login_error
      raise GraphQL::ExecutionError, "Login to access"
    end

    def raise_execution_error(record)
      raise GraphQL::ExecutionError.new(
        "Error creating rating",
        extensions: record.errors.to_hash
      )
    end
  end
end
