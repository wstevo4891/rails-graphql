class Blog < ApplicationRecord
  belongs_to :user

  validates_associated :user
  validates :title, presence: true, length: { in: 1..100 }
  validates :description, presence: true, length: { in: 1..500 }
end
