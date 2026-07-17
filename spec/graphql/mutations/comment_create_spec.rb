require "rails_helper"

RSpec.describe Mutations::CommentCreate do
  let(:user) { create(:user) }
  let(:blog) { create(:blog) }
  let(:blog_id) { blog.id }
  let(:text) { "A sample comment." }

  let(:query) do
    <<~GQL
      mutation createComment {
        commentCreate(input: {
          blogId: #{blog_id},
          text: "#{text}"
        }) {
          comment {
            id
            text
            userId
          }
        }
      }
    GQL
  end

  subject(:create_comment) { RailsGraphqlSchema.execute(query, context: { current_user: user }) }

  let(:response) { create_comment.to_h }

  let(:comment_data) { response["data"]["commentCreate"]["comment"] }

  let(:error_message) { response["errors"].first["message"] }

  let(:error_details) { response["errors"].first["extensions"] }

  it "creates a new comment" do
    expect { create_comment }.to change { Comment.count }.by(1)
  end

  it "returns the requested comment id" do
    expect(comment_data["id"].to_i).to be_a(Integer)
  end

  it "returns the requested comment text" do
    expect(comment_data["text"]).to eq(text)
  end

  it "sets the user id from the current user" do
    expect(comment_data["userId"]).to eq(user.id)
  end

  context "without a current user" do
    subject(:create_comment) { RailsGraphqlSchema.execute(query) }

    it "returns a login error" do
      expect(error_message).to eq("Login to access")
    end

    it "does not create a comment" do
      expect { create_comment }.not_to change { Comment.count }
    end
  end

  context "when the text is blank" do
    let(:text) { "" }

    it "returns an error message" do
      expect(error_message).to eq("Error creating comment")
    end

    it "returns validation error details" do
      expect(error_details["text"]).to include("can't be blank")
    end
  end

  context "when the blog ID does not exist" do
    let(:blog_id) { 0 }

    it "returns an error message" do
      expect(error_message).to eq("Error creating comment")
    end

    it "returns validation error details" do
      expect(error_details["blog"]).to include("must exist")
    end
  end
end
