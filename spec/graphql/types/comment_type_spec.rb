require "rails_helper"

RSpec.describe Types::CommentType do
  let(:user) { create(:user) }

  describe "querying all comments" do
    let(:query) do
      <<~GQL
        {
          comments {
            id
            text
            userName
          }
        }
      GQL
    end

    subject(:fetch_all) { RailsGraphqlSchema.execute(query) }

    let(:response) { fetch_all.to_h["data"]["comments"] }

    context "when comments exist" do
      let!(:comments) { create_list(:comment, 5, user: user) }

      it "returns the expected number of results" do
        expect(response.size).to eq(5)
      end

      it "returns comment IDs" do
        comment_id = response.first["id"].to_i
        expect(comment_id).to be_a(Integer)
      end

      it "returns comment text" do
        actual = response.first["text"]
        expected = comments.first.text
        expect(actual).to eq(expected)
      end

      it "returns comment userNames" do
        actual = response.first["userName"]
        expected = "#{user.first_name} #{user.last_name}"
        expect(actual).to eq(expected)
      end
    end

    context "when comments do not exist" do
      it "returns an empty response" do
        expect(response).to be_empty
      end
    end
  end

  describe "querying a comment by ID" do
    let!(:comment) { create(:comment, user: user) }
    let(:comment_id) { comment.id }

    let(:query) do
      <<~GQL
        {
          comment(id: #{comment_id}) {
            id
            text
            userName
          }
        }
      GQL
    end

    subject(:fetch_comment) { RailsGraphqlSchema.execute(query) }

    let(:response) { fetch_comment.to_h["data"]["comment"] }

    let(:error_message) { fetch_comment.to_h["errors"].first["message"] }

    it "returns the comment ID" do
      actual = response["id"].to_i
      expect(actual).to eq(comment.id)
    end

    it "returns the comment text" do
      expect(response["text"]).to eq(comment.text)
    end

    it "returns the comment userName" do
      expected = "#{user.first_name} #{user.last_name}"
      expect(response["userName"]).to eq(expected)
    end

    context "when comment does not exist" do
      let(:comment_id) { 0 }

      it "returns an error response" do
        expect(error_message).to match(/Record not found/)
      end
    end
  end
end
