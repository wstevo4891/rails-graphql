require "rails_helper"

RSpec.describe Blog, type: :model do
  subject(:blog) { build(:blog) }

  describe "factory" do
    it "builds a valid blog" do
      expect(blog).to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
  end

  describe "edge cases" do
    it "is invalid without a title" do
      blog.title = ""

      expect(blog).not_to be_valid
      expect(blog.errors[:title]).to include("can't be blank")
    end

    it "is invalid without a description" do
      blog.description = ""

      expect(blog).not_to be_valid
      expect(blog.errors[:description]).to include("can't be blank")
    end

    it "is invalid without a user" do
      blog.user = nil

      expect(blog).not_to be_valid
      expect(blog.errors[:user]).to include("must exist")
    end
  end
end
