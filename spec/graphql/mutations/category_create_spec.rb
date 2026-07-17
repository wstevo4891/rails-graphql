require "rails_helper"

RSpec.describe Mutations::CategoryCreate do
  let(:title) { "A sample category title" }
  let(:slug) { "a-sample-category-title" }
  let(:description) { "A sample category description." }

  let(:query) do
    <<~GQL
      mutation createCategory {
        categoryCreate(input: {
          title: "#{title}",
          slug: "#{slug}",
          description: "#{description}"
        }) {
          category {
            id
            title
            slug
          }
        }
      }
    GQL
  end

  subject(:create_category) { RailsGraphqlSchema.execute(query) }

  let(:response) { create_category.to_h }

  let(:category_data) { response["data"]["categoryCreate"]["category"] }

  let(:error_message) { response["errors"].first["message"] }

  let(:error_details) { response["errors"].first["extensions"] }

  it "creates a new category" do
    expect { create_category }.to change { Category.count }.by(1)
  end

  it "returns the requested category id" do
    expect(category_data["id"].to_i).to be_a(Integer)
  end

  it "returns the requested category title" do
    expect(category_data["title"]).to eq(title)
  end

  it "returns the requested category slug" do
    expect(category_data["slug"]).to eq(slug)
  end

  context "when the title is blank" do
    let(:title) { "" }

    it "returns an error message" do
      expect(error_message).to eq("Error creating category")
    end

    it "returns validation error details" do
      message = "is too short (minimum is 1 character)"

      expect(error_details["title"]).to include(message)
    end
  end

  context "when the description is blank" do
    let(:description) { "" }

    it "returns an error message" do
      expect(error_message).to eq("Error creating category")
    end

    it "returns validation error details" do
      message = "is too short (minimum is 1 character)"

      expect(error_details["description"]).to include(message)
    end
  end

  context "when the slug is blank" do
    let(:slug) { "" }

    it "returns an error message" do
      expect(error_message).to eq("Error creating category")
    end

    it "returns validation error details" do
      expect(error_details["slug"]).to include("can't be blank")
    end
  end

  context "when the slug is already taken" do
    before { create(:category, slug: slug) }

    it "returns an error message" do
      expect(error_message).to eq("Error creating category")
    end

    it "returns validation error details" do
      expect(error_details["slug"]).to include("has already been taken")
    end
  end
end
