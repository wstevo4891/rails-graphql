require "rails_helper"

RSpec.describe Mutations::CategoryDelete do
  let(:category) { create(:category) }
  let(:category_id) { category.id }

  let(:query) do
    <<~GQL
      mutation deleteCategory {
        categoryDelete(input: { id: #{category_id} }) {
          message
        }
      }
    GQL
  end

  subject(:delete_category) { RailsGraphqlSchema.execute(query) }

  let(:response_message) { delete_category.to_h["data"]["categoryDelete"]["message"] }

  let(:error_message) { delete_category.to_h["errors"].first["message"] }

  context "without a current user" do
    it "returns a login error" do
      expect(error_message).to eq("Login to access")
    end
  end

  context "when current user is an author" do
    let(:author) { create(:user) }

    subject(:delete_category) do
      RailsGraphqlSchema.execute(query, context: { current_user: author })
    end

    it "returns an authorization error" do
      expect(error_message).to eq("Only admins can delete categories")
    end
  end

  context "when current user is an admin" do
    let(:admin) { create(:user, role: :admin) }

    subject(:delete_category) do
      RailsGraphqlSchema.execute(query, context: { current_user: admin })
    end

    it "returns a success message" do
      expect(response_message).to eq("Category deleted successfully")
    end

    it "deletes the category" do
      delete_category
      expect { Category.find(category.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when category does not exist" do
      let(:category_id) { 0 }

      it "returns a record not found message" do
        expect(error_message).to match(/Record not found/)
      end
    end
  end
end
