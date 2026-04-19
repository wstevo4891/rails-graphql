class User < ApplicationRecord
  has_many :blogs, dependent: :destroy
  before_save { self.email = email.downcase }
end
