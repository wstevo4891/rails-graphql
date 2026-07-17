# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node,
          Types::NodeType,
          null: true,
          description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes,
          [ Types::NodeType, null: true ],
          null: true,
          description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :blogs, [ Types::BlogType ], null: true, description: "Fetches all the blogs"

    def blogs
      Blog.all
    end

    field :blog, Types::BlogType, null: false, description: "Fetch blog by id" do
      argument :id, ID, required: true
    end

    def blog(id:)
      Blog.find(id)
    end

    field :categories, [ Types::CategoryType ], null: true, description: "Fetches all the categories"

    def categories
      Category.all
    end

    field :category, Types::CategoryType, null: false, description: "Fetch category by id" do
      argument :id, ID, required: true
    end

    def category(id:)
      Category.find(id)
    end

    field :comments, [ Types::CommentType ], null: true, description: "Fetches all the comments"

    def comments
      Comment.all
    end

    field :comment, Types::CommentType, null: false, description: "Fetch comment by id" do
      argument :id, ID, required: true
    end

    def comment(id:)
      Comment.find(id)
    end

    field :ratings, [ Types::RatingType ], null: true, description: "Fetches all the ratings"

    def ratings
      Rating.all
    end

    field :rating, Types::RatingType, null: false, description: "Fetch rating by id" do
      argument :id, ID, required: true
    end

    def rating(id:)
      Rating.find(id)
    end
  end
end
