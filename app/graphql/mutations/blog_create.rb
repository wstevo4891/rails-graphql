# frozen_string_literal: true

module Mutations
  class BlogCreate < BaseMutation
    description "Creates a new blog"

    field :blog, Types::BlogType, null: false

    argument :title, String, required: true
    argument :description, String, required: true
    argument :user_id, ID, required: true

    def resolve(title:, description:, user_id:)
      blog = ::Blog.new(title:, description:, user_id:)
      raise_execution_error(blog) unless blog.save

      { blog: blog }
    end

    private

    def raise_execution_error(blog)
      raise GraphQL::ExecutionError.new(
        "Error creating blog",
        extensions: blog.errors.to_hash
      )
    end
  end
end
