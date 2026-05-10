require "rails_helper"

RSpec.describe Mutations::SignInMutation do
  let(:user) { create(:user) }
  let(:username) { user.username }
  let(:password) { user.password }

  let(:query) do
    <<~GQL
      mutation SignIn {
        signInMutation(input: {
          username: "#{username}",
          password: "#{password}"
        }) {
          token
          error
        }
      }
    GQL
  end

  subject(:sign_in) { RailsGraphqlSchema.execute(query) }

  let(:response_data) { sign_in.to_h["data"]["signInMutation"] }

  context "without a current user" do
    it "returns a token" do
      expect(response_data["token"]).to be_a(String)
    end

    it "does not return an error" do
      expect(response_data["error"]).to be_nil
    end
  end

  context "with a current user" do
    subject(:sign_in) do
      RailsGraphqlSchema.execute(query, context: { current_user: user })
    end

    let(:error_message) { sign_in.to_h["errors"].first["message"] }

    it "returns a redundant sign in error" do
      expect(error_message).to eq("User already signed in")
    end
  end

  context "when username is blank" do
    let(:username) { "" }

    it "does not return a token" do
      expect(response_data["token"]).to be_nil
    end

    it "returns an error message" do
      expect(response_data["error"]).to eq("Username or Password is incorrect")
    end
  end

  context "when password is blank" do
    let(:password) { "" }

    it "does not return a token" do
      expect(response_data["token"]).to be_nil
    end

    it "returns an error message" do
      expect(response_data["error"]).to eq("Username or Password is incorrect")
    end
  end

  context "when user does not exist" do
    let(:username) { "fakeUser123" }

    it "does not return a token" do
      expect(response_data["token"]).to be_nil
    end

    it "returns an error message" do
      expect(response_data["error"]).to eq("Username or Password is incorrect")
    end
  end
end
