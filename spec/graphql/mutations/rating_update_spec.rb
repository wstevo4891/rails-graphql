require "rails_helper"

RSpec.describe Mutations::RatingUpdate do
  let(:owner) { create(:user) }
  let(:rating) { create(:rating, user: owner) }
  let(:rating_id) { rating.id }
  let(:rating_value) { 1.5 }

  let(:query) do
    <<~GQL
      mutation updateRating {
        ratingUpdate(input: {
          id: #{rating_id},
          rating: #{rating_value}
        }) {
          rating {
            id
            rating
          }
        }
      }
    GQL
  end

  subject(:update_rating) { RailsGraphqlSchema.execute(query, context: { current_user: owner }) }

  let(:response) { update_rating.to_h }

  let(:response_data) { response["data"]["ratingUpdate"]["rating"] }

  let(:error_message) { response["errors"].first["message"] }

  let(:error_details) { response["errors"].first["extensions"] }

  it "updates the rating value" do
    expect(response_data["rating"]).to eq(rating_value)
  end

  context "without a current user" do
    subject(:update_rating) { RailsGraphqlSchema.execute(query) }

    it "returns a login error" do
      expect(error_message).to eq("Login to access")
    end
  end

  context "when current user is not the owner" do
    let(:other_user) { create(:user) }

    subject(:update_rating) do
      RailsGraphqlSchema.execute(query, context: { current_user: other_user })
    end

    it "returns an authorization error" do
      expect(error_message).to eq("You can only update your own ratings")
    end
  end

  context "when current user is an admin (not the owner)" do
    let(:admin) { create(:user, role: :admin) }

    subject(:update_rating) do
      RailsGraphqlSchema.execute(query, context: { current_user: admin })
    end

    it "updates the rating value" do
      expect(response_data["rating"]).to eq(rating_value)
    end
  end

  context "when the rating argument is out of range" do
    let(:rating_value) { 5.1 }

    it "returns an error message" do
      expect(error_message).to eq("Error updating rating")
    end

    it "returns validation error details" do
      expect(error_details["rating"]).to include("must be less than or equal to 5.0")
    end
  end

  context "when rating ID does not exist" do
    let(:rating_id) { 0 }

    it "returns a record not found message" do
      expect(error_message).to match(/Record not found/)
    end
  end
end
