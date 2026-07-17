# frozen_string_literal: true

module Mutations
  class CommentUpdate < BaseMutation
    description "Updates a comment by id"

    field :comment, Types::CommentType, null: false

    argument :id, ID, required: true
    argument :text, String, required: true

    def resolve(id:, text:)
      raise_login_error unless context[:current_user]

      comment = ::Comment.find(id)
      raise_authorization_error unless comment.user_id == context[:current_user].id || context[:current_user].admin?
      raise_execution_error(comment) unless comment.update(text:)

      { comment: comment }
    end

    private

    def raise_login_error
      raise GraphQL::ExecutionError, "Login to access"
    end

    def raise_authorization_error
      raise GraphQL::ExecutionError, "You can only update your own comments"
    end

    def raise_execution_error(comment)
      raise GraphQL::ExecutionError.new(
        "Error updating comment",
        extensions: comment.errors.to_hash
      )
    end
  end
end
