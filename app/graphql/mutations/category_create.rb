# frozen_string_literal: true

module Mutations
  class CategoryCreate < BaseMutation
    description "Creates a new category"

    field :category, Types::CategoryType, null: false

    argument :title, String, required: true
    argument :slug, String, required: true
    argument :description, String, required: true

    def resolve(title:, slug:, description:)
      category = ::Category.new(title:, slug:, description:)
      raise_execution_error(category) unless category.save
      { category: category }
    end

    private

    def raise_execution_error(category)
      raise GraphQL::ExecutionError.new(
        "Error creating category",
        extensions: category.errors.to_hash
      )
    end
  end
end
