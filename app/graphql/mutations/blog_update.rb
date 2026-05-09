# frozen_string_literal: true

module Mutations
  class BlogUpdate < BaseMutation
    description "Updates a blog by id"

    field :blog, Types::BlogType, null: false

    argument :id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false

    def resolve(id:, title: nil, description: nil)
      blog = ::Blog.find(id)
      title = blog.title if title.nil?
      description = blog.description if description.nil?
      raise_execution_error(blog) unless blog.update(title:, description:)

      { blog: blog }
    end

    private

    def raise_execution_error(blog)
      raise GraphQL::ExecutionError.new(
        "Error updating blog",
        extensions: blog.errors.to_hash
      )
    end
  end
end
