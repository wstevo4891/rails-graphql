require "rails_helper"

RSpec.describe Mutations::CommentUpdate do
  let(:owner) { create(:user) }
  let(:comment) { create(:comment, user: owner) }
  let(:comment_id) { comment.id }
  let(:text) { "An updated comment." }

  let(:query) do
    <<~GQL
      mutation updateComment {
        commentUpdate(input: {
          id: #{comment_id},
          text: "#{text}"
        }) {
          comment {
            id
            text
          }
        }
      }
    GQL
  end

  subject(:update_comment) { RailsGraphqlSchema.execute(query, context: { current_user: owner }) }

  let(:response) { update_comment.to_h }

  let(:response_data) { response["data"]["commentUpdate"]["comment"] }

  let(:error_message) { response["errors"].first["message"] }

  let(:error_details) { response["errors"].first["extensions"] }

  it "updates the text" do
    expect(response_data["text"]).to eq(text)
  end

  context "without a current user" do
    subject(:update_comment) { RailsGraphqlSchema.execute(query) }

    it "returns a login error" do
      expect(error_message).to eq("Login to access")
    end
  end

  context "when current user is not the owner" do
    let(:other_user) { create(:user) }

    subject(:update_comment) do
      RailsGraphqlSchema.execute(query, context: { current_user: other_user })
    end

    it "returns an authorization error" do
      expect(error_message).to eq("You can only update your own comments")
    end
  end

  context "when current user is an admin (not the owner)" do
    let(:admin) { create(:user, role: :admin) }

    subject(:update_comment) do
      RailsGraphqlSchema.execute(query, context: { current_user: admin })
    end

    it "updates the text" do
      expect(response_data["text"]).to eq(text)
    end
  end

  context "when the text argument is blank" do
    let(:text) { "" }

    it "returns an error message" do
      expect(error_message).to eq("Error updating comment")
    end

    it "returns validation error details" do
      expect(error_details["text"]).to include("can't be blank")
    end
  end

  context "when comment ID does not exist" do
    let(:comment_id) { 0 }

    it "returns a record not found message" do
      expect(error_message).to match(/Record not found/)
    end
  end
end
