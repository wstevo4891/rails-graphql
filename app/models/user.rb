# frozen_string_literal: true

# Model for users table
class User < ApplicationRecord
  PASSWORD_REGEXP = /\A
    (?=.{8,})
    (?=.*\d)
    (?=.*[a-z])
    (?=.*[A-Z])
    (?=.*[[:^alnum:]])
  /x.freeze

  has_many :blogs, dependent: :destroy

  enum :role, %w[author admin]
  has_secure_password

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, format: {
    with: PASSWORD_REGEXP,
    message: "condition failed"
  }

  before_save { self.email = email.downcase }
end
