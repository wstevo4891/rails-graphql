require "rails_helper"

RSpec.describe BlogCategory, type: :model do
  subject(:blog_category) { build(:blog_category) }

  describe "factory" do
    it "builds a valid blog_category" do
      expect(blog_category).to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:blog) }
    it { should belong_to(:category) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:category_id).scoped_to(:blog_id) }
  end

  describe ".save" do
    it "creates a new record" do
      expect { blog_category.save! }.to change { BlogCategory.count }.by(1)
    end
  end
end
