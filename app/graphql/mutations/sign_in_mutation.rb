# frozen_string_literal: true

module Mutations
  class SignInMutation < BaseMutation
    field :token, String, null: true
    field :error, String, null: true

    argument :username, String, required: true
    argument :password, String, required: true

    def resolve(username:, password:)
      raise GraphQL::ExecutionError, "User already signed in" if context[:current_user]

      hmac_secret = YOUR_SECRET_KEY
      user = User.find_by(username: "user-name")&.authenticate(password)

      return { error: "Username or Password is incorrect" } unless user

      token = JWT.encode(user.id, hmac_secret, "HS256")

      {
        token: token,
        error: ""
      }
    end
  end
end
