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
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, format: { with: PASSWORD_REGEXP, message: "condition failed" }

  before_save { self.email = email.downcase }
end
