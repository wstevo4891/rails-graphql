require "rails_helper"

RSpec.describe Mutations::CommentDelete do
  let(:owner) { create(:user) }
  let(:comment) { create(:comment, user: owner) }
  let(:comment_id) { comment.id }

  let(:query) do
    <<~GQL
      mutation deleteComment {
        commentDelete(input: { id: #{comment_id} }) {
          message
        }
      }
    GQL
  end

  subject(:delete_comment) { RailsGraphqlSchema.execute(query, context: { current_user: owner }) }

  let(:response_message) { delete_comment.to_h["data"]["commentDelete"]["message"] }

  let(:error_message) { delete_comment.to_h["errors"].first["message"] }

  context "without a current user" do
    subject(:delete_comment) { RailsGraphqlSchema.execute(query) }

    it "returns a login error" do
      expect(error_message).to eq("Login to access")
    end
  end

  context "when current user is not the owner" do
    let(:other_user) { create(:user) }

    subject(:delete_comment) do
      RailsGraphqlSchema.execute(query, context: { current_user: other_user })
    end

    it "returns an authorization error" do
      expect(error_message).to eq("You can only delete your own comments")
    end
  end

  context "when current user is the owner" do
    it "returns a success message" do
      expect(response_message).to eq("Comment deleted successfully")
    end

    it "deletes the comment" do
      delete_comment
      expect { Comment.find(comment.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when current user is an admin (not the owner)" do
    let(:admin) { create(:user, role: :admin) }

    subject(:delete_comment) do
      RailsGraphqlSchema.execute(query, context: { current_user: admin })
    end

    it "returns a success message" do
      expect(response_message).to eq("Comment deleted successfully")
    end
  end

  context "when comment does not exist" do
    let(:comment_id) { 0 }

    it "returns a record not found message" do
      expect(error_message).to match(/Record not found/)
    end
  end
end
