# frozen_string_literal: true

module Types
  class RoleType < Types::BaseEnum
    description "Role enum"

    value "author"
    value "admin"
  end
end
