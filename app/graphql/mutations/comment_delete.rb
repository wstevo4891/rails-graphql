# frozen_string_literal: true

module Mutations
  class CommentDelete < BaseMutation
    description "Deletes a comment by ID"

    field :message, String, null: false

    argument :id, ID, required: true

    def resolve(id:)
      raise_login_error unless context[:current_user]

      comment = ::Comment.find(id)
      raise_authorization_error unless comment.user_id == context[:current_user].id || context[:current_user].admin?
      raise_deletion_error(comment) unless comment.destroy!

      { message: "Comment deleted successfully" }
    end

    private

    def raise_login_error
      raise GraphQL::ExecutionError, "Login to access"
    end

    def raise_authorization_error
      raise GraphQL::ExecutionError, "You can only delete your own comments"
    end

    def raise_deletion_error(comment)
      raise GraphQL::ExecutionError.new(
        "Error deleting comment",
        extensions: comment.errors.to_hash
      )
    end
  end
end
