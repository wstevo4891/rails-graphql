# frozen_string_literal: true

class Category < ApplicationRecord
  TITLE_MAX = 100
  DESCRIPTION_MAX = 500

  has_many :blog_categories, dependent: :destroy
  has_many :blogs, through: :blog_categories

  validates :title, presence: true, length: { in: 1..TITLE_MAX }
  validates :description, presence: true, length: { in: 1..DESCRIPTION_MAX }
  validates :slug, presence: true, uniqueness: true
end
