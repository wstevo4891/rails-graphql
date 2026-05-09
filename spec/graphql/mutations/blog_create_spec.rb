require "rails_helper"

RSpec.describe Mutations::BlogCreate do
  let(:user) { create(:user) }
  let(:user_id) { user.id }
  let(:title) { "A sample blog title" }
  let(:description) { "A sample blog description." }

  let(:query) do
    input = <<~INPUT
      {
        title: "#{title}",
        description: "#{description}",
        userId: #{user_id}
      }
    INPUT

    <<~GQL
      mutation createBlog {
        blogCreate(input: #{input}) {
          blog {
            id
            title
          }
        }
      }
    GQL
  end

  subject(:create_blog) { RailsGraphqlSchema.execute(query) }

  let(:response) { create_blog.to_h }

  let(:blog_data) { response["data"]["blogCreate"]["blog"] }

  let(:error_message) { response["errors"].first["message"] }

  let(:error_details) { response["errors"].first["extensions"] }

  it "creates a new blog" do
    expect { create_blog }.to change { Blog.count }.by(1)
  end

  it "returns the requested blog id" do
    expect(blog_data["id"].to_i).to be_a(Integer)
  end

  it "returns the requested blog title" do
    expect(blog_data["title"]).to eq(title)
  end

  context "when the title is blank" do
    let(:title) { "" }

    it "returns an error message" do
      expect(error_message).to eq("Error creating blog")
    end

    it "returns validation error details" do
      message = "is too short (minimum is 1 character)"

      expect(error_details["title"]).to include(message)
    end
  end

  context "when the description is blank" do
    let(:description) { "" }

    it "returns an error message" do
      expect(error_message).to eq("Error creating blog")
    end

    it "returns validation error details" do
      message = "is too short (minimum is 1 character)"

      expect(error_details["description"]).to include(message)
    end
  end

  context "when the user ID does not exist" do
    let(:user_id) { 0 }

    it "returns an error message" do
      expect(error_message).to eq("Error creating blog")
    end

    it "returns validation error details" do
      expect(error_details["user"]).to include("must exist")
    end
  end
end
