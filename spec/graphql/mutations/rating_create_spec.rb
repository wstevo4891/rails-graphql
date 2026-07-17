require "rails_helper"

RSpec.describe Mutations::RatingCreate do
  let(:user) { create(:user) }
  let(:blog) { create(:blog) }
  let(:blog_id) { blog.id }
  let(:rating_value) { 4.5 }

  let(:query) do
    <<~GQL
      mutation createRating {
        ratingCreate(input: {
          blogId: #{blog_id},
          rating: #{rating_value}
        }) {
          rating {
            id
            rating
            userId
          }
        }
      }
    GQL
  end

  subject(:create_rating) { RailsGraphqlSchema.execute(query, context: { current_user: user }) }

  let(:response) { create_rating.to_h }

  let(:rating_data) { response["data"]["ratingCreate"]["rating"] }

  let(:error_message) { response["errors"].first["message"] }

  let(:error_details) { response["errors"].first["extensions"] }

  it "creates a new rating" do
    expect { create_rating }.to change { Rating.count }.by(1)
  end

  it "returns the requested rating id" do
    expect(rating_data["id"].to_i).to be_a(Integer)
  end

  it "returns the requested rating value" do
    expect(rating_data["rating"]).to eq(rating_value)
  end

  it "sets the user id from the current user" do
    expect(rating_data["userId"]).to eq(user.id)
  end

  context "without a current user" do
    subject(:create_rating) { RailsGraphqlSchema.execute(query) }

    it "returns a login error" do
      expect(error_message).to eq("Login to access")
    end

    it "does not create a rating" do
      expect { create_rating }.not_to change { Rating.count }
    end
  end

  context "when the rating is below 0.0" do
    let(:rating_value) { -0.1 }

    it "returns an error message" do
      expect(error_message).to eq("Error creating rating")
    end

    it "returns validation error details" do
      expect(error_details["rating"]).to include("must be greater than or equal to 0.0")
    end
  end

  context "when the rating is above 5.0" do
    let(:rating_value) { 5.1 }

    it "returns an error message" do
      expect(error_message).to eq("Error creating rating")
    end

    it "returns validation error details" do
      expect(error_details["rating"]).to include("must be less than or equal to 5.0")
    end
  end

  context "when the user has already rated this blog" do
    before { create(:rating, blog: blog, user: user, rating: 2.0) }

    it "does not create a new rating record" do
      expect { create_rating }.not_to change { Rating.count }
    end

    it "updates the existing rating value" do
      create_rating
      expect(Rating.find_by(blog: blog, user: user).rating).to eq(rating_value)
    end
  end
end
