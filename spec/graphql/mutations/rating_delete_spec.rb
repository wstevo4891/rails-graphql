require "rails_helper"

RSpec.describe Mutations::RatingDelete do
  let(:owner) { create(:user) }
  let(:rating) { create(:rating, user: owner) }
  let(:rating_id) { rating.id }

  let(:query) do
    <<~GQL
      mutation deleteRating {
        ratingDelete(input: { id: #{rating_id} }) {
          message
        }
      }
    GQL
  end

  subject(:delete_rating) { RailsGraphqlSchema.execute(query, context: { current_user: owner }) }

  let(:response_message) { delete_rating.to_h["data"]["ratingDelete"]["message"] }

  let(:error_message) { delete_rating.to_h["errors"].first["message"] }

  context "without a current user" do
    subject(:delete_rating) { RailsGraphqlSchema.execute(query) }

    it "returns a login error" do
      expect(error_message).to eq("Login to access")
    end
  end

  context "when current user is not the owner" do
    let(:other_user) { create(:user) }

    subject(:delete_rating) do
      RailsGraphqlSchema.execute(query, context: { current_user: other_user })
    end

    it "returns an authorization error" do
      expect(error_message).to eq("You can only delete your own ratings")
    end
  end

  context "when current user is the owner" do
    it "returns a success message" do
      expect(response_message).to eq("Rating deleted successfully")
    end

    it "deletes the rating" do
      delete_rating
      expect { Rating.find(rating.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when current user is an admin (not the owner)" do
    let(:admin) { create(:user, role: :admin) }

    subject(:delete_rating) do
      RailsGraphqlSchema.execute(query, context: { current_user: admin })
    end

    it "returns a success message" do
      expect(response_message).to eq("Rating deleted successfully")
    end
  end

  context "when rating does not exist" do
    let(:rating_id) { 0 }

    it "returns a record not found message" do
      expect(error_message).to match(/Record not found/)
    end
  end
end
