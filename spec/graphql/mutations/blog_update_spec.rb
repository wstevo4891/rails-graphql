require "rails_helper"

RSpec.describe Mutations::BlogUpdate do
  let(:user) { create(:user) }
  let(:blog) { create(:blog, user: user) }
  let(:blog_id) { blog.id }
  let(:title) { "An updated blog title" }
  let(:description) { "An updated blog description." }

  let(:query) do
    <<~GQL
      mutation updateBlog {
        blogUpdate(input: {
          id: #{blog_id},
          title: "#{title}",
          description: "#{description}"
        }) {
          blog {
            id
            title
            description
          }
        }
      }
    GQL
  end

  subject(:update_blog) { RailsGraphqlSchema.execute(query) }

  let(:response) { update_blog.to_h }

  let(:response_data) { response["data"]["blogUpdate"]["blog"] }

  let(:error_message) { response["errors"].first["message"] }

  let(:error_details) { response["errors"].first["extensions"] }

  it "updates the title" do
    expect(response_data["title"]).to eq(title)
  end

  it "updates the description" do
    expect(response_data["description"]).to eq(description)
  end

  context "when the title argument is blank" do
    let(:title) { "" }

    it "returns an error message" do
      expect(error_message).to eq("Error updating blog")
    end

    it "returns validation error details" do
      expect(error_details["title"]).to include("can't be blank")
    end
  end

  context "when the title argument is too long" do
    let(:title) { "A" * (Blog::TITLE_MAX + 1) }

    it "returns an error message" do
      expect(error_message).to eq("Error updating blog")
    end

    it "returns validation error details" do
      message = "is too long (maximum is 100 characters)"

      expect(error_details["title"]).to include(message)
    end
  end

  context "when the description argument is blank" do
    let(:description) { "" }

    it "returns an error message" do
      expect(error_message).to eq("Error updating blog")
    end

    it "returns validation error details" do
      expect(error_details["description"]).to include("can't be blank")
    end
  end

  context "when the description argument is too long" do
    let(:description) { "A" * (Blog::DESCRIPTION_MAX + 1) }

    it "returns an error message" do
      expect(error_message).to eq("Error updating blog")
    end

    it "returns validation error details" do
      message = "is too long (maximum is 500 characters)"

      expect(error_details["description"]).to include(message)
    end
  end

  context "when blog ID does not exist" do
    let(:blog_id) { 0 }

    it "returns a record not found message" do
      expect(error_message).to match(/Record not found/)
    end
  end

  describe "updating only the title" do
    let(:query) do
      <<~GQL
        mutation updateBlog {
          blogUpdate(input: {
            id: #{blog.id},
            title: "#{title}"
          }) {
            blog {
              title
              description
            }
          }
        }
      GQL
    end

    it "updates the title" do
      expect(response_data["title"]).to eq(title)
    end

    it "does not change the description" do
      expect(response_data["description"]).to eq(blog.description)
    end
  end

  describe "updating only the description" do
    let(:query) do
      <<~GQL
        mutation updateBlog {
          blogUpdate(input: {
            id: #{blog.id},
            description: "#{description}"
          }) {
            blog {
              title
              description
            }
          }
        }
      GQL
    end

    it "updates the description" do
      expect(response_data["description"]).to eq(description)
    end

    it "does not change the title" do
      expect(response_data["title"]).to eq(blog.title)
    end
  end

  describe "updating category_ids" do
    let(:categories) { create_list(:category, 2) }
    let(:category_ids) { categories.map(&:id) }

    let(:query) do
      <<~GQL
        mutation updateBlog {
          blogUpdate(input: {
            id: #{blog.id},
            categoryIds: [#{category_ids.join(', ')}]
          }) {
            blog {
              categories {
                id
              }
            }
          }
        }
      GQL
    end

    it "replaces the blog's categories" do
      ids = response_data["categories"].map { |c| c["id"].to_i }
      expect(ids).to match_array(category_ids)
    end

    context "when replacing with an empty list" do
      let(:query) do
        <<~GQL
          mutation updateBlog {
            blogUpdate(input: {
              id: #{blog.id},
              categoryIds: []
            }) {
              blog {
                categories {
                  id
                }
              }
            }
          }
        GQL
      end

      before { blog.category_ids = categories.map(&:id) }

      it "clears the blog's categories" do
        expect(response_data["categories"]).to be_empty
      end
    end
  end
end
