class Blog < ApplicationRecord
  TITLE_MAX = 100
  DESCRIPTION_MAX = 500

  belongs_to :user

  validates_associated :user
  validates :title, presence: true, length: { in: 1..TITLE_MAX }
  validates :description, presence: true, length: { in: 1..DESCRIPTION_MAX }
end
