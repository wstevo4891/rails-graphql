# frozen_string_literal: true

module Types
  class RatingType < Types::BaseObject
    field :id, ID, null: false
    field :rating, Float, null: false
    field :blog_id, Integer, null: false
    field :user_id, Integer, null: false
    field :user_name, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def user_name
      "#{object.user.first_name} #{object.user.last_name}"
    end
  end
end
