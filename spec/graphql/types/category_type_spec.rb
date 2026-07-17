require "rails_helper"

RSpec.describe Types::CategoryType do
  describe "querying all categories" do
    let(:query) do
      <<~GQL
        {
          categories {
            id
            title
            slug
            description
          }
        }
      GQL
    end

    subject(:fetch_all) { RailsGraphqlSchema.execute(query) }

    let(:response) { fetch_all.to_h["data"]["categories"] }

    context "when categories exist" do
      let!(:categories) { create_list(:category, 5) }

      it "returns the expected number of results" do
        expect(response.size).to eq(5)
      end

      it "returns category IDs" do
        category_id = response.first["id"].to_i
        expect(category_id).to be_a(Integer)
      end

      it "returns category titles" do
        actual = response.first["title"]
        expected = categories.first.title
        expect(actual).to eq(expected)
      end

      it "returns category slugs" do
        actual = response.first["slug"]
        expected = categories.first.slug
        expect(actual).to eq(expected)
      end
    end

    context "when categories do not exist" do
      it "returns an empty response" do
        expect(response).to be_empty
      end
    end
  end

  describe "querying a category by ID" do
    let!(:category) { create(:category) }
    let(:category_id) { category.id }

    let(:query) do
      <<~GQL
        {
          category(id: #{category_id}) {
            id
            title
            slug
            description
            blogs {
              id
            }
          }
        }
      GQL
    end

    subject(:fetch_category) { RailsGraphqlSchema.execute(query) }

    let(:response) { fetch_category.to_h["data"]["category"] }

    let(:error_message) { fetch_category.to_h["errors"].first["message"] }

    it "returns the category ID" do
      actual = response["id"].to_i
      expect(actual).to eq(category.id)
    end

    it "returns the category title" do
      expect(response["title"]).to eq(category.title)
    end

    it "returns the category slug" do
      expect(response["slug"]).to eq(category.slug)
    end

    it "returns the category's blogs" do
      blog = create(:blog)
      create(:blog_category, blog: blog, category: category)

      result = fetch_category.to_h["data"]["category"]["blogs"].map { |b| b["id"].to_i }
      expect(result).to eq([ blog.id ])
    end

    context "when category does not exist" do
      let(:category_id) { 0 }

      it "returns an error response" do
        expect(error_message).to match(/Record not found/)
      end
    end
  end
end
