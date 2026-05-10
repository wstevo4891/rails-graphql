require "rails_helper"

RSpec.describe Mutations::BlogDelete do
  let(:author) { create(:user) }
  let(:blog) { create(:blog, user: author) }

  let(:query) do
    <<~GQL
      mutation deleteBlog {
        blogDelete(input: { id: #{blog.id} }) {
          message
        }
      }
    GQL
  end

  context "without a current user" do
    subject(:delete_blog) do
      RailsGraphqlSchema.execute(query)
    end

    let(:error_message) { delete_blog.to_h["errors"].first["message"] }

    it "should return a login error" do
      expect(error_message).to eq("Login to access")
    end
  end

  context "when current user is an author" do
    subject(:delete_blog) do
      RailsGraphqlSchema.execute(query, context: { current_user: author })
    end

    let(:error_message) { delete_blog.to_h["errors"].first["message"] }

    it "should return an authorization error" do
      expect(error_message).to eq("Only admins can delete blogs")
    end
  end

  context "when current user is an admin" do
    let(:admin) { create(:user, role: :admin) }

    subject(:delete_blog) do
      RailsGraphqlSchema.execute(query, context: { current_user: admin })
    end

    let(:success_message) { delete_blog.to_h["data"]["blogDelete"]["message"] }

    it "returns a success message" do
      expect(success_message).to eq("Blog deleted successfully")
    end

    it "deletes the blog" do
      delete_blog
      expect { Blog.find(blog.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
