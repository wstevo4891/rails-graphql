# frozen_string_literal: true

module Mutations
  class CategoryUpdate < BaseMutation
    description "Updates a category by id"

    field :category, Types::CategoryType, null: false

    argument :id, ID, required: true
    argument :title, String, required: false
    argument :slug, String, required: false
    argument :description, String, required: false

    def resolve(id:, title: nil, slug: nil, description: nil)
      category = ::Category.find(id)
      title = category.title if title.nil?
      slug = category.slug if slug.nil?
      description = category.description if description.nil?
      raise_execution_error(category) unless category.update(title:, slug:, description:)

      { category: category }
    end

    private

    def raise_execution_error(category)
      raise GraphQL::ExecutionError.new(
        "Error updating category",
        extensions: category.errors.to_hash
      )
    end
  end
end
