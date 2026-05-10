require "rails_helper"

RSpec.describe Mutations::BlogDelete do
  let(:author) { create(:user) }
  let(:blog) { create(:blog, user: author) }
  let(:blog_id) { blog.id }

  let(:query) do
    <<~GQL
      mutation deleteBlog {
        blogDelete(input: { id: #{blog_id} }) {
          message
        }
      }
    GQL
  end

  subject(:delete_blog) { RailsGraphqlSchema.execute(query) }

  let(:response_message) { delete_blog.to_h["data"]["blogDelete"]["message"] }

  let(:error_message) { delete_blog.to_h["errors"].first["message"] }

  context "without a current user" do
    it "returns a login error" do
      expect(error_message).to eq("Login to access")
    end
  end

  context "when current user is an author" do
    subject(:delete_blog) do
      RailsGraphqlSchema.execute(query, context: { current_user: author })
    end

    it "retuns an authorization error" do
      expect(error_message).to eq("Only admins can delete blogs")
    end
  end

  context "when current user is an admin" do
    let(:admin) { create(:user, role: :admin) }

    subject(:delete_blog) do
      RailsGraphqlSchema.execute(query, context: { current_user: admin })
    end

    it "returns a success message" do
      expect(response_message).to eq("Blog deleted successfully")
    end

    it "deletes the blog" do
      delete_blog
      expect { Blog.find(blog.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when blog does not exist" do
      let(:blog_id) { 0 }

      it "returns a record not found message" do
        expect(error_message).to match(/Record not found/)
      end
    end
  end
end
