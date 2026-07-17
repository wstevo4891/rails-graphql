# frozen_string_literal: true

class BlogCategory < ApplicationRecord
  belongs_to :blog
  belongs_to :category

  validates :category_id, uniqueness: { scope: :blog_id }
end
