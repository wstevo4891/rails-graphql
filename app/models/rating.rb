# frozen_string_literal: true

class Rating < ApplicationRecord
  belongs_to :blog
  belongs_to :user

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 5.0 }
  validates :user_id, uniqueness: { scope: :blog_id }
end
