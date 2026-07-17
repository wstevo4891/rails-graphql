require "rails_helper"

RSpec.describe Rating, type: :model do
  subject(:rating) { build(:rating) }

  describe "factory" do
    it "builds a valid rating" do
      expect(rating).to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:blog) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:rating) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:blog_id) }

    it "is invalid when rating is below 0.0" do
      rating.rating = -0.1

      expect(rating).not_to be_valid
      expect(rating.errors[:rating]).to include("must be greater than or equal to 0.0")
    end

    it "is invalid when rating is above 5.0" do
      rating.rating = 5.1

      expect(rating).not_to be_valid
      expect(rating.errors[:rating]).to include("must be less than or equal to 5.0")
    end

    it "is valid when rating is 0.0" do
      rating.rating = 0.0

      expect(rating).to be_valid
    end

    it "is valid when rating is 5.0" do
      rating.rating = 5.0

      expect(rating).to be_valid
    end
  end

  describe ".save" do
    it "creates a new record" do
      expect { rating.save! }.to change { Rating.count }.by(1)
    end
  end
end
