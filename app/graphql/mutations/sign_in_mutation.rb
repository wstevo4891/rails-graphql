# frozen_string_literal: true

module Mutations
  class SignInMutation < BaseMutation
    field :token, String, null: true
    field :error, String, null: true

    argument :username, String, required: true
    argument :password, String, required: true

    def resolve(username:, password:)
      raise_redundant_sign_in_error if context[:current_user]

      hmac_secret = Rails.application.credentials.dig(:API_KEY)
      user = User.find_by(username: username)&.authenticate(password)

      return { error: "Username or Password is incorrect" } unless user

      token = JWT.encode(user.id, hmac_secret, "HS256")

      {
        token: token,
        error: ""
      }
    end

    private

    def raise_redundant_sign_in_error
      raise GraphQL::ExecutionError, "User already signed in"
    end
  end
end
