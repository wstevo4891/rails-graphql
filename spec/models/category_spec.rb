require "rails_helper"

RSpec.describe Category, type: :model do
  subject(:category) { build(:category) }

  describe "factory" do
    it "builds a valid category" do
      expect(category).to be_valid
    end
  end

  describe "associations" do
    it { should have_many(:blog_categories).dependent(:destroy) }
    it { should have_many(:blogs).through(:blog_categories) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:slug) }

    it "is invalid without a title" do
      category.title = ""

      expect(category).not_to be_valid
      expect(category.errors[:title]).to include("can't be blank")
    end

    it "is invalid when title is too long" do
      message = "is too long (maximum is #{Category::TITLE_MAX} characters)"
      category.title = "A" * (Category::TITLE_MAX + 1)

      expect(category).not_to be_valid
      expect(category.errors[:title]).to include(message)
    end

    it "is invalid without a description" do
      category.description = ""

      expect(category).not_to be_valid
      expect(category.errors[:description]).to include("can't be blank")
    end

    it "is invalid when description is too long" do
      message = "is too long (maximum is #{Category::DESCRIPTION_MAX} characters)"
      category.description = "A" * (Category::DESCRIPTION_MAX + 1)

      expect(category).not_to be_valid
      expect(category.errors[:description]).to include(message)
    end

    it "is invalid without a slug" do
      category.slug = ""

      expect(category).not_to be_valid
      expect(category.errors[:slug]).to include("can't be blank")
    end

    it "is invalid with a duplicate slug" do
      create(:category, slug: "duplicate-slug")
      category.slug = "duplicate-slug"

      expect(category).not_to be_valid
      expect(category.errors[:slug]).to include("has already been taken")
    end
  end

  describe ".save" do
    it "creates a new record" do
      expect { category.save! }.to change { Category.count }.by(1)
    end
  end
end
