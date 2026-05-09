require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "associations" do
    it { should have_many(:blogs).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should define_enum_for(:role).with_values(author: 0, admin: 1) }
  end

  describe "password format" do
    it "is invalid when the password does not include a special character" do
      user.password = "Password1"
      user.password_confirmation = "Password1"

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("condition failed")
    end
  end

  describe "callbacks" do
    it "downcases email before saving" do
      user.email = "TEST@EXAMPLE.COM"
      user.save!

      expect(user.email).to eq("test@example.com")
    end
  end
end
