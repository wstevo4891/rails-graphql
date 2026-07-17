require "rails_helper"

RSpec.describe Mutations::CategoryUpdate do
  let(:category) { create(:category) }
  let(:category_id) { category.id }
  let(:title) { "An updated category title" }
  let(:slug) { "an-updated-category-slug" }
  let(:description) { "An updated category description." }

  let(:query) do
    <<~GQL
      mutation updateCategory {
        categoryUpdate(input: {
          id: #{category_id},
          title: "#{title}",
          slug: "#{slug}",
          description: "#{description}"
        }) {
          category {
            id
            title
            slug
            description
          }
        }
      }
    GQL
  end

  subject(:update_category) { RailsGraphqlSchema.execute(query) }

  let(:response) { update_category.to_h }

  let(:response_data) { response["data"]["categoryUpdate"]["category"] }

  let(:error_message) { response["errors"].first["message"] }

  let(:error_details) { response["errors"].first["extensions"] }

  it "updates the title" do
    expect(response_data["title"]).to eq(title)
  end

  it "updates the slug" do
    expect(response_data["slug"]).to eq(slug)
  end

  it "updates the description" do
    expect(response_data["description"]).to eq(description)
  end

  context "when the title argument is blank" do
    let(:title) { "" }

    it "returns an error message" do
      expect(error_message).to eq("Error updating category")
    end

    it "returns validation error details" do
      expect(error_details["title"]).to include("can't be blank")
    end
  end

  context "when the slug argument is already taken" do
    before { create(:category, slug: "already-taken") }

    let(:slug) { "already-taken" }

    it "returns an error message" do
      expect(error_message).to eq("Error updating category")
    end

    it "returns validation error details" do
      expect(error_details["slug"]).to include("has already been taken")
    end
  end

  context "when category ID does not exist" do
    let(:category_id) { 0 }

    it "returns a record not found message" do
      expect(error_message).to match(/Record not found/)
    end
  end

  describe "updating only the title" do
    let(:query) do
      <<~GQL
        mutation updateCategory {
          categoryUpdate(input: {
            id: #{category.id},
            title: "#{title}"
          }) {
            category {
              title
              slug
              description
            }
          }
        }
      GQL
    end

    it "updates the title" do
      expect(response_data["title"]).to eq(title)
    end

    it "does not change the slug" do
      expect(response_data["slug"]).to eq(category.slug)
    end

    it "does not change the description" do
      expect(response_data["description"]).to eq(category.description)
    end
  end
end
