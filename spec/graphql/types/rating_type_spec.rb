require "rails_helper"

RSpec.describe Types::RatingType do
  let(:user) { create(:user) }

  describe "querying all ratings" do
    let(:query) do
      <<~GQL
        {
          ratings {
            id
            rating
            userName
          }
        }
      GQL
    end

    subject(:fetch_all) { RailsGraphqlSchema.execute(query) }

    let(:response) { fetch_all.to_h["data"]["ratings"] }

    context "when ratings exist" do
      let!(:ratings) { create_list(:rating, 5, user: user) }

      it "returns the expected number of results" do
        expect(response.size).to eq(5)
      end

      it "returns rating IDs" do
        rating_id = response.first["id"].to_i
        expect(rating_id).to be_a(Integer)
      end

      it "returns rating values" do
        actual = response.first["rating"]
        expected = ratings.first.rating.to_f
        expect(actual).to eq(expected)
      end

      it "returns rating userNames" do
        actual = response.first["userName"]
        expected = "#{user.first_name} #{user.last_name}"
        expect(actual).to eq(expected)
      end
    end

    context "when ratings do not exist" do
      it "returns an empty response" do
        expect(response).to be_empty
      end
    end
  end

  describe "querying a rating by ID" do
    let!(:rating) { create(:rating, user: user) }
    let(:rating_id) { rating.id }

    let(:query) do
      <<~GQL
        {
          rating(id: #{rating_id}) {
            id
            rating
            userName
          }
        }
      GQL
    end

    subject(:fetch_rating) { RailsGraphqlSchema.execute(query) }

    let(:response) { fetch_rating.to_h["data"]["rating"] }

    let(:error_message) { fetch_rating.to_h["errors"].first["message"] }

    it "returns the rating ID" do
      actual = response["id"].to_i
      expect(actual).to eq(rating.id)
    end

    it "returns the rating value" do
      expect(response["rating"]).to eq(rating.rating.to_f)
    end

    it "returns the rating userName" do
      expected = "#{user.first_name} #{user.last_name}"
      expect(response["userName"]).to eq(expected)
    end

    context "when rating does not exist" do
      let(:rating_id) { 0 }

      it "returns an error response" do
        expect(error_message).to match(/Record not found/)
      end
    end
  end
end
