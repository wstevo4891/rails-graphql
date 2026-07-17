# frozen_string_literal: true

module Mutations
  class CommentCreate < BaseMutation
    description "Creates a new comment"

    field :comment, Types::CommentType, null: false

    argument :blog_id, ID, required: true
    argument :text, String, required: true

    def resolve(blog_id:, text:)
      raise_login_error unless context[:current_user]

      comment = ::Comment.new(blog_id: blog_id, text: text, user_id: context[:current_user].id)
      raise_execution_error(comment) unless comment.save
      { comment: comment }
    end

    private

    def raise_login_error
      raise GraphQL::ExecutionError, "Login to access"
    end

    def raise_execution_error(comment)
      raise GraphQL::ExecutionError.new(
        "Error creating comment",
        extensions: comment.errors.to_hash
      )
    end
  end
end
