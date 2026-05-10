# frozen_string_literal: true

module Mutations
  class BlogDelete < BaseMutation
    description "Deletes a blog by ID"

    field :message, String, null: false

    argument :id, ID, required: true

    def resolve(id:)
      raise_login_error unless context[:current_user]
      raise_authorization_error unless context[:current_user].admin?

      blog = ::Blog.find(id)
      raise_deletion_error(blog) unless blog.destroy!

      { message: "Blog deleted successfully" }
    end

    private

    def raise_login_error
      raise GraphQL::ExecutionError, "Login to access"
    end

    def raise_authorization_error
      raise GraphQL::ExecutionError, "Only admins can delete blogs"
    end

    def raise_deletion_error(blog)
      raise GraphQL::ExecutionError.new(
        "Error deleting blog",
        extensions: blog.errors.to_hash
      )
    end
  end
end
